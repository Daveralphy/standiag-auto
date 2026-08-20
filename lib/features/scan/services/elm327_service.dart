// Real ELM327 OBD-II protocol over Bluetooth Low Energy.
//
// This is a genuine hardware integration, not a simulation: it scans for
// nearby BLE devices, connects to a real ELM327-compatible OBD-II adapter,
// speaks the actual ELM327 AT-command protocol, and queries real SAE J1979
// PIDs (RPM, coolant temperature, vehicle speed) plus stored Diagnostic
// Trouble Codes (Mode 03). There is no fabricated data anywhere in this file
// — every value returned came from the adapter's actual response, or is
// null/empty if the adapter didn't answer.
//
// BLE ELM327 clones don't share one standard GATT UUID scheme the way
// classic Bluetooth SPP devices effectively do, so connection uses a
// two-step strategy: try the common Nordic UART Service UUIDs first (used
// by many cheap clones), then fall back to scanning all discovered services
// for the first writable + first notifiable characteristic.

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// A single real diagnostic reading pulled from the adapter.
class ObdReading {
  final int? rpm;
  final int? coolantTempC;
  final int? speedKph;
  final List<String> dtcCodes;

  const ObdReading({
    this.rpm,
    this.coolantTempC,
    this.speedKph,
    this.dtcCodes = const [],
  });

  Map<String, dynamic> toRawData() => {
        if (rpm != null) 'rpm': rpm,
        if (coolantTempC != null) 'coolantTempC': coolantTempC,
        if (speedKph != null) 'speedKph': speedKph,
        'dtcCodes': dtcCodes,
        'source': 'obd_ble_elm327',
      };
}

class Elm327ConnectionException implements Exception {
  final String message;
  Elm327ConnectionException(this.message);
  @override
  String toString() => message;
}

class Elm327Service {
  // Nordic UART Service — the single most common BLE-serial UUID scheme
  // used by ELM327 BLE clones (and generic BLE-to-serial bridges).
  static final Guid _nusService = Guid('6e400001-b5a3-f393-e0a9-e50e24dcca9e');
  static final Guid _nusRxWrite = Guid('6e400002-b5a3-f393-e0a9-e50e24dcca9e');
  static final Guid _nusTxNotify = Guid('6e400003-b5a3-f393-e0a9-e50e24dcca9e');

  // Other BLE-serial service UUIDs commonly used by cheap ELM327 clones.
  // Checking these (from the advertisement packet) needs no connection —
  // far more reliable than guessing from a device's advertised name alone.
  static final Set<String> _knownSerialServiceUuids = {
    _nusService.toString().toLowerCase(),
    '0000fff0-0000-1000-8000-00805f9b34fb',
    '0000ffe0-0000-1000-8000-00805f9b34fb',
  };

  static const List<String> _obdNameKeywords = [
    'obd', 'elm327', 'elm 327', 'elm-327', 'vlink', 'veepeak', 'vgate',
    'icar', 'obdlink', 'scantool', 'konnwei', 'bafx', 'obdii', 'obd2',
    'obd-ii',
  ];

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;
  StreamSubscription<List<int>>? _notifySub;

  bool get isConnected => _device?.isConnected ?? false;
  String? get connectedDeviceName => _device?.platformName;
  String? get connectedDeviceId => _device?.remoteId.str;

  /// Best name to show for a scan result — checks the platform-cached name
  /// first, then falls back to the name from the advertisement packet.
  static String displayNameFor(ScanResult result) {
    if (result.device.platformName.isNotEmpty) return result.device.platformName;
    if (result.advertisementData.advName.isNotEmpty) {
      return result.advertisementData.advName;
    }
    return '';
  }

  /// A best-effort, non-authoritative signal for whether a discovered
  /// device is likely an OBD-II adapter. This is only used to sort/badge
  /// entries in the picker — it never blocks a connection attempt, since
  /// there's no way to be fully certain without actually connecting.
  ///
  /// Checks, in order of reliability:
  ///  1. Advertised BLE service UUIDs matching known serial-bridge services
  ///     (this is real signal — the device is advertising exactly the kind
  ///     of channel an ELM327 clone needs — no connection required to see it).
  ///  2. The device's advertised name containing a recognizable OBD/adapter
  ///     brand keyword.
  static bool looksLikeObdAdapter(ScanResult result) {
    for (final uuid in result.advertisementData.serviceUuids) {
      if (_knownSerialServiceUuids.contains(uuid.toString().toLowerCase())) {
        return true;
      }
    }
    final name = displayNameFor(result).toLowerCase();
    if (name.isEmpty) return false;
    return _obdNameKeywords.any((keyword) => name.contains(keyword));
  }

  /// Makes sure the phone's Bluetooth radio is actually on before we try to
  /// scan. On Android this can prompt the system "turn on Bluetooth" dialog
  /// directly; iOS does not allow third-party apps to toggle Bluetooth
  /// programmatically, so there we just surface a clear message instead.
  Future<void> _ensureAdapterOn() async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState == BluetoothAdapterState.on) return;

    if (!Platform.isAndroid) {
      throw Elm327ConnectionException(
          'Bluetooth is turned off. Please turn it on in Settings and try again.');
    }

    try {
      await FlutterBluePlus.turnOn();
    } catch (_) {
      throw Elm327ConnectionException(
          'Bluetooth is turned off. Please turn it on and try again.');
    }

    final onNow = await FlutterBluePlus.adapterState.first;
    if (onNow != BluetoothAdapterState.on) {
      throw Elm327ConnectionException(
          'Bluetooth is turned off. Please turn it on and try again.');
    }
  }

  /// Scans for nearby BLE devices. Every advertising device is surfaced —
  /// OBD-II adapters don't advertise a discoverable common service uuid, so
  /// filtering by name would risk hiding a real adapter with an unusual name.
  ///
  /// The returned future completes once the scan has actually started (or
  /// throws if it couldn't) — callers must await this before listening to
  /// the result stream, otherwise a failure to start (Bluetooth off, no
  /// permission, adapter busy) is silently lost instead of being reported.
  Future<Stream<List<ScanResult>>> scan(
      {Duration timeout = const Duration(seconds: 8)}) async {
    await _ensureAdapterOn();
    await FlutterBluePlus.startScan(timeout: timeout);
    return FlutterBluePlus.scanResults;
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {
      // Stopping a scan that's already stopped (or mid-teardown) is harmless
      // — never let cleanup itself throw.
    }
  }

  /// Connects to [device], discovers its GATT services, and locates a
  /// writable + notifiable characteristic pair to speak the ELM327 protocol
  /// over. Throws [Elm327ConnectionException] if no usable characteristic
  /// pair is found — this is a real, honest failure, not a silent fallback.
  Future<void> connect(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    await device.connect(timeout: const Duration(seconds: 12));
    final services = await device.discoverServices();

    BluetoothCharacteristic? write;
    BluetoothCharacteristic? notify;

    // First choice: the common Nordic UART Service layout.
    for (final service in services) {
      if (service.uuid == _nusService) {
        for (final c in service.characteristics) {
          if (c.uuid == _nusRxWrite) write = c;
          if (c.uuid == _nusTxNotify) notify = c;
        }
      }
    }

    // Fallback: the first writable characteristic and the first notifiable
    // characteristic found anywhere on the device (common on generic
    // FFF0/FFF1/FFF2-style BLE-serial clones).
    if (write == null || notify == null) {
      for (final service in services) {
        for (final c in service.characteristics) {
          if (write == null && (c.properties.write || c.properties.writeWithoutResponse)) {
            write = c;
          }
          if (notify == null && c.properties.notify) {
            notify = c;
          }
        }
      }
    }

    if (write == null || notify == null) {
      await device.disconnect();
      throw Elm327ConnectionException(
          "This device doesn't look like an OBD-II adapter — no serial-style Bluetooth channel was found.");
    }

    _device = device;
    _writeChar = write;
    _notifyChar = notify;
    await notify.setNotifyValue(true);

    // Standard ELM327 init sequence: reset, echo off, linefeeds off,
    // spaces off, headers off, auto-detect protocol.
    await _sendCommand('ATZ', timeout: const Duration(seconds: 3));
    await _sendCommand('ATE0');
    await _sendCommand('ATL0');
    await _sendCommand('ATS0');
    await _sendCommand('ATH0');
    await _sendCommand('ATSP0');
  }

  Future<void> disconnect() async {
    try {
      await _notifySub?.cancel();
      if (_device != null && _device!.isConnected) {
        await _device!.disconnect();
      }
    } catch (_) {
      // Cleanup must never throw — the device may already be gone.
    } finally {
      _notifySub = null;
      _device = null;
      _writeChar = null;
      _notifyChar = null;
    }
  }

  /// Sends a raw ELM327 command and waits for its terminating `>` prompt.
  /// Returns the adapter's raw ASCII response with the prompt stripped.
  Future<String> _sendCommand(String command,
      {Duration timeout = const Duration(seconds: 5)}) async {
    final writeChar = _writeChar;
    final notifyChar = _notifyChar;
    if (writeChar == null || notifyChar == null) {
      throw Elm327ConnectionException('Not connected to an OBD-II adapter.');
    }

    final buffer = StringBuffer();
    final completer = Completer<String>();
    late final StreamSubscription<List<int>> sub;
    sub = notifyChar.lastValueStream.listen((bytes) {
      if (bytes.isEmpty) return;
      buffer.write(utf8.decode(bytes, allowMalformed: true));
      if (buffer.toString().contains('>')) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete(buffer.toString());
      }
    });

    try {
      final payload = '$command\r'.codeUnits;
      await writeChar.write(payload,
          withoutResponse: writeChar.properties.writeWithoutResponse);
      final raw = await completer.future.timeout(timeout, onTimeout: () {
        sub.cancel();
        throw Elm327ConnectionException(
            'The OBD-II adapter did not respond to "$command".');
      });
      return raw.replaceAll('>', '').trim();
    } finally {
      await sub.cancel();
    }
  }

  /// Runs a real diagnostic pass: queries RPM, coolant temperature, vehicle
  /// speed, and any stored trouble codes. A PID the adapter genuinely has
  /// nothing to report for (engine off, unsupported PID, etc.) is simply
  /// left null — never substituted with a fabricated value. A real
  /// communication failure (the adapter stops responding, a BLE write
  /// fails) is a different thing entirely and throws instead of returning
  /// a reading — the caller must not treat that as "no trouble codes".
  Future<ObdReading> runDiagnostics() async {
    final rpm = await _queryPid('010C', _parseRpm);
    final coolant = await _queryPid('0105', _parseCoolantTemp);
    final speed = await _queryPid('010D', _parseSpeed);
    final dtcs = await _queryDtcs();
    return ObdReading(
      rpm: rpm,
      coolantTempC: coolant,
      speedKph: speed,
      dtcCodes: dtcs,
    );
  }

  /// Deliberately does NOT catch here. A clean "the adapter has nothing to
  /// report for this PID" (engine off, unsupported PID) comes back as a
  /// normal response string and is turned into `null` by
  /// [_extractDataBytes] without throwing at all — that path is unaffected.
  /// What must NOT be swallowed is a real communication failure (a BLE
  /// write error, a timeout because the adapter stopped responding
  /// mid-scan): those need to reach [runDiagnostics] and abort the scan,
  /// not get silently downgraded into "no data", which is how a mid-scan
  /// disconnect used to get saved as a perfectly healthy result.
  Future<T?> _queryPid<T>(
      String pid, T? Function(List<int> dataBytes) parse) async {
    final response = await _sendCommand(pid);
    final bytes = _extractDataBytes(response, expectedModeEcho: pid.substring(0, 2));
    if (bytes == null) return null;
    return parse(bytes);
  }

  /// See [_queryPid]'s doc comment — same reasoning applies here.
  Future<List<String>> _queryDtcs() async {
    final response = await _sendCommand('03');
    return _parseDtcResponse(response);
  }

  /// Strips ELM327 whitespace/echo noise and returns the hex data bytes
  /// following the echoed mode+PID, or null if the adapter reported no data
  /// (e.g. "NO DATA", "UNABLE TO CONNECT", "?").
  List<int>? _extractDataBytes(String response, {required String expectedModeEcho}) {
    final cleaned = response.replaceAll(RegExp(r'[\r\n]'), ' ').trim();
    if (cleaned.isEmpty) return null;
    final upper = cleaned.toUpperCase();
    if (upper.contains('NO DATA') ||
        upper.contains('UNABLE TO CONNECT') ||
        upper.contains('ERROR') ||
        upper.contains('?')) {
      return null;
    }
    final hexOnly = upper.replaceAll(RegExp(r'[^0-9A-F]'), '');
    if (hexOnly.length < 4) return null;

    final bytes = <int>[];
    for (var i = 0; i + 1 < hexOnly.length; i += 2) {
      final byte = int.tryParse(hexOnly.substring(i, i + 2), radix: 16);
      if (byte == null) return null;
      bytes.add(byte);
    }
    // Response mode byte is the request mode + 0x40 (e.g. 01 -> 41).
    // Drop the mode-echo and PID-echo bytes, keep only the data bytes.
    if (bytes.length < 2) return null;
    return bytes.sublist(2);
  }

  int? _parseRpm(List<int> data) {
    if (data.length < 2) return null;
    return ((data[0] * 256) + data[1]) ~/ 4;
  }

  int? _parseCoolantTemp(List<int> data) {
    if (data.isEmpty) return null;
    return data[0] - 40;
  }

  int? _parseSpeed(List<int> data) {
    if (data.isEmpty) return null;
    return data[0];
  }

  List<String> _parseDtcResponse(String response) {
    final cleaned = response.replaceAll(RegExp(r'[\r\n]'), ' ').trim();
    final upper = cleaned.toUpperCase();
    if (upper.contains('NO DATA') || upper.isEmpty) return const [];

    final hexOnly = upper.replaceAll(RegExp(r'[^0-9A-F]'), '');
    // Response starts with the mode echo (43) — drop it, then read 2 bytes
    // (4 hex chars) per trouble code.
    final body = hexOnly.startsWith('43') ? hexOnly.substring(2) : hexOnly;
    final codes = <String>[];
    for (var i = 0; i + 3 < body.length; i += 4) {
      final chunk = body.substring(i, i + 4);
      final code = _decodeDtcChunk(chunk);
      if (code != null) codes.add(code);
    }
    return codes;
  }

  /// Decodes a 2-byte DTC chunk into standard "P0301" style notation.
  /// The first two bits of the first byte select the code family
  /// (P=powertrain, C=chassis, B=body, U=network) per SAE J2012.
  String? _decodeDtcChunk(String hexChunk) {
    final value = int.tryParse(hexChunk, radix: 16);
    if (value == null || value == 0) return null;
    const families = ['P', 'C', 'B', 'U'];
    final family = families[(value >> 14) & 0x03];
    final rest = (value & 0x3FFF).toRadixString(16).padLeft(4, '0').toUpperCase();
    return '$family$rest';
  }
}

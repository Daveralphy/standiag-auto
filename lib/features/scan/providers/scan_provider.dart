// Scan provider — owns the real OBD-II BLE connection and scan history.
// Scan history is written to Firestore and mirrored in Hive. The diagnostic
// data itself comes from a real ELM327 adapter over Bluetooth (Elm327Service)
// — there is no fabricated health score anywhere in this file.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/constants/credits_pricing.dart';
import '../../../core/errors/error_handler.dart';
import '../../credits/providers/credits_provider.dart';
import '../../credits/services/credits_gateway.dart';

import '../models/scan_model.dart';
import '../services/elm327_service.dart';

class ScanState {
  final List<ScanModel> history;
  final ScanModel? latestScan;
  final bool isScanning;
  final bool isConnected;
  final bool isConnectingDevice;
  final bool isDiscovering;
  final String? connectedDeviceName;
  final List<ScanResult> discoveredDevices;

  /// Which of the owner's vehicles a scan applies to — explicit, rather
  /// than always silently defaulting to whichever vehicle an unordered
  /// Firestore query happens to return first. Null until the owner (with
  /// more than one vehicle) actually picks one.
  final String? selectedVehicleId;

  /// Error from the Bluetooth connect/scan flow — shown near the Connect
  /// Adapter / Tap to Scan button.
  final String? error;

  /// Error from fetching past scan history — a completely separate concern
  /// from the Bluetooth flow, kept in its own field so a history-fetch
  /// failure (e.g. a Firestore query issue) can never show up under the
  /// Connect Adapter button and look like a Bluetooth problem.
  final String? historyError;

  const ScanState({
    this.history = const [],
    this.latestScan,
    this.isScanning = false,
    this.isConnected = false,
    this.isConnectingDevice = false,
    this.isDiscovering = false,
    this.connectedDeviceName,
    this.discoveredDevices = const [],
    this.selectedVehicleId,
    this.error,
    this.historyError,
  });

  ScanState copyWith({
    List<ScanModel>? history,
    ScanModel? latestScan,
    bool? isScanning,
    bool? isConnected,
    bool? isConnectingDevice,
    bool? isDiscovering,
    String? connectedDeviceName,
    List<ScanResult>? discoveredDevices,
    String? selectedVehicleId,
    String? error,
    String? historyError,
  }) {
    return ScanState(
      history: history ?? this.history,
      latestScan: latestScan ?? this.latestScan,
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
      isConnectingDevice: isConnectingDevice ?? this.isConnectingDevice,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      error: error,
      historyError: historyError,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier(this._ref) : super(const ScanState());

  // Needed to charge/refund credits for a scan via CreditsGateway, which
  // reads creditsProvider.notifier — this notifier has no WidgetRef of its
  // own the way a widget would, so it's handed the provider's own Ref
  // instead, same as any provider that needs to reach another one.
  final Ref _ref;

  final Elm327Service _elm327 = Elm327Service();

  /// Tracks the adapter's real BLE connection state so a physical
  /// disconnect (out of range, adapter powered off) is reflected in
  /// [ScanState.isConnected] immediately, instead of the UI going on
  /// showing "Connected" until the next scan attempt fails. Cancelled
  /// before every *voluntary* disconnect (see [disconnectDevice]) so that
  /// path doesn't also show a spurious "lost connection" error.
  StreamSubscription<BluetoothConnectionState>? _connectionSub;

  void selectVehicle(String vehicleId) {
    state = state.copyWith(
        selectedVehicleId: vehicleId,
        error: state.error,
        historyError: state.historyError);
  }

  /// Requests the Bluetooth runtime permissions needed to scan/connect.
  ///
  /// `Permission.bluetooth` only corresponds to a real requestable permission
  /// on iOS (tied to NSBluetoothAlwaysUsageDescription). On Android it maps
  /// to the old install-time-only BLUETOOTH permission, which isn't
  /// meaningfully "requestable" on modern Android — including it in the same
  /// check as bluetoothScan/bluetoothConnect caused the overall check to
  /// fail even when the two permissions that actually matter were granted.
  /// So each platform checks only the permission that's real for it.
  Future<bool> _ensurePermissions() async {
    if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      // ignore: avoid_print
      print('[Elm327] iOS bluetooth permission status: $status');
      return status.isGranted || status.isLimited;
    }

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    // ignore: avoid_print
    print('[Elm327] Android permission statuses: '
        '${statuses.map((permission, status) => MapEntry(permission.toString(), status.toString()))}');
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  /// Starts a BLE device scan. Call [stopDeviceDiscovery] to stop early —
  /// otherwise it stops itself after the timeout.
  Future<void> startDeviceDiscovery() async {
    state = state.copyWith(
        isDiscovering: true,
        discoveredDevices: const [],
        error: null,
        historyError: state.historyError);
    final granted = await _ensurePermissions();
    if (!granted) {
      state = state.copyWith(
        isDiscovering: false,
        error: 'Bluetooth permission is required to find your OBD-II adapter.',
        historyError: state.historyError,
      );
      return;
    }
    try {
      // Awaiting here is what makes a failure to *start* the scan (Bluetooth
      // off, permission denied, adapter busy) actually reach this catch
      // block — without it, such a failure previously vanished silently and
      // left the sheet stuck on "Searching…" forever. The explicit timeout
      // is a hard backstop so discovery can never hang indefinitely even in
      // a case this error handling doesn't anticipate.
      final stream = await _elm327.scan().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException(
            'Could not start the Bluetooth scan. Please try again.'),
      );
      stream.listen((results) {
        state = state.copyWith(
            discoveredDevices: results,
            error: state.error,
            historyError: state.historyError);
      }, onError: (e, stackTrace) {
        state = state.copyWith(
          isDiscovering: false,
          error: ErrorHandler.handle(e, stackTrace as StackTrace,
                  screen: 'ScanProvider.startDeviceDiscovery')
              .message,
          historyError: state.historyError,
        );
      }, onDone: () {
        state = state.copyWith(
            isDiscovering: false,
            error: state.error,
            historyError: state.historyError);
      });
    } catch (e, stackTrace) {
      state = state.copyWith(
        isDiscovering: false,
        error: ErrorHandler.handle(e, stackTrace,
                screen: 'ScanProvider.startDeviceDiscovery')
            .message,
        historyError: state.historyError,
      );
    }
  }

  Future<void> stopDeviceDiscovery() async {
    await _elm327.stopScan();
    state = state.copyWith(
        isDiscovering: false,
        error: state.error,
        historyError: state.historyError);
  }

  /// Connects to a real OBD-II adapter found during discovery.
  /// Returns true on success — callers should only proceed to scan once
  /// this returns true, not assume the connection succeeded just because
  /// the future completed.
  Future<bool> connectToDevice(BluetoothDevice device) async {
    state = state.copyWith(
        isConnectingDevice: true,
        error: null,
        historyError: state.historyError);
    try {
      await stopDeviceDiscovery();
      await _elm327.connect(device);
      state = state.copyWith(
        isConnectingDevice: false,
        isConnected: true,
        connectedDeviceName: _elm327.connectedDeviceName?.isNotEmpty == true
            ? _elm327.connectedDeviceName
            : device.remoteId.str,
        historyError: state.historyError,
      );
      _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((connState) {
        if (connState != BluetoothConnectionState.disconnected) return;
        _connectionSub?.cancel();
        _connectionSub = null;
        state = state.copyWith(
          isConnected: false,
          connectedDeviceName: null,
          error: 'Lost connection to the OBD-II adapter.',
          historyError: state.historyError,
        );
      });
      return true;
    } catch (e, stackTrace) {
      state = state.copyWith(
        isConnectingDevice: false,
        isConnected: false,
        error: ErrorHandler.handle(e, stackTrace,
                screen: 'ScanProvider.connectToDevice')
            .message,
        historyError: state.historyError,
      );
      return false;
    }
  }

  Future<void> disconnectDevice() async {
    // Cancelled before the actual disconnect so the connection-state
    // listener above never sees this voluntary disconnect and shows a
    // spurious "Lost connection" error over what the user asked for.
    await _connectionSub?.cancel();
    _connectionSub = null;
    await _elm327.disconnect();
    state = state.copyWith(
        isConnected: false,
        connectedDeviceName: null,
        error: state.error,
        historyError: state.historyError);
  }

  /// Runs a real diagnostic pass on the connected adapter and saves the
  /// result. The health score is computed from real stored trouble codes —
  /// 10 points, minus 2 per DTC, floored at 0 — never a fixed placeholder.
  Future<void> startScan(String vehicleId, String ownerId) async {
    if (!state.isConnected) {
      state = state.copyWith(
        error: 'Connect to an OBD-II adapter before scanning.',
        historyError: state.historyError,
      );
      return;
    }
    state = state.copyWith(
        isScanning: true, error: null, historyError: state.historyError);

    final scanId = FirebaseFirestore.instance.collection('scans').doc().id;
    final canProceed = await CreditsGateway.charge(
      _ref.read(creditsProvider.notifier),
      userId: ownerId,
      action: 'obd_scan',
      fallbackAmount: CreditsPricing.obdScanCost,
      reason: 'Ran an OBD-II scan',
      relatedEntityId: scanId,
    );
    if (!canProceed) {
      state = state.copyWith(
        isScanning: false,
        error: _ref.read(creditsProvider).error ??
            'You don\'t have enough credits for this.',
        historyError: state.historyError,
      );
      return;
    }

    try {
      final reading = await _elm327.runDiagnostics();
      final healthScore = (10 - (reading.dtcCodes.length * 2)).clamp(0, 10);

      final scan = ScanModel(
        id: scanId,
        ownerId: ownerId,
        vehicleId: vehicleId,
        healthScore: healthScore,
        rawData: reading.toRawData(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('scans')
          .doc(scan.id)
          .set(scan.toFirestore());
      final updatedHistory = [scan, ...state.history];
      state = state.copyWith(
        isScanning: false,
        latestScan: scan,
        history: updatedHistory,
        historyError: state.historyError,
      );
      try {
        await CacheManager.instance.write(
          box: CacheKeys.scansBox,
          key: CacheKeys.scanHistory,
          value: updatedHistory.map((item) => item.toFirestore()).toList(),
        );
      } catch (_) {
        // Ignore — the Firestore write and in-memory state already succeeded.
      }
    } catch (e, stackTrace) {
      // The scan was already charged for above — if it then failed for a
      // system reason (the adapter disconnected mid-read, the save to
      // Firestore failed), that's not the user's fault, so give the
      // credits back rather than leaving them out the cost of a reading
      // the app itself couldn't complete.
      await CreditsGateway.refund(
        _ref.read(creditsProvider.notifier),
        userId: ownerId,
        amount: CreditsPricing.obdScanCost,
        reason: 'Refund: scan did not complete',
        relatedEntityId: scanId,
      );
      state = state.copyWith(
        isScanning: false,
        error: ErrorHandler.handle(e, stackTrace,
                screen: 'ScanProvider.startScan')
            .message,
        historyError: state.historyError,
      );
    }
  }

  Future<void> fetchHistory(String ownerId) async {
    try {
      // Sorted client-side rather than via .orderBy() — combining a
      // where-equality filter with an order-by on a different field needs a
      // composite Firestore index, and one owner's scan count is small
      // enough that sorting here costs nothing.
      final query = await FirebaseFirestore.instance
          .collection('scans')
          .where('ownerId', isEqualTo: ownerId)
          .get();
      final history = query.docs.map(ScanModel.fromFirestore).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      try {
        await CacheManager.instance.write(
          box: CacheKeys.scansBox,
          key: CacheKeys.scanHistory,
          value: history.map((item) => item.toFirestore()).toList(),
        );
      } catch (_) {
        // Ignore — history was already fetched successfully.
      }
      state = state.copyWith(
          history: history, error: state.error, historyError: null);
    } catch (e, stackTrace) {
      state = state.copyWith(
        error: state.error,
        historyError: ErrorHandler.handle(e, stackTrace,
                screen: 'ScanProvider.fetchHistory')
            .message,
      );
    }
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    // Fire-and-forget cleanup — must never let an unhandled rejection escape
    // a dispose() call.
    _elm327.disconnect().catchError((_) {});
    super.dispose();
  }
}

final scanProvider =
    StateNotifierProvider<ScanNotifier, ScanState>((ref) => ScanNotifier(ref));

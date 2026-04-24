import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/theme/app_colors.dart';
import 'scan_results_screen.dart';
import 'scan_no_faults_screen.dart';

class ScanConnectingScreen extends StatefulWidget {
  const ScanConnectingScreen({super.key});

  @override
  State<ScanConnectingScreen> createState() =>
      _ScanConnectingScreenState();
}

// ── SCAN PHASES ──────────────────────────────────────────────
enum _Phase {
  checkingBt,     // 0 — checking bluetooth is on
  scanning,       // 1 — scanning for BLE devices
  selectAdapter,  // 2 — showing found adapters, waiting for tap
  connecting,     // 3 — connecting to chosen adapter
  readingCodes,   // 4 — sending OBD commands, reading DTCs
  done,           // 5 — finished
  error,          // 6 — something went wrong
}

class _ScanConnectingScreenState
    extends State<ScanConnectingScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _ringController;
  late AnimationController _needleController;
  late Animation<double> _ring1, _ring2, _ring3;

  // State
  _Phase _phase = _Phase.checkingBt;
  String _statusText = 'Checking Bluetooth…';
  String _subText = 'Making sure your device is ready.';
  String? _errorText;

  // BT scanning
  final List<ScanResult> _foundDevices = [];
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _obdChar;
  final List<String> _dtcCodes = [];
  bool _cancelled = false;
  StreamSubscription? _scanSub;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _ring1 = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ringController,
            curve: const Interval(0.0, 0.6,
                curve: Curves.easeOut)));
    _ring2 = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ringController,
            curve: const Interval(0.2, 0.8,
                curve: Curves.easeOut)));
    _ring3 = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ringController,
            curve: const Interval(0.4, 1.0,
                curve: Curves.easeOut)));

    _start();
  }

  Future<void> _start() async {
    // Phase 0: Check BT
    _setPhase(_Phase.checkingBt,
        'Checking Bluetooth…', 'Making sure your device is ready.');
    await Future.delayed(const Duration(milliseconds: 800));

    if (_cancelled) return;

    try {
      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        _setError(
            'Bluetooth is off.\nPlease enable Bluetooth and try again.');
        return;
      }
    } catch (_) {
      _setError('Could not check Bluetooth state.');
      return;
    }

    if (_cancelled) return;

    // Phase 1: Scan for devices
    _setPhase(_Phase.scanning,
        'Searching for OBD adapters…',
        'Make sure your ELM327 is plugged into the OBD port.');

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted || _cancelled) return;
      for (final r in results) {
        if (!_foundDevices
            .any((d) => d.device.remoteId == r.device.remoteId)) {
          setState(() {
            _foundDevices.add(r);
            // Auto-switch to selectAdapter phase when first device found
            if (_phase == _Phase.scanning) {
              _phase = _Phase.selectAdapter;
              _statusText = 'Select your OBD adapter';
              _subText =
                  'Tap your ELM327 adapter from the list below.';
            }
          });
        }
      }
    });

    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15));

    if (_cancelled) return;
    await _scanSub?.cancel();

    // If no devices found after scan
    if (_foundDevices.isEmpty && mounted && !_cancelled) {
      _setError(
          'No Bluetooth devices found.\nMake sure your ELM327 adapter is plugged in and powered on.');
    }
  }

  void _onSelectDevice(BluetoothDevice device) async {
    if (_cancelled) return;
    setState(() => _selectedDevice = device);

    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();

    // Phase 3: Connect
    _setPhase(_Phase.connecting,
        'Connecting to ${device.platformName.isNotEmpty ? device.platformName : 'adapter'}…',
        'Establishing OBD-II session.');

    try {
      await device.connect(
          timeout: const Duration(seconds: 15));

      if (_cancelled) return;

      // Discover services
      _setPhase(_Phase.connecting,
          'Establishing OBD session…',
          'Discovering services on the adapter.');

      final services = await device.discoverServices();

      // Find the OBD characteristic
      for (final s in services) {
        for (final c in s.characteristics) {
          final uuid = c.uuid.toString().toLowerCase();
          if (uuid.contains('ffe1') ||
              uuid.contains('fff1') ||
              uuid.contains('be95')) {
            _obdChar = c;
            break;
          }
        }
        if (_obdChar != null) break;
      }

      // Fallback: first writable + notify characteristic
      if (_obdChar == null) {
        for (final s in services) {
          for (final c in s.characteristics) {
            if (c.properties.write && c.properties.notify) {
              _obdChar = c;
              break;
            }
          }
          if (_obdChar != null) break;
        }
      }

      if (_obdChar == null || _cancelled) {
        _setError(
            'OBD characteristic not found.\nThis adapter may not be compatible.');
        return;
      }

      // Phase 4: Read codes
      _setPhase(_Phase.readingCodes,
          'Reading fault codes…',
          'Scanning all vehicle systems for DTCs.');

      await _obdChar!.setNotifyValue(true);

      // Init ELM327
      await _sendCmd('ATZ\r');
      await Future.delayed(const Duration(milliseconds: 500));
      await _sendCmd('ATE0\r');
      await Future.delayed(const Duration(milliseconds: 200));
      await _sendCmd('ATH0\r');
      await Future.delayed(const Duration(milliseconds: 200));
      await _sendCmd('ATSP0\r');
      await Future.delayed(const Duration(milliseconds: 500));

      // Request stored DTCs (Mode 03)
      final response = await _readCmd('03\r');

      if (_cancelled) return;

      final codes = _parseDTCs(response);
      for (final code in codes) {
        if (_cancelled || !mounted) break;
        setState(() => _dtcCodes.add(code));
        // Small delay between each code so needle visibly jumps
        await Future.delayed(const Duration(milliseconds: 400));
      }

      if (_cancelled || !mounted) return;

      // Phase 5: Done
      _setPhase(_Phase.done,
          'Scan complete.',
          _dtcCodes.isEmpty
              ? 'No fault codes detected.'
              : '${_dtcCodes.length} fault code${_dtcCodes.length > 1 ? 's' : ''} found.');

      await Future.delayed(const Duration(milliseconds: 800));
      await device.disconnect().catchError((_) {});

      if (!mounted || _cancelled) return;

      final navigator = Navigator.of(context);
      if (_dtcCodes.isEmpty) {
        navigator.pushReplacement(
          MaterialPageRoute(
              builder: (_) => const ScanNoFaultsScreen()),
        );
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(
              builder: (_) =>
                  ScanResultsScreen(dtcCodes: _dtcCodes)),
        );
      }
    } catch (e) {
      if (!_cancelled && mounted) {
        _setError(
            'Connection failed.\nMake sure the adapter is on and try again.');
      }
    }
  }

  Future<void> _sendCmd(String cmd) async {
    await _obdChar!.write(cmd.codeUnits, withoutResponse: false);
  }

  Future<String> _readCmd(String cmd) async {
    final completer = Completer<String>();
    final buf = StringBuffer();

    final sub = _obdChar!.lastValueStream.listen((v) {
      buf.write(String.fromCharCodes(v));
      if (buf.toString().contains('>') &&
          !completer.isCompleted) {
        completer.complete(buf.toString());
      }
    });

    await _sendCmd(cmd);
    final result = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => '');
    await sub.cancel();
    return result;
  }

  List<String> _parseDTCs(String response) {
    final codes = <String>[];
    final cleaned =
        response.replaceAll(RegExp(r'[^0-9A-Fa-f\s]'), ' ').trim();
    final bytes = cleaned
        .split(RegExp(r'\s+'))
        .where((s) => s.length == 2)
        .toList();

    for (int i = 0; i + 1 < bytes.length; i += 2) {
      final first = int.tryParse(bytes[i], radix: 16) ?? 0;
      final second =
          int.tryParse(bytes[i + 1], radix: 16) ?? 0;
      if (first == 0 && second == 0) continue;
      final prefix =
          ['P', 'C', 'B', 'U'][(first >> 6) & 0x03];
      final num = ((first & 0x3F) << 8) | second;
      codes.add(
          '$prefix${num.toRadixString(16).padLeft(4, '0').toUpperCase()}');
    }
    return codes;
  }

  void _setPhase(_Phase phase, String status, String sub) {
    if (!mounted) return;
    setState(() {
      _phase = phase;
      _statusText = status;
      _subText = sub;
    });
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.error;
      _errorText = msg;
    });
    _ringController.stop();
  }

  bool _isLikelyOBD(String name) {
    final n = name.toLowerCase();
    return n.contains('elm') ||
        n.contains('obd') ||
        n.contains('vlink') ||
        n.contains('carista') ||
        n.contains('icar') ||
        n.contains('obdii');
  }

  @override
  void dispose() {
    _cancelled = true;
    _scanSub?.cancel();
    FlutterBluePlus.stopScan().catchError((_) {});
    _selectedDevice?.disconnect().catchError((_) {});
    _ringController.dispose();
    _needleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildPhasePill(),
            const SizedBox(height: 24),
            // Gauge — static until readingCodes phase
            AnimatedBuilder(
              animation: Listenable.merge(
                  [_ring1, _ring2, _ring3]),
              builder: (_, __) => _buildGauge(),
            ),
            const SizedBox(height: 20),
            Text(_statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter')),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(_subText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontFamily: 'Inter')),
            ),
            if (_phase == _Phase.error && _errorText != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40),
                child: Text(_errorText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.critical,
                        height: 1.5,
                        fontFamily: 'Inter')),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.border),
                  ),
                  child: const Text('Go Back',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter')),
                ),
              ),
            ],
            // Device list — shown during selectAdapter phase
            if (_phase == _Phase.selectAdapter &&
                _foundDevices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Expanded(child: _buildDeviceList()),
            ] else
              const Spacer(),
            // Step progress
            if (_phase != _Phase.selectAdapter &&
                _phase != _Phase.error)
              _buildStepProgress(),
            const SizedBox(height: 16),
            if (_phase != _Phase.done &&
                _phase != _Phase.error)
              GestureDetector(
                onTap: () {
                  _cancelled = true;
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                        fontFamily: 'Inter')),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Text('Diagnostic Scan',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _phase == _Phase.error
                  ? AppColors.criticalBg
                  : _phase == _Phase.done
                      ? AppColors.advisoryBg
                      : AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _phase == _Phase.error
                      ? AppColors.criticalBorder
                      : _phase == _Phase.done
                          ? AppColors.advisoryBorder
                          : AppColors.primaryBorder),
            ),
            child: Text(
              _phase == _Phase.error
                  ? 'Error'
                  : _phase == _Phase.done
                      ? 'Complete'
                      : 'Scanning…',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _phase == _Phase.error
                      ? AppColors.critical
                      : _phase == _Phase.done
                          ? AppColors.advisory
                          : AppColors.primary,
                  fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhasePill() {
    final label = _selectedDevice != null
        ? _selectedDevice!.platformName.isNotEmpty
            ? _selectedDevice!.platformName
            : 'ELM327 Adapter'
        : 'Searching for adapter…';

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter')),
    );
  }

  Widget _buildGauge() {
    // Needle only active during readingCodes phase
    final isReading = _phase == _Phase.readingCodes;
    final faultCount = _dtcCodes.length;

    return SizedBox(
      width: 220, height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding rings
          _Ring(scale: _ring3.value,
              opacity: 1 - _ring3.value),
          _Ring(scale: _ring2.value,
              opacity: 1 - _ring2.value),
          _Ring(scale: _ring1.value,
              opacity: 1 - _ring1.value),
          // Gauge
          CustomPaint(
            size: const Size(200, 200),
            painter: _FaultGaugePainter(
              faultCount: isReading ? faultCount : 0,
              maxFaults: 10,
              isActive: isReading,
            ),
          ),
          // Center display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              if (isReading) ...[
                Text(
                  '$faultCount',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: faultCount == 0
                        ? AppColors.textTertiary
                        : AppColors.critical,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  faultCount == 0
                      ? 'checking…'
                      : faultCount == 1
                          ? 'fault found'
                          : 'faults found',
                  style: TextStyle(
                      fontSize: 11,
                      color: faultCount == 0
                          ? AppColors.textTertiary
                          : AppColors.critical,
                      fontFamily: 'Inter'),
                ),
              ] else if (_phase == _Phase.done) ...[
                Icon(
                  _dtcCodes.isEmpty
                      ? Icons.check_circle_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: _dtcCodes.isEmpty
                      ? AppColors.advisory
                      : AppColors.critical,
                  size: 40,
                ),
              ] else ...[
                const SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    final obdDevices = _foundDevices
        .where((r) => _isLikelyOBD(r.device.platformName))
        .toList();
    final otherDevices = _foundDevices
        .where((r) => !_isLikelyOBD(r.device.platformName))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (obdDevices.isNotEmpty) ...[
          const _SectionLabel(label: 'OBD ADAPTERS DETECTED'),
          const SizedBox(height: 8),
          ...obdDevices.map((r) => _DeviceTile(
                result: r,
                isOBD: true,
                onTap: () => _onSelectDevice(r.device),
              )),
          const SizedBox(height: 12),
        ],
        if (otherDevices.isNotEmpty) ...[
          const _SectionLabel(label: 'OTHER NEARBY DEVICES'),
          const SizedBox(height: 8),
          ...otherDevices.map((r) => _DeviceTile(
                result: r,
                isOBD: false,
                onTap: () => _onSelectDevice(r.device),
              )),
        ],
      ],
    );
  }

  Widget _buildStepProgress() {
    final steps = [
      'Check Bluetooth',
      'Find OBD adapter',
      'Connect & initialise',
      'Read fault codes',
    ];
    final currentStep = _phase.index.clamp(0, 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final idx = e.key;
          final label = e.value;
          final isDone = idx < currentStep;
          final isActive = idx == currentStep;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.advisory
                        : isActive
                            ? AppColors.primary
                            : AppColors.surface,
                    border: Border.all(
                        color: isDone
                            ? AppColors.advisory
                            : isActive
                                ? AppColors.primary
                                : AppColors.border),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 12)
                        : isActive
                            ? const SizedBox(
                                width: 10, height: 10,
                                child:
                                    CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 1.5))
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isDone
                            ? AppColors.advisory
                            : isActive
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                        fontFamily: 'Inter')),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── FAULT GAUGE PAINTER ──────────────────────────────────────
class _FaultGaugePainter extends CustomPainter {
  final int faultCount, maxFaults;
  final bool isActive;

  const _FaultGaugePainter({
    required this.faultCount,
    required this.maxFaults,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.65;
    const sweepAngle = math.pi * 1.22;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFF1E1E24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // Active arc
    final progress =
        isActive ? (faultCount / maxFaults).clamp(0.0, 1.0) : 0.0;
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle * progress, false,
        Paint()
          ..color = faultCount <= 3
              ? AppColors.moderate
              : AppColors.critical
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
    }

    // Ticks 0–10
    final tickPaint = Paint()
      ..color = const Color(0xFF5E5E6A)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 10; i++) {
      final angle = startAngle + (sweepAngle / 10) * i;
      final isMajor = i % 2 == 0;
      final outer = Offset(
          center.dx + (radius + 2) * math.cos(angle),
          center.dy + (radius + 2) * math.sin(angle));
      final inner = Offset(
          center.dx +
              (radius - (isMajor ? 12 : 7)) * math.cos(angle),
          center.dy +
              (radius - (isMajor ? 12 : 7)) * math.sin(angle));
      canvas.drawLine(inner, outer, tickPaint);

      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(
              text: '$i',
              style: const TextStyle(
                  color: Color(0xFF5E5E6A),
                  fontSize: 9,
                  fontWeight: FontWeight.w500)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
            canvas,
            Offset(
                center.dx +
                    (radius - 26) * math.cos(angle) -
                    tp.width / 2,
                center.dy +
                    (radius - 26) * math.sin(angle) -
                    tp.height / 2));
      }
    }

    // Needle
    final needleAngle =
        startAngle + sweepAngle * progress;
    final needleEnd = Offset(
        center.dx + (radius - 28) * math.cos(needleAngle),
        center.dy + (radius - 28) * math.sin(needleAngle));
    final needleColor =
        isActive && faultCount > 0
            ? faultCount <= 3
                ? AppColors.moderate
                : AppColors.critical
            : AppColors.primary;

    canvas.drawLine(center, needleEnd,
        Paint()
          ..color = needleColor
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(
        center, 8, Paint()..color = needleColor);
    canvas.drawCircle(center, 4,
        Paint()..color = const Color(0xFF0A0A0B));
  }

  @override
  bool shouldRepaint(_FaultGaugePainter old) =>
      old.faultCount != faultCount ||
      old.isActive != isActive;
}

// ── SUPPORTING WIDGETS ────────────────────────────────────────
class _Ring extends StatelessWidget {
  final double scale, opacity;
  const _Ring({required this.scale, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: 220, height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
            fontFamily: 'Inter'));
  }
}

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  final bool isOBD;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.result,
    required this.isOBD,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : 'Unknown Device';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isOBD
                  ? AppColors.primaryBorder
                  : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isOBD
                    ? AppColors.primarySubtle
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isOBD
                        ? AppColors.primaryBorder
                        : AppColors.border),
              ),
              child: Icon(
                isOBD
                    ? Icons.power_outlined
                    : Icons.bluetooth_rounded,
                color: isOBD
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter')),
                  const SizedBox(height: 2),
                  Text(
                    result.device.remoteId.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            if (isOBD)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('TAP TO USE',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Inter')),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

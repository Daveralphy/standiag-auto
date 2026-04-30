import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import 'scan_results_screen.dart';
import 'scan_no_faults_screen.dart';

class ScanConnectingScreen extends StatefulWidget {
  const ScanConnectingScreen({super.key});

  @override
  State<ScanConnectingScreen> createState() =>
      _ScanConnectingScreenState();
}

// ── SCAN STEPS ───────────────────────────────────────────────
enum _Step {
  bluetooth,      // 0 — Enable Bluetooth
  odbAdapter,     // 1 — Find & select OBD adapter
  scanning,       // 2 — Scan for fault codes
  completed,      // 3 — Scan finished
}

class _ScanConnectingScreenState extends State<ScanConnectingScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _needleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // State
  _Step _currentStep = _Step.bluetooth;
  _Step _completedUpTo = _Step.bluetooth;
  bool _cancelled = false;
  bool _bluetoothOn = false;
  int _faultCount = 0;
  String? _errorText;

  // BT scanning
  final List<ScanResult> _foundAdapters = [];
  BluetoothDevice? _selectedAdapter;
  BluetoothCharacteristic? _obdChar;
  final List<String> _dtcCodes = [];
  StreamSubscription? _scanSub;
  StreamSubscription? _adapterStateListener;

  @override
  void initState() {
    super.initState();

    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Pulse animation for meter
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
          parent: _pulseController, curve: Curves.easeInOut),
    );

    _init();
  }

  Future<void> _init() async {
    // Check Bluetooth permission first
    final btPermission = await Permission.bluetoothScan.request();
    if (!btPermission.isGranted && mounted && !_cancelled) {
      _showError('Bluetooth permissions are required');
      return;
    }

    // Check if Bluetooth is on
    _checkBluetoothStatus();

    // Listen for Bluetooth state changes
    _adapterStateListener =
        FlutterBluePlus.adapterState.listen((state) {
      if (mounted && !_cancelled) {
        setState(() {
          _bluetoothOn = state == BluetoothAdapterState.on;
        });
      }
    });
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      if (mounted && !_cancelled) {
        setState(() {
          _bluetoothOn = state == BluetoothAdapterState.on;
        });
      }
    } catch (_) {
      if (mounted && !_cancelled) {
        _showError('Could not check Bluetooth');
      }
    }
  }

  Future<void> _enableBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
      // Bluetooth should be on now, wait a bit for state update
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && !_cancelled && _bluetoothOn) {
        _advanceStep();
      }
    } catch (_) {
      if (mounted && !_cancelled) {
        _showError('Could not enable Bluetooth');
      }
    }
  }

  Future<void> _startAdapterSearch() async {
    setState(() {
      _currentStep = _Step.odbAdapter;
    });

    try {
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        if (!mounted || _cancelled) return;

        for (final result in results) {
          final isOBD = _isLikelyOBD(result.device.platformName);
          if (isOBD &&
              !_foundAdapters
                  .any((d) => d.device.remoteId == result.device.remoteId)) {
            setState(() {
              _foundAdapters.add(result);
            });
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
      );

      if (_cancelled) return;

      // Stop scanning after timeout
      await _scanSub?.cancel();

      if (!mounted || _cancelled) return;

      if (_foundAdapters.isEmpty) {
        _showError('No OBD adapters found.\nMake sure your adapter is powered on.');
      }
    } catch (e) {
      if (!_cancelled && mounted) {
        _showError('Scan failed. Please try again.');
      }
    }
  }

  Future<void> _selectAdapter(ScanResult adapterResult) async {
    if (_cancelled) return;

    setState(() => _selectedAdapter = adapterResult.device);

    try {
      // Stop scanning
      await FlutterBluePlus.stopScan().catchError((_) {});
      await _scanSub?.cancel();

      // Connect to adapter
      await adapterResult.device.connect(
        timeout: const Duration(seconds: 15),
      );

      if (_cancelled || !mounted) return;

      // Discover services
      final services =
          await adapterResult.device.discoverServices();

      // Find OBD characteristic
      for (final service in services) {
        for (final char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          // Common OBD characteristic UUIDs
          if (uuid.contains('ffe1') ||
              uuid.contains('fff1') ||
              uuid.contains('be95') ||
              (char.properties.write && char.properties.notify)) {
            _obdChar = char;
            break;
          }
        }
        if (_obdChar != null) break;
      }

      if (_obdChar == null || _cancelled) {
        _showError('OBD characteristic not found');
        return;
      }

      if (mounted && !_cancelled) {
        _advanceStep(); // Move to scanning
      }
    } catch (e) {
      if (!_cancelled && mounted) {
        _showError('Connection failed. Try again.');
      }
      try {
        await _selectedAdapter?.disconnect();
      } catch (_) {}
    }
  }

  Future<void> _startScanning() async {
    setState(() {
      _currentStep = _Step.scanning;
    });

    try {
      await _obdChar!.setNotifyValue(true);

      // Initialize ELM327
      await _sendCmd('ATZ\r');
      await Future.delayed(const Duration(milliseconds: 500));
      await _sendCmd('ATE0\r');
      await Future.delayed(const Duration(milliseconds: 200));
      await _sendCmd('ATH0\r');
      await Future.delayed(const Duration(milliseconds: 200));
      await _sendCmd('ATSP0\r');
      await Future.delayed(const Duration(milliseconds: 500));

      if (_cancelled) return;

      // Request stored DTCs (Mode 03)
      final response = await _readCmd('03\r');
      if (_cancelled) return;

      final codes = _parseDTCs(response);

      // Animate needle as codes are found
      for (int i = 0; i < codes.length && !_cancelled; i++) {
        if (mounted) {
          setState(() {
            _dtcCodes.add(codes[i]);
            _faultCount = _dtcCodes.length;
          });
        }
        await Future.delayed(const Duration(milliseconds: 400));
      }

      if (_cancelled || !mounted) return;

      // Mark scanning as completed
      setState(() {
        _completedUpTo = _Step.scanning;
      });

      // Move to completed
      await Future.delayed(const Duration(milliseconds: 400));
      _advanceStep();
    } catch (e) {
      if (!_cancelled && mounted) {
        _showError('Scanning failed. Try again.');
      }
    }
  }

  Future<void> _finishScan() async {
    try {
      await _selectedAdapter?.disconnect().catchError((_) {});
    } catch (_) {}

    if (!mounted || _cancelled) return;

    setState(() {
      _currentStep = _Step.completed;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted || _cancelled) return;

    final navigator = Navigator.of(context);
    if (_dtcCodes.isEmpty) {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ScanNoFaultsScreen(),
        ),
      );
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              ScanResultsScreen(dtcCodes: _dtcCodes),
        ),
      );
    }
  }

  void _advanceStep() {
    if (_currentStep == _Step.bluetooth && _bluetoothOn) {
      _startAdapterSearch();
    } else if (_currentStep == _Step.odbAdapter &&
        _selectedAdapter != null) {
      _selectAdapter(
        _foundAdapters.firstWhere(
          (a) => a.device == _selectedAdapter,
        ),
      );
    } else if (_currentStep == _Step.scanning) {
      _startScanning();
    } else if (_currentStep == _Step.completed) {
      _finishScan();
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
      onTimeout: () => '',
    );
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
      final second = int.tryParse(bytes[i + 1], radix: 16) ?? 0;
      if (first == 0 && second == 0) continue;
      final prefix = ['P', 'C', 'B', 'U'][(first >> 6) & 0x03];
      final num = ((first & 0x3F) << 8) | second;
      codes.add(
          '$prefix${num.toRadixString(16).padLeft(4, '0').toUpperCase()}');
    }
    return codes;
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

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _errorText = msg;
    });
  }

  @override
  void dispose() {
    _cancelled = true;
    _scanSub?.cancel();
    _adapterStateListener?.cancel();
    FlutterBluePlus.stopScan().catchError((_) {});
    _selectedAdapter?.disconnect().catchError((_) {});
    _needleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Diagnostic Scan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  // Help icon (?)
                  GestureDetector(
                    onTap: () => _showHelpOverlay(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.textTertiary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Meter (Static at top) ─────────────────────
            _buildMeter(),
            const SizedBox(height: 32),

            // ── Progress Steps ────────────────────────────
            _buildProgressSteps(),
            const SizedBox(height: 28),

            // ── Status Text ───────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_errorText != null) ...[
                    Text(
                      'Error',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.critical,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ] else if (_currentStep ==
                      _Step.bluetooth) ...[
                    if (!_bluetoothOn) ...[
                      const Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bluetooth is required to connect\nto your OBD adapter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _enableBluetooth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Enable Bluetooth',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bluetooth ready',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ]
                  ] else if (_currentStep ==
                      _Step.odbAdapter) ...[
                    if (_foundAdapters.isEmpty)
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      )
                    else ...[
                      const Text(
                        'Select your adapter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          itemCount: _foundAdapters.length,
                          itemBuilder: (_, i) {
                            final adapter =
                                _foundAdapters[i];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    _selectAdapter(adapter),
                                child: Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius
                                            .circular(12),
                                    border: Border.all(
                                      color:
                                          AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .bluetooth_rounded,
                                        color: AppColors
                                            .textTertiary,
                                        size: 18,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Text(
                                          adapter
                                              .device
                                              .platformName,
                                          style:
                                              const TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight
                                                    .w500,
                                            color: AppColors
                                                .textPrimary,
                                            fontFamily:
                                                'Inter',
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons
                                            .chevron_right_rounded,
                                        color: AppColors
                                            .textTertiary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                  ] else if (_currentStep ==
                      _Step.scanning) ...[
                    Text(
                      '$_faultCount',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: _faultCount == 0
                            ? AppColors.textTertiary
                            : AppColors.critical,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _faultCount == 0
                          ? 'scanning…'
                          : _faultCount == 1
                              ? 'fault found'
                              : 'faults found',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _faultCount == 0
                            ? AppColors.textTertiary
                            : AppColors.critical,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ] else if (_currentStep ==
                      _Step.completed) ...[
                    Icon(
                      Icons.check_circle_rounded,
                      color: _dtcCodes.isEmpty
                          ? AppColors.advisory
                          : AppColors.textTertiary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan complete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dtcCodes.isEmpty
                          ? 'No faults found'
                          : '${_dtcCodes.length} fault${_dtcCodes.length > 1 ? 's' : ''} detected',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Cancel button ─────────────────────────────
            if (_currentStep != _Step.completed &&
                _errorText == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    _cancelled = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              )
            else if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMeter() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer ring
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary
                          .withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary
                        .withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
              ),
              // Gauge painter
              CustomPaint(
                size: const Size(200, 200),
                painter: _GaugePainter(needlePosition: _faultCount / 10.0),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  if (_currentStep == _Step.scanning) ...[
                    Text(
                      '$_faultCount',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _faultCount == 0
                            ? AppColors.textTertiary
                            : AppColors.critical,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ] else if (_currentStep ==
                      _Step.completed) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.advisory,
                      size: 32,
                    ),
                  ]
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSteps() {
    const steps = [
      'Bluetooth',
      'ODB Adapter',
      'Scanning',
      'Completed',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Progress line with numbered circles ON the line
          SizedBox(
            height: 32,
            child: Row(
              children: [
                for (int i = 0; i < steps.length; i++) ...[
                  // Step circle
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _Step.values.indexOf(_completedUpTo) +
                                  1
                              ? AppColors.primary
                              : i == _Step.values.indexOf(_currentStep)
                                  ? AppColors.primary
                                  : AppColors.surface,
                          border: Border.all(
                            color: i <=
                                    _Step.values
                                        .indexOf(_currentStep)
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: i <
                                  _Step.values.indexOf(
                                          _completedUpTo) +
                                      1
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: i ==
                                            _Step.values.indexOf(
                                                _currentStep)
                                        ? Colors.white
                                        : AppColors
                                            .textTertiary,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  // Connecting line
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i <
                                _Step.values.indexOf(
                                        _completedUpTo) +
                                    1
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Step labels below
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: Text(
                    steps[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: i <=
                              _Step.values
                                  .indexOf(_currentStep)
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: i <=
                              _Step.values
                                  .indexOf(_currentStep)
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpOverlay() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.background,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'How to connect',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Plug in your OBD-II adapter into your car\'s OBD port (usually under the dashboard).\n\n'
                '2. Make sure your adapter is powered on (usually has an LED indicator).\n\n'
                '3. Your phone will automatically find the adapter in the list.\n\n'
                '4. Tap to select it and the scan will begin.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Got it',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── GAUGE PAINTER ───────────────────────────────────────────
class _GaugePainter extends CustomPainter {
  final double needlePosition; // 0.0 to 1.0

  const _GaugePainter({required this.needlePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.65;
    const sweepAngle = math.pi * 1.22;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = const Color(0xFF1E1E24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // Tick marks + labels (0–10)
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
        startAngle + sweepAngle * needlePosition;
    final needleEnd = Offset(
        center.dx + (radius - 30) * math.cos(needleAngle),
        center.dy + (radius - 30) * math.sin(needleAngle));

    canvas.drawLine(
        center,
        needleEnd,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    canvas.drawCircle(
        center, 6, Paint()..color = AppColors.primary);
    canvas.drawCircle(center, 3,
        Paint()..color = const Color(0xFF0A0A0B));
  }

  @override
  bool shouldRepaint(_GaugePainter old) => false;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/providers/vehicle_provider.dart';
import '../onboarding/obd_guide_screen.dart';
import '../history/scan_history_screen.dart';
import 'scan_connecting_screen.dart';

class ScanIdleScreen extends ConsumerStatefulWidget {
  const ScanIdleScreen({super.key});

  @override
  ConsumerState<ScanIdleScreen> createState() =>
      _ScanIdleScreenState();
}

class _ScanIdleScreenState extends ConsumerState<ScanIdleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _btEnabled = false;
  bool _checkingBt = true;

  @override
  void initState() {
    super.initState();
    // Only the outer ring pulses — needle is completely static
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
          parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkBluetooth();
  }

  Future<void> _checkBluetooth() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      if (mounted) {
        setState(() {
          _btEnabled = state == BluetoothAdapterState.on;
          _checkingBt = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checkingBt = false);
    }
    FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(
            () => _btEnabled = state == BluetoothAdapterState.on);
      }
    });
  }

  Future<void> _onTapScan() async {
    // Request BT + location permissions
    final results = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    final permanentlyDenied = results.values
        .any((s) => s == PermissionStatus.permanentlyDenied);

    if (permanentlyDenied) {
      if (!mounted) return;
      _showSnack(
          'Bluetooth permissions denied. Please enable in Settings.');
      await openAppSettings();
      return;
    }

    final anyDenied = results.values
        .any((s) => s == PermissionStatus.denied);

    if (anyDenied) {
      if (!mounted) return;
      _showSnack('Bluetooth and location permissions are required.');
      return;
    }

    if (!_btEnabled) {
      if (!mounted) return;
      _showSnack('Please enable Bluetooth to scan.');
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const ScanConnectingScreen()),
    );
  }


  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 13)),
      backgroundColor: AppColors.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeVehicleAsync = ref.watch(activeVehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Full-width Header ────────────────────────
            activeVehicleAsync.when(
              data: (v) => _buildHeader(v != null ? '${v['make']} ${v['model']} ${v['year']}' : ''),
              loading: () => _buildHeader(''),
              error: (_, __) => _buildHeader(''),
            ),
            // ── Scrollable Content ───────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    activeVehicleAsync.when(
                      data: (v) => _buildVehiclePill(v != null
                          ? '${v['make']} ${v['model']} ${v['year']}'
                          : 'No vehicle — add one first'),
                      loading: () => _buildVehiclePill('Loading...'),
                      error: (_, __) =>
                          _buildVehiclePill('No vehicle'),
                    ),
                    const SizedBox(height: 32),
                    _buildGauge(),
                    const SizedBox(height: 16),
                    const Text('Ready to diagnose.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 6),
                    const Text(
                      'Plug in your OBD-II adapter, make sure\nBluetooth is on, then tap the gauge.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFBBBBBB),
                          height: 1.5,
                          fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 24),
                    _buildStatusCards(),
                    const SizedBox(height: 20),
                    _buildHelperCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String vehicleName) {
    return AppHeader(
      title: 'Ready to scan.',
      subtitle: vehicleName.isNotEmpty ? vehicleName : 'No vehicle selected',
      titleHasPrimary: true,
      action: const Icon(Icons.history_rounded, color: AppColors.textPrimary, size: 20),
      onActionTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanHistoryScreen())),
    );
  }
  Widget _buildVehiclePill(String label) {
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
              color: Color(0xFFBBBBBB),
              fontFamily: 'Inter')),
    );
  }

  Widget _buildGauge() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTapScan,
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing outer ring only
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 260, height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary
                              .withValues(alpha: 0.08),
                          width: 1),
                    ),
                  ),
                ),
                Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 0.12),
                        width: 1),
                  ),
                ),
                // STATIC gauge — needle at 0, no animation
                CustomPaint(
                  size: const Size(200, 200),
                  painter:
                      _StaticGaugePainter(needlePosition: 0.0),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'TAP TO SCAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary
                            .withValues(alpha: 0.85),
                        letterSpacing: 2,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCards() {
    return Column(
      children: [
        _StatusRow(
          icon: Icons.bluetooth,
          iconColor: AppColors.bluetooth,
          iconBg: AppColors.bluetooth.withValues(alpha: 0.12),
          title: 'Bluetooth',
          subtitle: _checkingBt
              ? 'Checking...'
              : _btEnabled
                  ? 'Enabled  •  Ready'
                  : 'Disabled  •  Tap to enable',
          dotColor:
              _btEnabled ? AppColors.advisory : AppColors.moderate,
          onTap: _btEnabled
              ? null
              : () async => await FlutterBluePlus.turnOn(),
        ),
        const SizedBox(height: 10),
        const _StatusRow(
          icon: Icons.power_outlined,
          iconColor: AppColors.textSecondary,
          iconBg: AppColors.surface,
          title: 'OBD-II Adapter',
          subtitle: 'Not connected  •  Plug in to begin',
          dotColor: AppColors.moderate,
        ),
      ],
    );
  }

  Widget _buildHelperCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.power_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('First time scanning?',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 4),
                const Text(
                  'You need an ELM327 Bluetooth adapter. They cost under ₦5,000 and work on any car with an OBD-II port (most cars after 2000).',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBBBBBB),
                      height: 1.5,
                      fontFamily: 'Inter'),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const OBDGuideScreen()),
                  ),
                  child: const Text('Where to buy one →',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFamily: 'Inter')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── STATIC GAUGE PAINTER ─────────────────────────────────────
// Needle is fixed at position 0 — never moves on idle screen
class _StaticGaugePainter extends CustomPainter {
  final double needlePosition; // Always 0.0 on idle

  const _StaticGaugePainter({required this.needlePosition});

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

    // Needle — fixed at startAngle (position 0)
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
  bool shouldRepaint(_StaticGaugePainter old) => false;
}

// ── STATUS ROW ───────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg, dotColor;
  final String title, subtitle;
  final VoidCallback? onTap;

  const _StatusRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.dotColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter')),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBBBBBB),
                          fontFamily: 'Inter')),
                ],
              ),
            ),
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: dotColor.withValues(alpha: 0.5),
                    blurRadius: 6)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
















import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/providers/vehicle_provider.dart';
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
  }

  Future<void> _onTapScan() async {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const ScanConnectingScreen()),
    );
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
            // ── Centered Gauge + Button ──────────────────
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGauge(),
                    const SizedBox(height: 32),
                    const Text('Ready to diagnose',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 8),
                    const Text(
                      'Plug in your OBD-II adapter\nand tap to start scanning',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBBBBBB),
                          height: 1.5,
                          fontFamily: 'Inter'),
                    ),
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















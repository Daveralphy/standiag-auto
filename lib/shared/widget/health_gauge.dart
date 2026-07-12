// Shared OBD diagnostic widgets — the health-score gauge and the adapter
// connection pill used on both the CarOwner and Mechanic scan screens.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Circular dial matching the design's OBD health-score gauge.
/// [score] is on a 0-10 scale (see ScanModel.healthScore); null means no
/// scan has run yet, which renders the needle at rest with a "—" readout —
/// this is the design's own idle state, not a fabricated placeholder.
class HealthGauge extends StatelessWidget {
  final int? score;
  final String? label;
  final double size;

  const HealthGauge({super.key, this.score, this.label, this.size = 220});

  @override
  Widget build(BuildContext context) {
    final fraction = score == null ? null : (score!.clamp(0, 10)) / 10;
    return SizedBox(
      width: size,
      height: size * 0.66,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 0.66),
            painter: _HealthGaugePainter(fraction: fraction),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score == null ? '—' : '$score',
                  style: AppTypography.healthScore,
                ),
                const SizedBox(height: 2),
                Text(
                  label ?? (score == null ? 'No scan yet' : 'HEALTH SCORE'),
                  style: AppTypography.captionSmall.copyWith(
                    letterSpacing: 1,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthGaugePainter extends CustomPainter {
  final double? fraction;
  const _HealthGaugePainter({required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = math.pi;
    const totalSweep = math.pi;

    final trackFaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x0DE8281E);
    canvas.drawArc(rect, startAngle, totalSweep, false, trackFaint);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1A1A1A);
    canvas.drawArc(rect, startAngle, totalSweep, false, track);

    // Tick labels (0 / 5 / 10) along the arc, always shown — this is what
    // reads it as "a gauge with a scale" rather than a bare needle.
    for (final tick in [
      (angle: startAngle, label: '0'),
      (angle: startAngle + totalSweep / 2, label: '5'),
      (angle: startAngle + totalSweep, label: '10'),
    ]) {
      final tickPoint = Offset(
        center.dx + (radius + 14) * math.cos(tick.angle),
        center.dy + (radius + 14) * math.sin(tick.angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: tick.label,
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 9,
            color: Color(0x33FFFFFF), fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, tickPoint - Offset(tp.width / 2, tp.height / 2));
    }

    // The needle and its hub only appear once a real score exists — an
    // idle needle pinned hard against one edge with nothing else on the
    // dial reads as broken rather than "no data yet".
    if (fraction == null) return;

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [AppColors.success, AppColors.warning, AppColors.primary],
      ).createShader(rect);
    canvas.drawArc(
        rect, startAngle, totalSweep * fraction!, false, progress);

    final needleAngle = startAngle + totalSweep * fraction!;
    final needleEnd = Offset(
      center.dx + (radius - 18) * math.cos(needleAngle),
      center.dy + (radius - 18) * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary;
    canvas.drawLine(center, needleEnd, needlePaint);

    canvas.drawCircle(
        center, 8, Paint()..color = const Color(0xFF141414));
    canvas.drawCircle(
        center,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.primary);
    canvas.drawCircle(center, 3.5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _HealthGaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

/// Status pill showing whether an OBD-II Bluetooth adapter is connected.
/// Both the dot color and the label reflect real connection state — there
/// is no fabricated "connected" default.
class ObdStatusPill extends StatelessWidget {
  final bool connected;

  /// Name of the connected adapter, when known. Shown instead of the generic
  /// "OBD Adapter Connected" label so the user can see which device it is.
  final String? connectedName;

  const ObdStatusPill({super.key, required this.connected, this.connectedName});

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppColors.success : AppColors.textMuted;
    final label = connected
        ? (connectedName != null && connectedName!.isNotEmpty
            ? 'Connected · $connectedName'
            : 'OBD Adapter Connected')
        : 'OBD Adapter Not Connected — Tap to Connect';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: connected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

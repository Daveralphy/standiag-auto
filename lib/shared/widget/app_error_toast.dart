// Floating error toast widget for StanDiag Auto.
// Displays user-friendly error messages without affecting the UI layout.
// Appears above all other content and auto-dismisses after 3 seconds.
// Uses an Overlay so it never pushes or shifts any screen element.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/errors/app_error.dart';

class AppErrorToast {
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, AppError error) {
    _currentEntry?.remove();
    _currentEntry = null;

    final OverlayEntry entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: error.message,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    Overlay.of(context).insert(entry);
  }

  static void showMessage(BuildContext context, String message) {
    _currentEntry?.remove();
    _currentEntry = null;

    final OverlayEntry entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    Overlay.of(context).insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ToastWidget({required this.message, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.navBarClearance + AppSpacing.md,
      left: AppSpacing.pageHorizontal,
      right: AppSpacing.pageHorizontal,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      offset: Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const _WarningIcon(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningIcon extends StatelessWidget {
  const _WarningIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(painter: _WarningPainter()),
    );
  }
}

class _WarningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double s = size.width / 24;

    final Path triangle = Path()
      ..moveTo(10.29 * s, 3.86 * s)
      ..lineTo(1.82 * s, 18 * s)
      ..arcToPoint(
        Offset(3.53 * s, 21 * s),
        radius: const Radius.circular(1),
        clockwise: false,
      )
      ..lineTo(20.47 * s, 21 * s)
      ..arcToPoint(
        Offset(22.18 * s, 18 * s),
        radius: const Radius.circular(1),
        clockwise: false,
      )
      ..lineTo(13.71 * s, 3.86 * s)
      ..arcToPoint(
        Offset(10.29 * s, 3.86 * s),
        radius: const Radius.circular(1),
        clockwise: false,
      );

    canvas.drawPath(triangle, paint);
    canvas.drawLine(Offset(12 * s, 9 * s), Offset(12 * s, 13 * s), paint);

    // Exclamation dot — use ui.PointMode to avoid ambiguity
    final Paint dotPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(
      ui.PointMode.points,
      [Offset(12 * s, 17 * s)],
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(_WarningPainter _) => false;
}
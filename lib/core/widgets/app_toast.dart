import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_system.dart';

enum ToastType { error, success, info, warning }

class AppToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.error,
    Duration duration = const Duration(seconds: 3),
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
        duration: duration,
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  static void error(BuildContext context, String message) =>
      show(context, message, type: ToastType.error);

  static void success(BuildContext context, String message) =>
      show(context, message, type: ToastType.success);

  static void info(BuildContext context, String message) =>
      show(context, message, type: ToastType.info);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _bgColor {
    switch (widget.type) {
      case ToastType.error: return const Color(0xFF2D0A0C);
      case ToastType.success: return const Color(0xFF0A2D14);
      case ToastType.info: return const Color(0xFF0A1A2D);
      case ToastType.warning: return const Color(0xFF2D1E0A);
    }
  }

  Color get _borderColor {
    switch (widget.type) {
      case ToastType.error: return AppColors.primary.withValues(alpha: 0.6);
      case ToastType.success: return AppColors.advisory.withValues(alpha: 0.6);
      case ToastType.info: return AppColors.bluetooth.withValues(alpha: 0.6);
      case ToastType.warning: return AppColors.moderate.withValues(alpha: 0.6);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.error: return Icons.error_outline_rounded;
      case ToastType.success: return Icons.check_circle_outline_rounded;
      case ToastType.info: return Icons.info_outline_rounded;
      case ToastType.warning: return Icons.warning_amber_rounded;
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case ToastType.error: return AppColors.primaryLight;
      case ToastType.success: return AppColors.advisory;
      case ToastType.info: return AppColors.bluetooth;
      case ToastType.warning: return AppColors.moderate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 12,
      left: 16, right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: _borderColor),
                  boxShadow: AppShadows.lg,
                ),
                child: Row(children: [
                  Icon(_icon, color: _iconColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.message,
                      style: AppTypography.bodySm.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.5), size: 16),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

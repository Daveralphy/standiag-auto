// Floating scan trigger for the Vehicle screen — a circular button with
// slow, concentric ripple rings behind it, like a hotspot/broadcast icon.
// Fixed position, sits just above the nav bar.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FloatingScanButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isBusy;

  const FloatingScanButton({
    super.key,
    required this.onTap,
    this.isBusy = false,
  });

  @override
  State<FloatingScanButton> createState() => _FloatingScanButtonState();
}

class _FloatingScanButtonState extends State<FloatingScanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _buttonSize = 60;
  static const double _maxRippleSize = 100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isBusy ? null : widget.onTap,
      child: SizedBox(
        width: _maxRippleSize,
        height: _maxRippleSize,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                for (final delay in const [0.0, 0.33, 0.66])
                  _Ripple(progress: (_controller.value + delay) % 1.0),
                Container(
                  width: _buttonSize,
                  height: _buttonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryButtonGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x80E8281E),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.isBusy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.qr_code_scanner_rounded,
                            color: Colors.white, size: 26),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Ripple extends StatelessWidget {
  final double progress;
  const _Ripple({required this.progress});

  @override
  Widget build(BuildContext context) {
    final size = _FloatingScanButtonState._buttonSize +
        (_FloatingScanButtonState._maxRippleSize -
                _FloatingScanButtonState._buttonSize) *
            progress;
    final opacity = (1 - progress).clamp(0.0, 1.0) * 0.45;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}

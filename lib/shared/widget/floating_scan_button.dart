// Floating scan trigger for the Vehicle screen — a plain static circular
// button using the hotspot/broadcast icon. No animation or ripple rings;
// fixed position, sits just above the nav bar.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FloatingScanButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isBusy;

  static const double visibleSize = 60;

  const FloatingScanButton({
    super.key,
    required this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: visibleSize,
        height: visibleSize,
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
          child: isBusy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.wifi_tethering_rounded,
                  color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

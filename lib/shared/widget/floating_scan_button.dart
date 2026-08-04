// Floating scan trigger for the Vehicle screen — an outlined circular
// button: a light-red stroke and a light-red icon when the Vehicle tab is
// active, grey otherwise (matching the other nav items' color-only active
// state) so it's never confused for an already-open scan screen when it
// isn't. Fill matches the nav bar's own surface so it reads as the same
// material as the bar rather than a separate colored object. No animation
// or ripple rings; fixed position, sits above the nav bar.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FloatingScanButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isBusy;
  final bool isActive;

  static const double visibleSize = 60;

  const FloatingScanButton({
    super.key,
    required this.onTap,
    this.isBusy = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Same intensity relationship in both states — a lighter-tint stroke,
    // a solid icon — just swapping hue between light red and grey.
    final strokeColor = isActive ? AppColors.primaryBorder : AppColors.border;
    final iconColor = isActive ? AppColors.primary : AppColors.textMuted;
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: visibleSize,
        height: visibleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.navBarBackground,
          border: Border.all(color: strokeColor, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isBusy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : Icon(Icons.wifi_tethering_rounded, color: iconColor, size: 26),
        ),
      ),
    );
  }
}

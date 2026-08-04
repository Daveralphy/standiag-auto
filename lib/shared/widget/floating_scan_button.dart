// Floating scan trigger for the Vehicle screen — an outlined circular
// button: a light-red stroke and a light-red icon, no filled red
// background. Fill matches the nav bar's own surface so it reads as the
// same material as the bar rather than a separate colored object. No
// animation or ripple rings; fixed position, sits above the nav bar.

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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.navBarBackground,
          border: Border.all(color: AppColors.primaryBorder, width: 1.5),
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
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : const Icon(Icons.wifi_tethering_rounded,
                  color: AppColors.primary, size: 26),
        ),
      ),
    );
  }
}

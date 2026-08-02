// The car owner's nav bar — two items on each side of a real notch cut
// into the bar's top edge, with a floating scan button docked in that
// notch. This is a different shape from AppNavBar (a plain rounded pill),
// built with a CustomClipper rather than approximated with two separate
// bars, so the curve reads as one continuous shape the way it does in a
// real notched-FAB design instead of two pills with a gap between them.

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import 'app_nav_bar.dart';
import 'floating_scan_button.dart';

class NotchedNavBar extends StatelessWidget {
  /// Exactly 4 items — 2 rendered left of the notch, 2 right of it.
  final List<AppNavItem> items;
  final int activeIndex;
  final VoidCallback onScanTap;
  final bool isScanBusy;

  static const double barHeight = 64;
  static const double notchRadius = 32;

  const NotchedNavBar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onScanTap,
    this.isScanBusy = false,
  }) : assert(items.length == 4, 'NotchedNavBar expects exactly 4 items');

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.navBarBottomOffset,
      left: AppSpacing.navBarSideOffset,
      right: AppSpacing.navBarSideOffset,
      height: barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x99000000),
                  offset: Offset(0, 8),
                  blurRadius: 32,
                ),
              ],
            ),
            child: ClipPath(
              clipper: const _NotchClipper(notchRadius: notchRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: AppColors.navBarBackground,
                  child: Row(
                    children: [
                      Expanded(child: _side(0, 1)),
                      const SizedBox(width: notchRadius * 2),
                      Expanded(child: _side(2, 3)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -22,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingScanButton(onTap: onScanTap, isBusy: isScanBusy),
            ),
          ),
        ],
      ),
    );
  }

  /// Each half holds 2 items, laid out identically to [AppNavBar] — equal
  /// width, icon above label, color-only active state.
  Widget _side(int i, int j) {
    return Row(
      children: [
        Expanded(child: NavColumnItem(item: items[i], isActive: i == activeIndex)),
        Expanded(child: NavColumnItem(item: items[j], isActive: j == activeIndex)),
      ],
    );
  }
}

/// Cuts a smooth circular notch into the top-center of an otherwise
/// rounded-rect bar — a rounded rect minus a circle centered exactly on
/// the top edge, so only the circle's lower half actually bites into the
/// shape.
class _NotchClipper extends CustomClipper<Path> {
  final double notchRadius;
  const _NotchClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final bar = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(AppRadius.floatingNav),
      ));
    final notch = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, 0),
        radius: notchRadius,
      ));
    return Path.combine(PathOperation.difference, bar, notch);
  }

  @override
  bool shouldReclip(covariant _NotchClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius;
}

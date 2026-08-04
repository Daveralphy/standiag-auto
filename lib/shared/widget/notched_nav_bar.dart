// The car owner's nav bar — five evenly-sized slots (2 items, an empty
// center slot, 2 items) inside a capsule-shaped bar with a real notch cut
// into its top edge, and a floating scan button docked in that notch,
// centered exactly on the bar's top edge so roughly half of it protrudes
// above the bar and the rest overlaps down into it. Built with a
// CustomClipper rather than approximated with two separate bars, so the
// curve reads as one continuous shape the way it does in a real
// notched-FAB design instead of two pills with a gap between them.

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

  /// Whether the Vehicle tab (the one the scan flow belongs to) is the
  /// currently selected tab — drives the scan button's light-red-vs-grey
  /// color, same as every other item's active/inactive state.
  final bool isScanActive;

  // Must match AppSpacing.navBarHeight — NavColumnItem (shared with
  // AppNavBar) sizes itself to that constant via a fixed SizedBox, so a
  // different height here would leave that box mismatched against this
  // bar's own height.
  static const double barHeight = AppSpacing.navBarHeight;
  static const double notchRadius = 32;

  /// Half of [FloatingScanButton.visibleSize] — the button is centered
  /// exactly on the bar's top edge, so this is how far above that edge its
  /// box must sit. That puts ~45% of the circle's own diameter below the
  /// edge (into the bar) and the rest above it — within the intended
  /// 40-50% overlap.
  static const double _scanButtonTopOffset =
      -(FloatingScanButton.visibleSize / 2);

  const NotchedNavBar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onScanTap,
    this.isScanBusy = false,
    this.isScanActive = false,
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
                      Expanded(child: _item(0)),
                      Expanded(child: _item(1)),
                      const Expanded(child: SizedBox()),
                      Expanded(child: _item(2)),
                      Expanded(child: _item(3)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: _scanButtonTopOffset,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingScanButton(
                onTap: onScanTap,
                isBusy: isScanBusy,
                isActive: isScanActive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Five equal-width slots — 2 items, an empty center slot for the scan
  /// button to float over, then 2 more items — so the layout stays
  /// proportional (and the center slot stays centered) at any bar width.
  Widget _item(int i) {
    return NavColumnItem(item: items[i], isActive: i == activeIndex);
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
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(AppRadius.floatingNav),
        ),
      );
    final notch = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(size.width / 2, 0), radius: notchRadius),
      );
    return Path.combine(PathOperation.difference, bar, notch);
  }

  @override
  bool shouldReclip(covariant _NotchClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius;
}

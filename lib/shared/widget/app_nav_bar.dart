// The floating bottom nav bar used by every tab shell and every job-flow
// screen in the app. Every item — active or not — renders exactly the
// same way: icon above label, no pill or background of any kind, only
// the color changing between active and inactive. That uniformity is
// deliberate: every item gets an equal, generously-padded share of the
// bar's width and height by construction, so there's no equal-vs-expanded
// asymmetry left to get wrong and no way for a label to end up squeezed
// into less room than its neighbors.
//
// Icons are standard Material IconData, not hand-drawn — plain Icon
// widgets, no custom SVG parsing or CustomPainter drawing in this file.

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';

/// One entry in [AppNavBar.items].
class AppNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AppNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class AppNavBar extends StatelessWidget {
  final List<AppNavItem> items;
  final int activeIndex;

  const AppNavBar({
    super.key,
    required this.items,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.navBarBottomOffset,
      left: AppSpacing.navBarSideOffset,
      right: AppSpacing.navBarSideOffset,
      height: AppSpacing.navBarHeight,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x99000000),
              offset: Offset(0, 8),
              blurRadius: 32,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.floatingNav),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.navBarBackground,
                border: Border.all(color: AppColors.navBarBorder),
              ),
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: NavColumnItem(
                        item: items[i],
                        isActive: i == activeIndex,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One nav item: icon above label, colored primary when active and muted
/// when not — no pill, no background, no size difference between the two
/// states. Shared by [AppNavBar] and [NotchedNavBar] so both read as the
/// same design language.
class NavColumnItem extends StatelessWidget {
  final AppNavItem item;
  final bool isActive;

  const NavColumnItem({super.key, required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textMuted;
    // Both nav bars render as siblings of their tab shell's navigationShell
    // inside a plain Stack, outside of any screen's own Scaffold — so
    // there's no Material ancestor here unless this widget provides its
    // own. `transparency` keeps it fully invisible (no color/elevation of
    // its own) while still giving the Text/Icon below a real Material
    // and DefaultTextStyle to resolve against.
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: item.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: AppSpacing.navBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                  // The pre-redesign labels used AppTypography.labelActive/
                  // labelInactive, both pinned to height: 1.0. Dropping that
                  // when this became an inline style left the label's line
                  // box sized by Inter's own (taller) built-in line-height
                  // instead — pin it back to exactly 1x the font size.
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

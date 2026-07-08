import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widget/app_nav_bar.dart';

class UserShellScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const UserShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<UserShellScreen> createState() => _UserShellScreenState();
}

class _UserShellScreenState extends State<UserShellScreen> {
  int _previousIndex = 1;

  void _onTap(int index) {
    setState(() => _previousIndex = widget.navigationShell.currentIndex);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final slidingRight = currentIndex > _previousIndex;
    final begin = slidingRight
        ? const Offset(1.0, 0.0)
        : const Offset(-1.0, 0.0);

    return Stack(
      children: [
        // ─── Sliding body ───────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            final isIncoming =
                (child.key as ValueKey<int>).value == currentIndex;
            final slideIn = Tween<Offset>(
              begin: isIncoming ? begin : Offset.zero,
              end: isIncoming
                  ? Offset.zero
                  : (slidingRight
                      ? const Offset(-1.0, 0.0)
                      : const Offset(1.0, 0.0)),
            ).animate(animation);
            return SlideTransition(position: slideIn, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(currentIndex),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: widget.navigationShell,
            ),
          ),
        ),

        // ─── Persistent nav bar — never moves ──────────────────────────
        AppNavBar(
          activeItem: _activeItem(currentIndex),
          userType: NavBarUserType.carOwner,
          onScanTap: () => _onTap(0),
          onHomeTap: () => _onTap(1),
          onThirdTap: () => _onTap(2),
        ),
      ],
    );
  }

  NavBarItem _activeItem(int index) {
    switch (index) {
      case 0:
        return NavBarItem.scan;
      case 2:
        return NavBarItem.third;
      default:
        return NavBarItem.home;
    }
  }
}
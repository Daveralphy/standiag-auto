// Persistent bottom-nav chrome for the three-tab shells (Scan / Home /
// Mechanics-or-Users) for both profile types. Each tab's whole screen —
// including its map, if it has one — lives in its own StatefulShellBranch
// and stays alive in memory across tab switches instead of being torn down
// and rebuilt every time context.go() used to swap the entire route: that
// full rebuild (fresh GPS resolve, fresh camera reset) was what made the
// map tabs feel like they were reloading on every navigation.
//
// Branch order is fixed to match AppNavBar's own left-to-right item order:
// 0 = Scan, 1 = Home, 2 = Mechanics/Users.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widget/app_nav_bar.dart';

NavBarItem _itemForBranch(int index) {
  switch (index) {
    case 0:
      return NavBarItem.scan;
    case 2:
      return NavBarItem.third;
    default:
      return NavBarItem.home;
  }
}

class UserTabShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const UserTabShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        navigationShell,
        AppNavBar(
          activeItem: _itemForBranch(navigationShell.currentIndex),
          userType: NavBarUserType.carOwner,
          onScanTap: () => navigationShell.goBranch(0),
          onHomeTap: () => navigationShell.goBranch(1),
          onThirdTap: () => navigationShell.goBranch(2),
        ),
      ],
    );
  }
}

class MechanicTabShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MechanicTabShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        navigationShell,
        AppNavBar(
          activeItem: _itemForBranch(navigationShell.currentIndex),
          userType: NavBarUserType.mechanic,
          onScanTap: () => navigationShell.goBranch(0),
          onHomeTap: () => navigationShell.goBranch(1),
          onThirdTap: () => navigationShell.goBranch(2),
        ),
      ],
    );
  }
}

// Persistent bottom-nav chrome for the tab shells â€” one per profile type.
// Each tab's whole screen â€” including its map, if it has one â€” lives in a
// StatefulShellBranch and stays alive in memory across tab switches instead
// of being torn down and rebuilt every time.
//
// Car owner: Home, Mechanics, Vehicle, Profile, laid out around a real
// notch with the scan button permanently docked in it (NotchedNavBar) â€”
// always visible, on every car-owner screen, not just the Vehicle tab.
// Tapping it switches to the Vehicle branch first if needed, then talks
// directly to scanProvider/profileProvider â€” the same global state the
// Vehicle screen itself reads â€” rather than reaching into that screen's
// own widget state, since the button and the screen are siblings here,
// not parent and child.
//
// Mechanic: Scan, Home, Users â€” unchanged, plain AppNavBar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/profile/providers/profile_provider.dart';
import '../../features/scan/providers/scan_provider.dart';
import '../../shared/widget/app_nav_bar.dart';
import '../../shared/widget/notched_nav_bar.dart';
import 'route_names.dart';

class UserTabShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const UserTabShell({super.key, required this.navigationShell});

  static const int _vehicleBranchIndex = 2;

  /// Pushes the dedicated Scan screen — the scan flow itself (connect/start)
  /// lives entirely on that screen, not here. The one thing worth handling
  /// before pushing is having no vehicle yet, since that screen assumes one
  /// exists; send them to the Vehicle tab's own "Add a Vehicle" prompt
  /// instead of a diagnostics screen with nothing to diagnose.
  void _onScanTap(BuildContext context, WidgetRef ref) {
    final vehicles = ref.read(profileProvider).vehicles;
    if (vehicles.isEmpty) {
      if (navigationShell.currentIndex != _vehicleBranchIndex) {
        navigationShell.goBranch(_vehicleBranchIndex);
      }
      return;
    }
    context.push(RouteNames.userScan);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final scanState = ref.watch(scanProvider);

    return Stack(
      children: [
        navigationShell,
        NotchedNavBar(
          activeIndex: currentIndex,
          isScanBusy: scanState.isScanning || scanState.isConnectingDevice,
          isScanActive: currentIndex == _vehicleBranchIndex,
          onScanTap: () => _onScanTap(context, ref),
          items: [
            AppNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => navigationShell.goBranch(0),
            ),
            AppNavItem(
              icon: Icons.build_rounded,
              label: 'Mechanics',
              onTap: () => navigationShell.goBranch(1),
            ),
            AppNavItem(
              icon: Icons.directions_car_rounded,
              label: 'Vehicle',
              onTap: () => navigationShell.goBranch(_vehicleBranchIndex),
            ),
            AppNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () => navigationShell.goBranch(3),
            ),
          ],
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
          activeIndex: navigationShell.currentIndex,
          items: [
            AppNavItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan',
              onTap: () => navigationShell.goBranch(0),
            ),
            AppNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => navigationShell.goBranch(1),
            ),
            AppNavItem(
              icon: Icons.groups_rounded,
              label: 'Users',
              onTap: () => navigationShell.goBranch(2),
            ),
          ],
        ),
      ],
    );
  }
}

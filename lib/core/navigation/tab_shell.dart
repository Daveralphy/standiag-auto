// Persistent bottom-nav chrome for the tab shells â€” one per profile type.
// Each tab's whole screen â€” including its map, if it has one â€” lives in a
// StatefulShellBranch and stays alive in memory across tab switches instead
// of being torn down and rebuilt every time.
//
// Car owner: Home, Mechanics, Vehicle, Profile, laid out around a real
// notch with the scan button permanently docked in it (NotchedNavBar) —
// always visible, on every car-owner screen, not just the Vehicle tab.
// Tapping it opens ScanSheet — a modal that floats on top of whatever tab
// is currently showing, not a route change, so the tab underneath (and
// its highlighted nav item) never changes.
//
// The scan button's own active color is deliberately independent of
// which tab is selected — it's an action trigger, not a destination, so
// it only lights up while its own sheet is actually open, never because
// the Vehicle tab happens to be selected. Tying it to the tab used to
// mean tapping Vehicle lit up both icons at once, which read as two
// different screens being "current" simultaneously.
//
// Mechanic: Scan, Home, Users — unchanged, plain AppNavBar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/scan/providers/scan_provider.dart';
import '../../shared/widget/app_nav_bar.dart';
import '../../shared/widget/notched_nav_bar.dart';
import '../../shared/widget/scan_sheet.dart';

class UserTabShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const UserTabShell({super.key, required this.navigationShell});

  @override
  ConsumerState<UserTabShell> createState() => _UserTabShellState();
}

class _UserTabShellState extends ConsumerState<UserTabShell> {
  static const int _vehicleBranchIndex = 2;
  bool _isScanSheetOpen = false;

  Future<void> _onScanTap(BuildContext context) async {
    setState(() => _isScanSheetOpen = true);
    await ScanSheet.show(context);
    if (mounted) setState(() => _isScanSheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final scanState = ref.watch(scanProvider);

    return Stack(
      children: [
        widget.navigationShell,
        NotchedNavBar(
          activeIndex: currentIndex,
          isScanBusy: scanState.isScanning || scanState.isConnectingDevice,
          isScanActive: _isScanSheetOpen,
          onScanTap: () => _onScanTap(context),
          items: [
            AppNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => widget.navigationShell.goBranch(0),
            ),
            AppNavItem(
              icon: Icons.build_rounded,
              label: 'Mechanics',
              onTap: () => widget.navigationShell.goBranch(1),
            ),
            AppNavItem(
              icon: Icons.directions_car_rounded,
              label: 'Vehicle',
              onTap: () => widget.navigationShell.goBranch(_vehicleBranchIndex),
            ),
            AppNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () => widget.navigationShell.goBranch(3),
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

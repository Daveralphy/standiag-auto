// Persistent bottom-nav chrome for the tab shells â€” one per profile type.
// Each tab's whole screen â€” including its map, if it has one â€” lives in a
// StatefulShellBranch and stays alive in memory across tab switches instead
// of being torn down and rebuilt every time.
//
// Car owner: Home, Mechanics, Vehicle, Profile, laid out around a real
// notch with the scan button permanently docked in it (NotchedNavBar) —
// always visible, on every car-owner screen, not just the Vehicle tab.
// Tapping it starts a two-stage overlay (see scan_overlay.dart) — a
// blurred backdrop with a "Scan" prompt, then the diagnostic panel as a
// centered layer — never a route change and never a slide-up sheet, so
// the tab underneath (and its highlighted nav item) never changes.
//
// The scan button's own active color is deliberately independent of
// which tab is selected — it's an action trigger, not a destination, so
// it only lights up while its own overlay is actually showing, never
// because the Vehicle tab happens to be selected. Tying it to the tab
// used to mean tapping Vehicle lit up both icons at once, which read as
// two different screens being "current" simultaneously.
//
// Mechanic: Scan, Home, Users — unchanged, plain AppNavBar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/scan/providers/scan_provider.dart';
import '../../shared/widget/app_nav_bar.dart';
import '../../shared/widget/notched_nav_bar.dart';
import '../../shared/widget/scan_overlay.dart';

class UserTabShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const UserTabShell({super.key, required this.navigationShell});

  @override
  ConsumerState<UserTabShell> createState() => _UserTabShellState();
}

class _UserTabShellState extends ConsumerState<UserTabShell> {
  static const int _vehicleBranchIndex = 2;
  ScanOverlayStage _scanStage = ScanOverlayStage.idle;

  void _onScanIconTap() {
    if (_scanStage == ScanOverlayStage.idle) {
      setState(() => _scanStage = ScanOverlayStage.prompt);
    }
  }

  void _openScanModal() => setState(() => _scanStage = ScanOverlayStage.open);

  void _demoteScanStage() {
    setState(() {
      _scanStage = _scanStage == ScanOverlayStage.open
          ? ScanOverlayStage.prompt
          : ScanOverlayStage.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final scanState = ref.watch(scanProvider);
    final iconTop = scanIconTopFromBottom();

    return Stack(
      children: [
        widget.navigationShell,
        ScanBackdrop(stage: _scanStage, onTapOutside: _demoteScanStage),
        NotchedNavBar(
          activeIndex: currentIndex,
          isScanBusy: scanState.isScanning || scanState.isConnectingDevice,
          isScanActive: _scanStage != ScanOverlayStage.idle,
          onScanTap: _onScanIconTap,
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
        ScanPromptButton(
          stage: _scanStage,
          iconTopFromBottom: iconTop,
          onTap: _openScanModal,
        ),
        ScanModalCard(stage: _scanStage),
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

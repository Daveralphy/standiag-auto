// User Mechanics tab — full-screen map of nearby mechanics, matching the
// "Great Mechanics / Standby Nearby" design. Tapping "Find Nearby Mechanics"
// starts the radius-selector → searching → mechanic-card flow.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_dark_map.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../../profile/screens/user_drawer_screen.dart';

class UserMechanicsScreen extends ConsumerStatefulWidget {
  const UserMechanicsScreen({super.key});

  @override
  ConsumerState<UserMechanicsScreen> createState() =>
      _UserMechanicsScreenState();
}

class _UserMechanicsScreenState extends ConsumerState<UserMechanicsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(nearbyMechanicsProvider);
    final mechanics = mechanicsAsync.valueOrNull ?? const [];
    final markers = [
      for (final entry in mechanics)
        if (entry.mechanic.location != null)
          AppDarkMapMarker(
            id: entry.mechanic.uid,
            position: LatLng(entry.mechanic.location!.latitude,
                entry.mechanic.location!.longitude),
            child: const AppDarkMapPin(icon: Icons.build_rounded),
            onTap: () => context.push(RouteNames.mechanicProfile,
                extra: entry.mechanic.uid),
          ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mapBackground,
      drawer: const UserDrawerScreen(),
      body: Stack(
        children: [
          AppDarkMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 13.2,
            markers: markers,
          ),

          // ─── Top gradient ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF0060606), Colors.transparent],
                ),
              ),
            ),
          ),

          // ─── Header ──────────────────────────────────────────────────
          SafeArea(
            child: AppScreenHeader(
              scaffoldKey: _scaffoldKey,
              title: 'Great Mechanics',
              subtitle: 'Standby Nearby',
              trailingIcon: Icons.search_rounded,
              onTrailingTap: () => context.go(RouteNames.radiusSelector),
            ),
          ),

          if (mechanicsAsync.isLoading)
            const Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(child: _StatusPill(text: 'Finding mechanics nearby…')),
            )
          else if (mechanicsAsync.hasError)
            const Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                  child: _StatusPill(text: 'Unable to load mechanics')),
            )
          else if (mechanics.isEmpty)
            const Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                  child: _StatusPill(text: 'No mechanics available nearby')),
            ),

          // ─── Find button — sits above the floating nav ─────────────────
          Positioned(
            bottom: AppSpacing.navBarHeight +
                AppSpacing.navBarBottomOffset +
                12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: GestureDetector(
              onTap: () => context.go(RouteNames.radiusSelector),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40E8281E),
                        blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: const Center(
                  child: Text('Find Nearby Mechanics',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 15,
                        fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                ),
              ),
            ),
          ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.carOwner,
            onScanTap: () => context.go(RouteNames.userScan),
            onHomeTap: () => context.go(RouteNames.userHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE10E0E0E),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Text(text,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
          maxLines: 1),
    );
  }
}

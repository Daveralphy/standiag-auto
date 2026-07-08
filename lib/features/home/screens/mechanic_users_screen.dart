// Mechanic Users screen — map view showing nearby car owners.
// Nav bar active: Users. Search icon top right.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicUsersScreen extends StatefulWidget {
  const MechanicUsersScreen({super.key});

  @override
  State<MechanicUsersScreen> createState() => _MechanicUsersScreenState();
}

class _MechanicUsersScreenState extends State<MechanicUsersScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    const LatLng mechanicUserCenter = LatLng(6.5244, 3.3792);
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792),
              zoom: 13.2,
            ),
            markers: {
              buildMapMarker(
                markerId: 'user-1',
                position: mechanicUserCenter,
                icon: buildUserMarkerIcon(),
                infoWindowTitle: 'User requesting help',
              ),
              buildMapMarker(
                markerId: 'user-2',
                position: const LatLng(6.5271, 3.3820),
                icon: buildUserMarkerIcon(),
                infoWindowTitle: 'Nearby user',
              ),
              buildMapMarker(
                markerId: 'user-3',
                position: const LatLng(6.5218, 3.3767),
                icon: buildUserMarkerIcon(),
                infoWindowTitle: 'Nearby user',
              ),
            },
            circles: {
              buildRadiusCircle(
                circleId: 'mechanic-radius',
                center: mechanicUserCenter,
                radiusMeters: 2000,
              ),
            },
            enableCurrentLocation: true,
            showCurrentLocationButton: false,
            showZoomControls: false,
            showCompass: false,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nearby Users',
                          style: AppTypography.heading2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Car owners near you',
                          style: AppTypography.body,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  // Search icon
                  Container(
                    width: AppSpacing.iconButtonSize,
                    height: AppSpacing.iconButtonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xB3080808),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border:
                          Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: const Icon(Icons.search_rounded,
                        size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}
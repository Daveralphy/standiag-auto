// Displays the live tracking map while the mechanic is en route.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserTrackingScreen extends StatefulWidget {
  const UserTrackingScreen({super.key});

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    const LatLng userLocation = LatLng(6.5244, 3.3792);
    const LatLng mechanicLocation = LatLng(6.5290, 3.3830);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792),
              zoom: 13.5,
            ),
            markers: {
              buildMapMarker(
                markerId: 'user-location',
                position: userLocation,
                icon: buildUserMarkerIcon(),
                infoWindowTitle: 'Your location',
              ),
              buildMapMarker(
                markerId: 'mechanic-location',
                position: mechanicLocation,
                icon: buildMechanicMarkerIcon(),
                infoWindowTitle: 'Kwame Asante',
              ),
            },
            polylines: {
              buildDashedRoutePolyline(
                polylineId: 'tracking-route',
                points: [userLocation, mechanicLocation],
              ),
            },
            enableCurrentLocation: true,
            showCurrentLocationButton: false,
            showZoomControls: false,
            showCompass: false,
          ),
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
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tracking',
                          style: AppTypography.heading3,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Mechanic en route',
                          style: AppTypography.body,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.search_rounded, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.navBarClearance + 12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  AppAvatar(name: 'Kwame Asante', size: 42),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kwame Asante',
                          style: AppTypography.heading4,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '7 min away · 1.2 km',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
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

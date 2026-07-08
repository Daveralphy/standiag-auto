// User Mechanic Arrived screen — mechanic has arrived at user location.
// Map background, arrival confirmation, confirm job started button.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMechanicArrivedScreen extends StatefulWidget {
  const UserMechanicArrivedScreen({super.key});

  @override
  State<UserMechanicArrivedScreen> createState() =>
      _UserMechanicArrivedScreenState();
}

class _UserMechanicArrivedScreenState
    extends State<UserMechanicArrivedScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    const LatLng userLocation = LatLng(6.5244, 3.3792);
    const LatLng mechanicLocation = LatLng(6.5248, 3.3795);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792),
              zoom: 15,
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
                infoWindowTitle: 'Arrived mechanic',
              ),
            },
            enableCurrentLocation: true,
            showCurrentLocationButton: false,
            showZoomControls: false,
            showCompass: false,
          ),

          Positioned(top: 0, left: 0, right: 0, height: 140,
            child: Container(decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF0060606), Colors.transparent])))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                const AppAvatar(name: 'John Doe', size: 36),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mechanic Arrived', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text("He's here", style: AppTypography.body.copyWith(
                        color: AppColors.success),
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                )),
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xB3080808),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: const Color(0x1FFFFFFF))),
                  child: const Icon(Icons.search_rounded,
                      size: 16, color: Colors.white)),
              ]),
            ),
          ),

          Positioned(
            bottom: AppSpacing.navBarClearance + 12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl2),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0x144CAF50),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: const Color(0x334CAF50))),
                child: const Row(children: [
                  Icon(Icons.location_on_rounded,
                      color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kwame is here!', style: AppTypography.bodyLarge,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text('Ready to get started',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  )),
                ]),
              ),
              AppButton(
                label: 'Confirm Job Started',
                onTap: () => context.go(RouteNames.userJobInProgress),
              ),
            ]),
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
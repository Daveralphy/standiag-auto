// Mechanic Post Call screen — after call ends, mechanic decides to accept or reject job.

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

class MechanicPostCallScreen extends StatefulWidget {
  const MechanicPostCallScreen({super.key});

  @override
  State<MechanicPostCallScreen> createState() =>
      _MechanicPostCallScreenState();
}

class _MechanicPostCallScreenState extends State<MechanicPostCallScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    const LatLng mechanicLocation = LatLng(6.5282, 3.3822);
    const LatLng userLocation = LatLng(6.5244, 3.3792);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5265, 3.3810),
              zoom: 14.2,
            ),
            markers: {
              buildMapMarker(
                markerId: 'mechanic-location',
                position: mechanicLocation,
                icon: buildMechanicMarkerIcon(),
                infoWindowTitle: 'You',
              ),
              buildMapMarker(
                markerId: 'user-location',
                position: userLocation,
                icon: buildUserMarkerIcon(),
                infoWindowTitle: 'John Doe',
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
                const AppAvatar(name: 'Kwame Asante', size: 36),
                const SizedBox(width: 10),
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Call completed', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Ready to take this job?', style: AppTypography.body,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                )),
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xB3080808),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: const Color(0x1FFFFFFF))),
                  child: const Icon(Icons.search_rounded, size: 16, color: Colors.white)),
              ]),
            ),
          ),

          Positioned(
            bottom: AppSpacing.navBarClearance + 12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  const Row(children: [
                    AppAvatar(name: 'John Doe', size: 42),
                    SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John Doe', style: AppTypography.heading4,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        Text('Engine Problem · Toyota Corolla',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: AppButton(
                      label: 'Reject Job',
                      onTap: () => context.go(RouteNames.mechanicHome),
                      variant: AppButtonVariant.ghost,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: AppButton(
                      label: 'Accept Job',
                      onTap: () => context.go(RouteNames.mechanicEnRoute),
                    )),
                  ]),
                ]),
              ),
            ]),
          ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () => context.go(RouteNames.mechanicUsers),
          ),
        ],
      ),
    );
  }
}
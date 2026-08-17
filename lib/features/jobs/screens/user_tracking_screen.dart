// Displays the live tracking map while the mechanic is en route.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/notched_nav_bar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/job_provider.dart';

class UserTrackingScreen extends ConsumerStatefulWidget {
  final String jobId;
  const UserTrackingScreen({super.key, required this.jobId});

  @override
  ConsumerState<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends ConsumerState<UserTrackingScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(jobProvider.select((s) => s.activeJob));
    final mechanicAsync = job == null
        ? null
        : ref.watch(mechanicUserProvider(job.mechanicId));
    final mechanicName = mechanicAsync?.valueOrNull != null
        ? '${mechanicAsync!.valueOrNull!.firstName} ${mechanicAsync.valueOrNull!.lastName}'
            .trim()
        : 'Mechanic';
    const LatLng userLocation = LatLng(6.5244, 3.3792);
    final mechanicLocation = job?.mechanicLocation != null
        ? LatLng(job!.mechanicLocation!.latitude, job.mechanicLocation!.longitude)
        : const LatLng(6.5290, 3.3830);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 13.5,
            markers: [
              AppMapMarker(
                id: 'user-location',
                position: userLocation,
                child: buildUserMarkerIcon(),
              ),
              AppMapMarker(
                id: 'mechanic-location',
                position: mechanicLocation,
                child: buildMechanicMarkerIcon(),
              ),
            ],
            polylines: [
              AppMapPolyline(
                id: 'tracking-route',
                points: [userLocation, mechanicLocation],
              ),
            ],
            enableCurrentLocation: true,
            showMapControls: false,
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
                  Icon(Icons.search_rounded, size: 16, color: AppColors.textPrimary),
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
              child: Row(
                children: [
                  AppAvatar(name: mechanicName, size: 42),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mechanicName,
                          style: AppTypography.heading4,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          job?.issue ?? '',
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
          NotchedNavBar(
            activeIndex: 1,
            onScanTap: () => context.go(RouteNames.userVehicle),
            items: [
              AppNavItem(icon: Icons.home_rounded, label: 'Home',
                  onTap: () => context.go(RouteNames.userHome)),
              AppNavItem(icon: Icons.build_rounded, label: 'Mechanics',
                  onTap: () {}),
              AppNavItem(icon: Icons.directions_car_rounded, label: 'Vehicle',
                  onTap: () => context.go(RouteNames.userVehicle)),
              AppNavItem(icon: Icons.person_rounded, label: 'Profile',
                  onTap: () => context.go(RouteNames.userProfile)),
            ],
          ),
        ],
      ),
    );
  }
}

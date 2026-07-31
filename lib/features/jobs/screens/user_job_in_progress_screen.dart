// User Job In Progress screen — job is underway.
// Map background, user nav bar Mechanics active, search icon top right.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:latlong2/latlong.dart';
import '../providers/job_provider.dart';

class UserJobInProgressScreen extends ConsumerStatefulWidget {
  final String jobId;
  const UserJobInProgressScreen({super.key, required this.jobId});

  @override
  ConsumerState<UserJobInProgressScreen> createState() =>
      _UserJobInProgressScreenState();
}

class _UserJobInProgressScreenState
    extends ConsumerState<UserJobInProgressScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
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
        : const LatLng(6.5246, 3.37935);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 15.2,
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
            enableCurrentLocation: true,
            showMapControls: false,
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
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job In Progress', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Sit tight', style: AppTypography.body,
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
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border)),
              child: Row(children: [
                AppAvatar(name: mechanicName, size: 42),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mechanicName, style: AppTypography.heading4,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Working on ${job?.issue ?? "your vehicle"}',
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.primaryBorder)),
                  child: Text('In Progress',
                      style: AppTypography.micro.copyWith(
                          color: AppColors.primary),
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              ]),
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
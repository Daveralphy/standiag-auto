// User Job Completed screen — job is done, user prompted to rate mechanic.
// Map background, user nav Mechanics active, search icon top right.

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
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:latlong2/latlong.dart';
import '../providers/job_provider.dart';

class UserJobCompletedScreen extends ConsumerStatefulWidget {
  final String jobId;
  const UserJobCompletedScreen({super.key, required this.jobId});

  @override
  ConsumerState<UserJobCompletedScreen> createState() =>
      _UserJobCompletedScreenState();
}

class _UserJobCompletedScreenState
    extends ConsumerState<UserJobCompletedScreen> {
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
        : ref.watch(mechanicByIdProvider(job.mechanicId));
    final mechanicUserAsync = job == null
        ? null
        : ref.watch(mechanicUserProvider(job.mechanicId));
    final mechanicName = mechanicUserAsync?.valueOrNull != null
        ? '${mechanicUserAsync!.valueOrNull!.firstName} ${mechanicUserAsync.valueOrNull!.lastName}'
            .trim()
        : 'Mechanic';
    final mechanicRating = mechanicAsync?.valueOrNull?.rating ?? 0.0;
    final mechanicJobs = mechanicAsync?.valueOrNull?.totalJobs ?? 0;
    const LatLng userLocation = LatLng(6.5244, 3.3792);
    const LatLng mechanicLocation = LatLng(6.5246, 3.37935);

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
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Job Completed', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Great work!', style: AppTypography.body.copyWith(
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
              // Completion banner
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0x144CAF50),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: const Color(0x334CAF50))),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Job marked as done!',
                          style: AppTypography.bodyLarge,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text(job?.issue ?? '',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  )),
                ]),
              ),
              // Mechanic card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  Row(children: [
                    AppAvatar(name: mechanicName, size: 42),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mechanicName, style: AppTypography.heading4,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        Row(children: [
                          RatingStars(rating: mechanicRating, starSize: 11),
                          const SizedBox(width: 4),
                          Flexible(child: Text(
                              '${mechanicRating.toStringAsFixed(1)} · $mechanicJobs jobs',
                              style: AppTypography.caption,
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                        ]),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 12),
                  Text('Help $mechanicName grow by leaving a rating.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, maxLines: 2),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: AppButton(
                      label: 'Skip',
                      onTap: () => context.go(RouteNames.userHome),
                      variant: AppButtonVariant.ghost,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: AppButton(
                      label: 'Rate Mechanic',
                      onTap: () => context.go(RouteNames.userRateMechanic,
                          extra: widget.jobId),
                    )),
                  ]),
                ]),
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
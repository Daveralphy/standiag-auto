// Mechanic Job In Progress screen â€” mechanic side during active job.
// Mechanic nav bar, Users active, search icon top right.
// Mark job as done button.

import 'package:firebase_auth/firebase_auth.dart';
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
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:latlong2/latlong.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';

class MechanicJobInProgressScreen extends ConsumerStatefulWidget {
  final String jobId;
  const MechanicJobInProgressScreen({super.key, required this.jobId});

  @override
  ConsumerState<MechanicJobInProgressScreen> createState() =>
      _MechanicJobInProgressScreenState();
}

class _MechanicJobInProgressScreenState
    extends ConsumerState<MechanicJobInProgressScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
  }

  void _markDone() {
    ref.read(jobProvider.notifier).updateStatus(widget.jobId, JobStatus.completed);
    context.go(RouteNames.mechanicJobCompleted, extra: widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(jobProvider.select((s) => s.activeJob));
    final callerAsync = job == null
        ? null
        : ref.watch(mechanicUserProvider(job.carOwnerId));
    final callerName = callerAsync?.valueOrNull != null
        ? '${callerAsync!.valueOrNull!.firstName} ${callerAsync.valueOrNull!.lastName}'
            .trim()
        : 'Car Owner';
    final mechanicLocation = job?.mechanicLocation != null
        ? LatLng(job!.mechanicLocation!.latitude, job.mechanicLocation!.longitude)
        : const LatLng(6.5282, 3.3822);
    final userLocation = job?.carOwnerLocation != null
        ? LatLng(job!.carOwnerLocation!.latitude, job.carOwnerLocation!.longitude)
        : const LatLng(6.5244, 3.3792);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5265, 3.3810),
            initialZoom: 14.6,
            markers: [
              AppMapMarker(
                id: 'mechanic-location',
                position: mechanicLocation,
                child: buildMechanicMarkerIcon(),
              ),
              AppMapMarker(
                id: 'user-location',
                position: userLocation,
                child: buildUserMarkerIcon(),
              ),
            ],
            enableCurrentLocation: true,
            showMapControls: false,
          ),

          Positioned(top: 0, left: 0, right: 0, height: 140,
            child: Container(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background.withValues(alpha: 0.9), Colors.transparent])))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                AppAvatar(
                  name: FirebaseAuth.instance.currentUser?.displayName ?? 'You',
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job In Progress', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Working now', style: AppTypography.body,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                )),
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.surfaceElevated.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.borderActive)),
                  child: Icon(Icons.search_rounded,
                      size: 16, color: AppColors.textPrimary)),
              ]),
            ),
          ),

          Positioned(
            bottom: AppSpacing.navBarClearance + 12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  AppAvatar(name: callerName, size: 42),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(callerName, style: AppTypography.heading4,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text(job?.issue ?? '',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  )),
                ]),
              ),
              AppButton(
                label: 'Mark Job as Done',
                onTap: _markDone,
              ),
            ]),
          ),

          AppNavBar(
            activeIndex: 2,
            items: [
              AppNavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scan',
                  onTap: () => context.go(RouteNames.mechanicScan)),
              AppNavItem(icon: Icons.home_rounded, label: 'Home',
                  onTap: () => context.go(RouteNames.mechanicHome)),
              AppNavItem(icon: Icons.groups_rounded, label: 'Users',
                  onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
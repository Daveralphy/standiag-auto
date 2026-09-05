// Mechanic Job In Progress screen â€” mechanic side during active job.
// Mechanic nav bar, Users active, search icon top right.
// Mark job as done button.

import 'dart:async';

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
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/notched_nav_bar.dart';
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
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _elapsedTime(DateTime? startedAt) {
    if (startedAt == null) return 'Ready to start';
    final elapsed = _now.difference(startedAt);
    final totalSeconds = elapsed.isNegative ? 0 : elapsed.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startJob() {
    ref.read(jobProvider.notifier).updateStatus(widget.jobId, JobStatus.inProgress);
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
                      const SizedBox(height: 3),
                      Text(
                        job?.status == JobStatus.inProgress
                          ? 'Duration ${_elapsedTime(job?.startedAt)}'
                          : _elapsedTime(null),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  )),
                ]),
              ),
              AppButton(
                label: job?.status == JobStatus.inProgress
                    ? 'Mark Job as Done'
                    : 'Start Job',
                onTap: job?.status == JobStatus.inProgress
                    ? _markDone
                    : _startJob,
              ),
            ]),
          ),

          NotchedNavBar(
            activeIndex: 1,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            items: [
              AppNavItem(icon: Icons.home_rounded, label: 'Home',
                  onTap: () => context.go(RouteNames.mechanicHome)),
              AppNavItem(icon: Icons.groups_rounded, label: 'Users',
                  onTap: () {}),
              AppNavItem(icon: Icons.history_rounded, label: 'Jobs',
                  onTap: () => context.go(RouteNames.jobHistory)),
              AppNavItem(icon: Icons.person_rounded, label: 'Profile',
                  onTap: () => context.go(RouteNames.mechanicProfileView)),
            ],
          ),
        ],
      ),
    );
  }
}
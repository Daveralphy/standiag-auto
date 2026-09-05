// User Job In Progress screen â€” job is underway.
// Map background, user nav bar Mechanics active, search icon top right.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../shared/widget/notched_nav_bar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:latlong2/latlong.dart';
import '../models/job_model.dart';
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
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    HapticFeedback.mediumImpact();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _elapsedTime(DateTime? startedAt) {
    if (startedAt == null) return 'Starting timer...';
    final elapsed = _now.difference(startedAt);
    final totalSeconds = elapsed.isNegative ? 0 : elapsed.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // The mechanic marking the job done only updates Firestore — nothing
    // was ever listening for that transition on this side, so the owner
    // was stuck on this screen forever with no way to reach the
    // completed/rating screens. addPostFrameCallback defers the navigation
    // out of build(), matching the framework's own rule against pushing
    // routes mid-build.
    ref.listen(jobProvider.select((s) => s.activeJob), (previous, next) {
      if (next?.status == JobStatus.completed &&
          previous?.status != JobStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go(RouteNames.userJobCompleted, extra: widget.jobId);
        });
      }
    });

    final job = ref.watch(jobProvider.select((s) => s.activeJob));
    final mechanicAsync = job == null
        ? null
        : ref.watch(mechanicUserProvider(job.mechanicId));
    final mechanicName = mechanicAsync?.valueOrNull != null
        ? '${mechanicAsync!.valueOrNull!.firstName} ${mechanicAsync.valueOrNull!.lastName}'
            .trim()
        : 'Mechanic';
    final userLocation = job?.carOwnerLocation != null
        ? LatLng(job!.carOwnerLocation!.latitude, job.carOwnerLocation!.longitude)
        : const LatLng(6.5244, 3.3792);
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
                    Text(
                      job?.status == JobStatus.inProgress
                        ? 'Job In Progress'
                        : 'Mechanic Arrived',
                      style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text(
                      job?.status == JobStatus.inProgress
                        ? 'Sit tight'
                        : 'Waiting for the job to start',
                      style: AppTypography.body,
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
                    Text(
                      job?.status == JobStatus.inProgress
                        ? 'Duration ${_elapsedTime(job?.startedAt)}'
                        : 'Waiting for mechanic to start',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.primaryBorder)),
                    child: Text(
                      job?.status == JobStatus.inProgress
                        ? 'In Progress'
                        : 'Ready to start',
                      style: AppTypography.micro.copyWith(
                          color: AppColors.primary),
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              ]),
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
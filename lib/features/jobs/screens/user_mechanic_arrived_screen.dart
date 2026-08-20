// User Mechanic Arrived screen â€” mechanic has arrived at user location.
// Map background, arrival confirmation, confirm job started button.

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
import '../../../shared/widget/notched_nav_bar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:latlong2/latlong.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';

class UserMechanicArrivedScreen extends ConsumerStatefulWidget {
  final String jobId;
  const UserMechanicArrivedScreen({super.key, required this.jobId});

  @override
  ConsumerState<UserMechanicArrivedScreen> createState() =>
      _UserMechanicArrivedScreenState();
}

class _UserMechanicArrivedScreenState
    extends ConsumerState<UserMechanicArrivedScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
  }

  void _confirmStarted() {
    ref.read(jobProvider.notifier).updateStatus(widget.jobId, JobStatus.inProgress);
    context.go(RouteNames.userJobInProgress, extra: widget.jobId);
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
    final userLocation = job?.carOwnerLocation != null
        ? LatLng(job!.carOwnerLocation!.latitude, job.carOwnerLocation!.longitude)
        : const LatLng(6.5244, 3.3792);
    final mechanicLocation = job?.mechanicLocation != null
        ? LatLng(job!.mechanicLocation!.latitude, job.mechanicLocation!.longitude)
        : const LatLng(6.5248, 3.3795);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 15,
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
                    Text('Mechanic Arrived', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text("He's here", style: AppTypography.body.copyWith(
                        color: AppColors.success),
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
                padding: const EdgeInsets.all(AppSpacing.xl2),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0x144CAF50),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: const Color(0x334CAF50))),
                child: Row(children: [
                  Icon(Icons.location_on_rounded,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$mechanicName is here!', style: AppTypography.bodyLarge,
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
                onTap: _confirmStarted,
              ),
            ]),
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
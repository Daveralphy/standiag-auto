// User Mechanic Accepted screen — mechanic has accepted the job.
// Secondary screen — back button, no nav bar, no avatar in header.
// Map background showing mechanic en route.

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
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:latlong2/latlong.dart';
import '../providers/job_provider.dart';

class UserMechanicAcceptedScreen extends ConsumerStatefulWidget {
  final String jobId;
  const UserMechanicAcceptedScreen({super.key, required this.jobId});

  @override
  ConsumerState<UserMechanicAcceptedScreen> createState() =>
      _UserMechanicAcceptedScreenState();
}

class _UserMechanicAcceptedScreenState
    extends ConsumerState<UserMechanicAcceptedScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    HapticFeedback.mediumImpact();
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
    final userLocation = job?.carOwnerLocation != null
        ? LatLng(job!.carOwnerLocation!.latitude, job.carOwnerLocation!.longitude)
        : const LatLng(6.5244, 3.3792);
    final mechanicLocation = job?.mechanicLocation != null
        ? LatLng(job!.mechanicLocation!.latitude, job.mechanicLocation!.longitude)
        : const LatLng(6.5280, 3.3820);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 13.4,
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
                id: 'accepted-route',
                points: [userLocation, mechanicLocation],
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
              child: GestureDetector(
                onTap: () => context.go(RouteNames.userHome),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.borderActive)),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textPrimary)),
              ),
            ),
          ),

          Positioned(
            bottom: 40, left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl2),
                decoration: BoxDecoration(color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  // Success banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x144CAF50),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: const Color(0x334CAF50))),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mechanic accepted!',
                              style: AppTypography.bodyLarge,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                          Text("He's on his way to you",
                              style: AppTypography.caption,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ],
                      )),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    AppAvatar(name: mechanicName, size: 42),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mechanicName, style: AppTypography.heading4,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        Text(job?.issue ?? '',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.primary),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'Live · Tap to track',
                    onTap: () => context.go(RouteNames.userTracking,
                        extra: widget.jobId),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
// Mechanic Post Call screen — after call ends, mechanic decides to accept or reject job.

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

class MechanicPostCallScreen extends ConsumerStatefulWidget {
  final String jobId;
  const MechanicPostCallScreen({super.key, required this.jobId});

  @override
  ConsumerState<MechanicPostCallScreen> createState() =>
      _MechanicPostCallScreenState();
}

class _MechanicPostCallScreenState
    extends ConsumerState<MechanicPostCallScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
  }

  void _reject() {
    ref.read(jobProvider.notifier).updateStatus(widget.jobId, JobStatus.rejected);
    context.go(RouteNames.mechanicHome);
  }

  void _accept() {
    ref.read(jobProvider.notifier).updateStatus(widget.jobId, JobStatus.accepted);
    context.go(RouteNames.mechanicEnRoute, extra: widget.jobId);
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
    const LatLng mechanicLocation = LatLng(6.5282, 3.3822);
    const LatLng userLocation = LatLng(6.5244, 3.3792);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5265, 3.3810),
            initialZoom: 14.2,
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
                  Row(children: [
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
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: AppButton(
                      label: 'Reject Job',
                      onTap: _reject,
                      variant: AppButtonVariant.ghost,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: AppButton(
                      label: 'Accept Job',
                      onTap: _accept,
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
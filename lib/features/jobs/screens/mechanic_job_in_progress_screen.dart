// Mechanic Job In Progress screen — mechanic side during active job.
// Mechanic nav bar, Users active, search icon top right.
// Mark job as done button.

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
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    SystemUiStyle.applyDark();
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
    const LatLng userLocation = LatLng(6.5244, 3.3792);

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5265, 3.3810),
              zoom: 14.6,
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
                    Text('Job In Progress', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Working now', style: AppTypography.body,
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
            activeItem: NavBarItem.third,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}
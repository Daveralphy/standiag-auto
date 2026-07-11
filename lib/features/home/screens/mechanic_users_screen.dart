// Mechanic Users screen — map view showing nearby car owners.
// Nav bar active: Users. Search icon top right.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/jobs/models/job_model.dart';
import '../../../features/jobs/providers/job_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicUsersScreen extends ConsumerStatefulWidget {
  const MechanicUsersScreen({super.key});

  @override
  ConsumerState<MechanicUsersScreen> createState() => _MechanicUsersScreenState();
}

class _MechanicUsersScreenState extends ConsumerState<MechanicUsersScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    const LatLng mechanicUserCenter = LatLng(6.5244, 3.3792);
    final mechanicId = ref.watch(currentUserIdProvider);
    final requests = mechanicId == null
        ? const <JobModel>[]
        : ref.watch(pendingJobsForMechanicProvider(mechanicId)).valueOrNull ??
            const <JobModel>[];
    final markers = {
      for (final job in requests)
        if (job.carOwnerLocation != null)
          buildMapMarker(
            markerId: job.id,
            position: LatLng(
                job.carOwnerLocation!.latitude, job.carOwnerLocation!.longitude),
            icon: buildUserMarkerIcon(),
            infoWindowTitle: job.issue,
          ),
    };
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792),
              zoom: 13.2,
            ),
            markers: markers,
            circles: {
              buildRadiusCircle(
                circleId: 'mechanic-radius',
                center: mechanicUserCenter,
                radiusMeters: 2000,
              ),
            },
            enableCurrentLocation: true,
            showCurrentLocationButton: false,
            showZoomControls: false,
            showCompass: false,
          ),

          // ─── Top gradient ─────────────────────────────────────────────
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

          // ─── Header ──────────────────────────────────────────────────
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nearby Users',
                          style: AppTypography.heading2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Car owners near you',
                          style: AppTypography.body,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  // Search icon
                  Container(
                    width: AppSpacing.iconButtonSize,
                    height: AppSpacing.iconButtonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xB3080808),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border:
                          Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: const Icon(Icons.search_rounded,
                        size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
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
// Mechanic Card screen — shows found mechanic card (locked state).
// Map background, mechanic info card at bottom, Subscribe/Call buttons.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/mechanics_provider.dart';
import '../../jobs/providers/job_provider.dart';

class MechanicCardScreen extends ConsumerStatefulWidget {
  final String mechanicId;
  const MechanicCardScreen({super.key, required this.mechanicId});

  @override
  ConsumerState<MechanicCardScreen> createState() => _MechanicCardScreenState();
}

class _MechanicCardScreenState extends ConsumerState<MechanicCardScreen> {
  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Future<void> _callMechanic() async {
    setState(() => _isCalling = true);
    final carOwnerId = ref.read(currentUserIdProvider);
    if (carOwnerId == null) return;
    final jobId = await ref.read(jobProvider.notifier).createJob(
          carOwnerId: carOwnerId,
          mechanicId: widget.mechanicId,
          vehicleId: '',
          issue: 'General car issue',
        );
    if (!mounted) return;
    context.go(RouteNames.inAppCall, extra: {
      'jobId': jobId,
      'mechanicId': widget.mechanicId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final mechanicAsync = ref.watch(mechanicByIdProvider(widget.mechanicId));
    final mechanicUserAsync = ref.watch(mechanicUserProvider(widget.mechanicId));
    final mechanic = mechanicAsync.valueOrNull;
    final mechanicUser = mechanicUserAsync.valueOrNull;
    final mechanicName = mechanicUser != null
        ? '${mechanicUser.firstName} ${mechanicUser.lastName}'.trim()
        : 'Mechanic';
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792),
              zoom: 13.5,
            ),
            markers: {
              buildMapMarker(
                markerId: 'user-location',
                position: const LatLng(6.5244, 3.3792),
                icon: buildUserMarkerIcon(),
                infoWindowTitle: 'Your location',
              ),
              buildMapMarker(
                markerId: 'mechanic-location',
                position: const LatLng(6.5290, 3.3830),
                icon: buildMechanicMarkerIcon(),
                infoWindowTitle: 'Kwame Asante',
              ),
            },
            polylines: {
              buildDashedRoutePolyline(
                polylineId: 'search-route',
                points: const [
                  LatLng(6.5244, 3.3792),
                  LatLng(6.5290, 3.3830),
                ],
              ),
            },
            enableCurrentLocation: true,
            showCurrentLocationButton: false,
            showZoomControls: false,
            showCompass: false,
          ),

          // Top gradient
          Positioned(
            top: 0, left: 0, right: 0, height: 140,
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

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(RouteNames.userMechanics),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xB3080808),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: const Color(0x1FFFFFFF)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Mechanic Found',
                        style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xB3080808),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: const Icon(Icons.search_rounded,
                        size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Bottom card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 20,
                  AppSpacing.pageHorizontal, 36),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl5)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AppAvatar(name: mechanicName, size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mechanicName,
                                style: AppTypography.heading4,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                RatingStars(
                                    rating: mechanic?.rating ?? 0, starSize: 12),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                      '${(mechanic?.rating ?? 0).toStringAsFixed(1)} · ${mechanic?.totalJobs ?? 0} jobs',
                                      style: AppTypography.caption,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4, runSpacing: 4,
                              children: (mechanic?.expertise ?? const [])
                                  .take(3)
                                  .map((e) => ExpertiseTag(label: e))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusDot(isOnline: true, size: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'View Profile',
                          onTap: () => context.push(RouteNames.mechanicProfile,
                              extra: widget.mechanicId),
                          variant: AppButtonVariant.ghost,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          isLoading: _isCalling,
                          label: 'Call Mechanic',
                          onTap: _callMechanic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
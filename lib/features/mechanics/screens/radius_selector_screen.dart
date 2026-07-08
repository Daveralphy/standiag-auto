// Radius Selector screen — user picks search radius before finding mechanics.
// Full screen map background, bottom sheet with slider, Find button.
// Back button top left, search icon top right.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';

class RadiusSelectorScreen extends StatefulWidget {
  const RadiusSelectorScreen({super.key});

  @override
  State<RadiusSelectorScreen> createState() => _RadiusSelectorScreenState();
}

class _RadiusSelectorScreenState extends State<RadiusSelectorScreen> {
  double _radius = 1.0;
  final LatLng _center = const LatLng(6.5244, 3.3792);

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          LiveMapCanvas(
            initialCameraPosition: CameraPosition(target: _center, zoom: 13.5),
            markers: {
              buildMapMarker(
                markerId: 'search-center',
                position: _center,
                icon: buildDestinationMarkerIcon(),
                infoWindowTitle: 'Search area',
              ),
            },
            circles: {
              buildRadiusCircle(
                circleId: 'search-radius',
                center: _center,
                radiusMeters: _radius * 1000,
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
                    child: Text('Search Radius',
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

          // Bottom sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 24,
                  AppSpacing.pageHorizontal, 40),
              decoration: const BoxDecoration(
                color: Color(0xF0060606),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Search Radius',
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                      Text('${_radius.toStringAsFixed(1)} km',
                          style: AppTypography.heading3.copyWith(
                              color: AppColors.primary),
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.border,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primarySubtle,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _radius,
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      onChanged: (v) => setState(() => _radius = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0.5 km', style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text('10 km', style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Find Nearby Mechanics',
                    onTap: () => context.go(RouteNames.searching),
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
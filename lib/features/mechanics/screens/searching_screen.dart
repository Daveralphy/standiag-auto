// Searching screen — shown while the app searches for nearby mechanics.
// Full screen map, pulsing animation, cancel button at bottom.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/live_map_canvas.dart';
import '../../../shared/widget/system_ui_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/mechanics_provider.dart';

class SearchingScreen extends ConsumerStatefulWidget {
  final double radiusKm;
  const SearchingScreen({super.key, required this.radiusKm});

  @override
  ConsumerState<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends ConsumerState<SearchingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _search();
  }

  Future<void> _search() async {
    setState(() => _notFound = false);
    LatLng? origin;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition();
        origin = LatLng(position.latitude, position.longitude);
      }
    } catch (_) {
      // Fall back to unfiltered results below if location isn't available.
    }

    final mechanics = await ref.refresh(mechanicsProvider.future);
    if (!mounted) return;

    final withinRadius = origin == null
        ? mechanics
        : mechanics.where((m) {
            if (m.location == null) return false;
            final distanceMeters = Geolocator.distanceBetween(
              origin!.latitude,
              origin.longitude,
              m.location!.latitude,
              m.location!.longitude,
            );
            return distanceMeters / 1000 <= widget.radiusKm;
          }).toList();

    final match = withinRadius.isNotEmpty ? withinRadius.first : null;
    if (!mounted) return;
    if (match == null) {
      setState(() => _notFound = true);
      return;
    }
    context.go(RouteNames.mechanicCard, extra: match.uid);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          const LiveMapCanvas(
            initialCameraPosition: CameraPosition(
              target: LatLng(6.5244, 3.3792),
              zoom: 13.5,
            ),
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
                    onTap: () => context.go(RouteNames.radiusSelector),
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
                    child: Text('Searching...',
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

          // Pulsing search indicator
          Center(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySubtle,
                  border: Border.all(color: AppColors.primaryBorder, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33E8281E),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.search_rounded,
                    color: AppColors.primary, size: 40),
              ),
            ),
          ),

          // Bottom
          Positioned(
            bottom: 40, left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Column(
              children: [
                Text(
                  _notFound
                      ? 'No mechanics found within ${widget.radiusKm.toStringAsFixed(0)} km.'
                      : 'Searching within ${widget.radiusKm.toStringAsFixed(0)} km...',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, maxLines: 2,
                ),
                const SizedBox(height: 20),
                if (_notFound)
                  AppButton(label: 'Try Again', onTap: _search)
                else
                  AppButton(
                    label: 'Cancel Search',
                    onTap: () => context.go(RouteNames.userMechanics),
                    variant: AppButtonVariant.ghost,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
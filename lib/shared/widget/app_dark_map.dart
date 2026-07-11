// Free, no-API-key dark-mode map used by the two nav-tab map screens
// (User Mechanics tab, Mechanic Users tab). Google Maps requires a billed
// API key to render tiles/places — since that isn't configured here and the
// map was failing to render, this uses flutter_map with CARTO's free dark
// basemap tiles instead. No account, no key, no billing.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

/// A single pin on [AppDarkMap]. [child] is the marker's visual (an icon in
/// a colored circle, matching the rest of the app's iconography) rather
/// than a raw asset, so callers never need platform-specific marker images.
class AppDarkMapMarker {
  final String id;
  final LatLng position;
  final Widget child;
  final VoidCallback? onTap;

  const AppDarkMapMarker({
    required this.id,
    required this.position,
    required this.child,
    this.onTap,
  });
}

class AppDarkMap extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<AppDarkMapMarker> markers;

  /// Optional radius circle (meters) drawn around [initialCenter] or, once
  /// resolved, the device's real location.
  final double? radiusMeters;

  const AppDarkMap({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13.5,
    this.markers = const [],
    this.radiusMeters,
  });

  @override
  State<AppDarkMap> createState() => _AppDarkMapState();
}

class _AppDarkMapState extends State<AppDarkMap> {
  final MapController _controller = MapController();
  LatLng? _currentLocation;
  bool _isResolvingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isResolvingLocation = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = location;
        _isResolvingLocation = false;
      });
      _controller.move(location, widget.initialZoom);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isResolvingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentLocation ?? widget.initialCenter;
    final circleCenter = _currentLocation ?? widget.initialCenter;

    return Container(
      // Paints dark immediately, before FlutterMap or any tile has a chance
      // to render — this is what was causing the white flash: FlutterMap's
      // own canvas (and the tile placeholder) default to white/transparent,
      // which shows through onto whatever's behind it during that gap.
      color: AppColors.mapBackground,
      child: Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: center,
            initialZoom: widget.initialZoom,
            backgroundColor: AppColors.mapBackground,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.standiagauto.standiag_auto',
              maxZoom: 20,
              errorTileCallback: (tile, error, stackTrace) {},
            ),
            if (widget.radiusMeters != null)
              CircleLayer(circles: [
                CircleMarker(
                  point: circleCenter,
                  radius: widget.radiusMeters!,
                  useRadiusInMeter: true,
                  color: AppColors.primarySubtle,
                  borderColor: AppColors.primaryBorder,
                  borderStrokeWidth: 2,
                ),
              ]),
            MarkerLayer(markers: [
              if (_currentLocation != null)
                Marker(
                  point: _currentLocation!,
                  width: 22,
                  height: 22,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              for (final marker in widget.markers)
                Marker(
                  point: marker.position,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: marker.onTap,
                    child: marker.child,
                  ),
                ),
            ]),
            const RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors © CARTO'),
              ],
            ),
          ],
        ),
        IgnorePointer(
          ignoring: true,
          child: AnimatedOpacity(
            opacity: _isResolvingLocation ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              alignment: Alignment.center,
              child: Container(
                width: 160,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Loading map…',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

/// A ready-made mechanic/user pin matching the app's marker iconography —
/// used as [AppDarkMapMarker.child] so screens don't hand-roll marker art.
class AppDarkMapPin extends StatelessWidget {
  final IconData icon;
  const AppDarkMapPin({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A2A),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary, size: 18),
    );
  }
}

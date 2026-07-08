// Reusable Google Map canvas with optional current-location tracking and route overlays.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';

class LiveMapCanvas extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final Set<Polyline> polylines;
  final bool enableCurrentLocation;
  final bool showCurrentLocationButton;
  final bool showZoomControls;
  final bool showCompass;
  final EdgeInsets mapPadding;
  final ValueChanged<GoogleMapController>? onMapCreated;

  const LiveMapCanvas({
    super.key,
    required this.initialCameraPosition,
    this.markers = const {},
    this.circles = const {},
    this.polylines = const {},
    this.enableCurrentLocation = true,
    this.showCurrentLocationButton = false,
    this.showZoomControls = false,
    this.showCompass = false,
    this.mapPadding = EdgeInsets.zero,
    this.onMapCreated,
  });

  @override
  State<LiveMapCanvas> createState() => _LiveMapCanvasState();
}

class _LiveMapCanvasState extends State<LiveMapCanvas> {
  GoogleMapController? _controller;
  LatLng? _currentLocation;
  bool _isResolvingLocation = true;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final LocationPermission permission = await Geolocator.checkPermission();
      LocationPermission resolved = permission;

      if (permission == LocationPermission.denied) {
        resolved = await Geolocator.requestPermission();
      }

      if (resolved == LocationPermission.denied ||
          resolved == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationPermissionGranted = false;
          _isResolvingLocation = false;
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      final LatLng location = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = location;
        _locationPermissionGranted = true;
        _isResolvingLocation = false;
      });
      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 14.5),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationPermissionGranted = false;
        _isResolvingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = _currentLocation == null
        ? widget.initialCameraPosition
        : CameraPosition(
            target: _currentLocation!,
            zoom: widget.initialCameraPosition.zoom,
            tilt: widget.initialCameraPosition.tilt,
            bearing: widget.initialCameraPosition.bearing,
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: initialPosition,
          markers: widget.markers,
          circles: widget.circles,
          polylines: widget.polylines,
          myLocationEnabled: widget.enableCurrentLocation &&
              _locationPermissionGranted,
          myLocationButtonEnabled:
              widget.enableCurrentLocation && widget.showCurrentLocationButton,
          zoomControlsEnabled: widget.showZoomControls,
          compassEnabled: widget.showCompass,
          mapToolbarEnabled: false,
          trafficEnabled: false,
          buildingsEnabled: true,
          indoorViewEnabled: false,
          mapType: MapType.normal,
          liteModeEnabled: false,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          padding: widget.mapPadding,
          onMapCreated: (controller) {
            _controller = controller;
            widget.onMapCreated?.call(controller);
          },
        ),
        IgnorePointer(
          ignoring: true,
          child: AnimatedOpacity(
            opacity: _isResolvingLocation ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: const _MapLoadingPill(),
            ),
          ),
        ),
        if (!_locationPermissionGranted && _currentLocation == null)
          Positioned(
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            bottom: AppSpacing.xxl,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Current location unavailable. Showing the last known map area.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
      ],
    );
  }
}

class _MapLoadingPill extends StatelessWidget {
  const _MapLoadingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    );
  }
}

LatLng latLngFromGeoPoint(dynamic geoPoint) {
  if (geoPoint is LatLng) {
    return geoPoint;
  }
  if (geoPoint is Map<String, dynamic>) {
    final double? lat = (geoPoint['latitude'] as num?)?.toDouble();
    final double? lng = (geoPoint['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
  }
  return const LatLng(6.5244, 3.3792);
}

Marker buildMapMarker({
  required String markerId,
  required LatLng position,
  required BitmapDescriptor icon,
  double? rotation,
  bool consumeTapEvents = false,
  VoidCallback? onTap,
  String? infoWindowTitle,
}) {
  return Marker(
    markerId: MarkerId(markerId),
    position: position,
    icon: icon,
    rotation: rotation ?? 0,
    consumeTapEvents: consumeTapEvents,
    infoWindow: InfoWindow(title: infoWindowTitle),
    onTap: onTap,
    anchor: const Offset(0.5, 0.5),
  );
}

BitmapDescriptor buildUserMarkerIcon() {
  return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
}

BitmapDescriptor buildMechanicMarkerIcon() {
  return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
}

BitmapDescriptor buildDestinationMarkerIcon() {
  return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
}

Polyline buildDashedRoutePolyline({
  required String polylineId,
  required List<LatLng> points,
  Color color = AppColors.blue,
}) {
  return Polyline(
    polylineId: PolylineId(polylineId),
    points: points,
    color: color.withValues(alpha: 0.85),
    width: 5,
    patterns: [PatternItem.dash(16), PatternItem.gap(8)],
    geodesic: true,
  );
}

Circle buildRadiusCircle({
  required String circleId,
  required LatLng center,
  required double radiusMeters,
}) {
  return Circle(
    circleId: CircleId(circleId),
    center: center,
    radius: radiusMeters,
    fillColor: AppColors.primarySubtle,
    strokeColor: AppColors.primaryBorder,
    strokeWidth: 2,
  );
}
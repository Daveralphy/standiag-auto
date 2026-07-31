// The one map widget used everywhere in the app — nearby-mechanic/user
// discovery, job tracking, radius selection. Free, no API key, no billing:
// CARTO's "Positron" vector style, served with no account needed from
// CARTO's public basemap CDN. Vector tiles render sharp at any zoom instead
// of the blurry, low-detail look of raster PNG tiles — that sharpness is
// the whole reason this exists instead of google_maps_flutter, which also
// needs a properly billed API key per platform to render at all.
//
// The style is fetched once per app run and cached in _PositronStyleCache —
// without this, every remount (switching tabs and back) would re-fetch and
// re-parse the whole style from scratch, which is most of what made the map
// feel slow to appear on every visit.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' show ThemeReader;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

/// A single pin on [AppMap]. [child] is the marker's visual (an icon in a
/// colored circle, matching the rest of the app's iconography) rather than
/// a raw bitmap, so callers never need platform-specific marker images.
class AppMapMarker {
  final String id;
  final LatLng position;
  final Widget child;
  final VoidCallback? onTap;

  const AppMapMarker({
    required this.id,
    required this.position,
    required this.child,
    this.onTap,
  });
}

/// A dashed route line between two or more points (e.g. user ↔ mechanic).
class AppMapPolyline {
  final String id;
  final List<LatLng> points;
  final Color color;

  const AppMapPolyline({
    required this.id,
    required this.points,
    this.color = AppColors.blue,
  });
}

/// A radius circle, e.g. a mechanic's service-area preview on the map.
class AppMapCircle {
  final String id;
  final LatLng center;
  final double radiusMeters;

  const AppMapCircle({
    required this.id,
    required this.center,
    required this.radiusMeters,
  });
}

class AppMap extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<AppMapMarker> markers;
  final List<AppMapPolyline> polylines;
  final List<AppMapCircle> circles;

  /// Whether to resolve and show the device's real GPS position, and
  /// auto-center the camera on it once resolved.
  final bool enableCurrentLocation;

  /// Whether to show the floating zoom/compass/recenter control column.
  final bool showMapControls;

  const AppMap({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13.5,
    this.markers = const [],
    this.polylines = const [],
    this.circles = const [],
    this.enableCurrentLocation = true,
    this.showMapControls = true,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final MapController _controller = MapController();
  StreamSubscription<MapEvent>? _mapEventSub;
  LatLng? _currentLocation;
  bool _isResolvingLocation = true;
  bool _locationPermissionGranted = false;
  bool _isRecentering = false;
  Style? _vectorStyle;
  double _rotation = 0;
  bool _hasCenteredOnFix = false;

  @override
  void initState() {
    super.initState();
    // Every AppMap this app session (across screens and tab switches) shares
    // one last-known GPS fix — a fresh instance shows it immediately instead
    // of sitting on the loading pill through another full GPS resolve, which
    // is most of what made the map feel like it was "reloading" on every
    // navigation even though nothing actually changed.
    final cached = _LastKnownLocation.value;
    if (cached != null) {
      _currentLocation = cached;
      _locationPermissionGranted = true;
      _isResolvingLocation = false;
      _hasCenteredOnFix = true;
    }
    if (widget.enableCurrentLocation) {
      _loadCurrentLocation();
    } else if (cached == null) {
      _isResolvingLocation = false;
    }
    _loadVectorStyle();
    _mapEventSub = _controller.mapEventStream.listen((_) {
      final rotation = _controller.camera.rotation;
      if (rotation != _rotation && mounted) {
        setState(() => _rotation = rotation);
      }
    });
  }

  @override
  void dispose() {
    _mapEventSub?.cancel();
    super.dispose();
  }

  /// Loads (or reuses the cached) CARTO "Positron" vector style. On any
  /// failure (no network, style temporarily unreachable) [_vectorStyle]
  /// simply stays null and the map falls back to the raster CARTO tiles
  /// below — never a blank map, just a lower-detail one until the vector
  /// style is available.
  Future<void> _loadVectorStyle() async {
    try {
      final style = await _PositronStyleCache.load();
      if (!mounted) return;
      setState(() => _vectorStyle = style);
    } catch (_) {
      // Fall back to the raster tile layer — no error state needed here.
    }
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
        setState(() {
          _locationPermissionGranted = false;
          _isResolvingLocation = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final location = LatLng(position.latitude, position.longitude);
      _LastKnownLocation.value = location;
      setState(() {
        _currentLocation = location;
        _locationPermissionGranted = true;
        _isResolvingLocation = false;
      });
      // Only snap the camera to this fix the first time one lands for this
      // instance — a cached fix from a previous screen has already centered
      // it, and re-centering on every later refresh would fight the user's
      // own panning/zooming.
      if (!_hasCenteredOnFix) {
        _hasCenteredOnFix = true;
        _controller.move(location, widget.initialZoom);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationPermissionGranted = false;
        _isResolvingLocation = false;
      });
    }
  }

  void _zoomBy(double delta) {
    final camera = _controller.camera;
    _controller.move(camera.center, (camera.zoom + delta).clamp(3, 20));
  }

  void _resetNorth() => _controller.rotate(0);

  Future<void> _recenterOnMe() async {
    if (_currentLocation != null) {
      _controller.move(_currentLocation!, _controller.camera.zoom);
      return;
    }
    setState(() => _isRecentering = true);
    await _loadCurrentLocation();
    if (!mounted) return;
    setState(() => _isRecentering = false);
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentLocation ?? widget.initialCenter;

    return Container(
      // Paints the Positron background tone immediately, before FlutterMap
      // or any tile has a chance to render, so there's no white/blank flash
      // during that gap.
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
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              _buildTileLayer(context),
              if (widget.circles.isNotEmpty)
                CircleLayer(
                  circles: [
                    for (final circle in widget.circles)
                      CircleMarker(
                        point: circle.center,
                        radius: circle.radiusMeters,
                        useRadiusInMeter: true,
                        color: AppColors.primarySubtle,
                        borderColor: AppColors.primaryBorder,
                        borderStrokeWidth: 1.5,
                      ),
                  ],
                ),
              if (widget.polylines.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    for (final line in widget.polylines)
                      Polyline(
                        points: line.points,
                        color: line.color.withValues(alpha: 0.85),
                        strokeWidth: 4,
                        pattern: StrokePattern.dashed(segments: const [16, 8]),
                      ),
                  ],
                ),
              MarkerLayer(markers: [
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 64,
                    height: 64,
                    child: const _UserLocationPin(),
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
                child: const _MapLoadingPill(),
              ),
            ),
          ),
          if (widget.enableCurrentLocation &&
              !_locationPermissionGranted &&
              _currentLocation == null &&
              !_isResolvingLocation)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.95),
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

          // ─── Map controls — zoom, compass, locate-me ───────────────────
          // Vertically centered on the right edge so nothing screen-specific
          // (a bottom CTA, the floating nav bar) can ever cover it.
          if (widget.showMapControls)
            Positioned(
              top: 0,
              bottom: 0,
              right: 12,
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_rotation.abs() > 0.5) ...[
                      _MapControlButton(
                        onTap: _resetNorth,
                        child: Transform.rotate(
                          angle: -_rotation * 3.1415926535 / 180,
                          child: const Icon(Icons.explore_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    _MapControlButton(
                      onTap: () => _zoomBy(1),
                      child: const Icon(Icons.add_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                    const SizedBox(height: 8),
                    _MapControlButton(
                      onTap: () => _zoomBy(-1),
                      child: const Icon(Icons.remove_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                    if (widget.enableCurrentLocation) ...[
                      const SizedBox(height: 8),
                      _MapControlButton(
                        onTap: _isRecentering ? null : _recenterOnMe,
                        child: _isRecentering
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              )
                            : const Icon(Icons.my_location_rounded,
                                color: AppColors.primary, size: 18),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Vector tiles once the Positron style has loaded; the old raster CARTO
  /// tiles as an immediate placeholder while it loads and as a permanent
  /// fallback if it never does (e.g. no network).
  Widget _buildTileLayer(BuildContext context) {
    final style = _vectorStyle;
    if (style != null) {
      return VectorTileLayer(
        tileProviders: style.providers,
        theme: style.theme,
        sprites: style.sprites,
        maximumZoom: 22,
        tileOffset: TileOffset.mapbox,
        // A higher substitution difference means the layer more readily
        // shows an already-loaded tile from a nearby zoom level while the
        // exact one is still loading, instead of leaving that area blank.
        maximumTileSubstitutionDifference: 3,
      );
    }
    return TileLayer(
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      subdomains: const ['a', 'b', 'c', 'd'],
      userAgentPackageName: 'com.standiagauto.standiag_auto',
      maxZoom: 20,
      retinaMode: RetinaMode.isHighDensity(context),
      errorTileCallback: (tile, error, stackTrace) {},
    );
  }
}

/// The most recent GPS fix from any [AppMap] instance this app session —
/// shared so a new instance (a fresh screen, a tab switch that rebuilds its
/// route) starts centered on it immediately instead of sitting on
/// [widget.initialCenter] and the loading pill through another full GPS
/// resolve every single time.
class _LastKnownLocation {
  _LastKnownLocation._();
  static LatLng? value;
}

/// Fetches CARTO's Positron style once per app run and caches the result so
/// every [AppMap] instance for the rest of this app session reuses it
/// instantly instead of re-fetching and re-parsing the whole style from
/// scratch on every remount.
class _PositronStyleCache {
  _PositronStyleCache._();

  static const _uri =
      'https://tiles.basemaps.cartocdn.com/gl/positron-gl-style/style.json';

  static Future<Style>? _future;

  static Future<Style> load() => _future ??= _load();

  static Future<Style> _load() async {
    final base = await StyleReader(uri: _uri).read();
    try {
      // Normalize the literal "transparent" keyword some CARTO layers use —
      // the renderer's color parser only understands hex/rgba forms, not
      // the CSS keyword. Left as-is, tiles touching those layers throw a
      // parse exception on every paint, causing black patches and dropped
      // frames while zooming.
      final response = await http.get(Uri.parse(_uri));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _normalizeTransparent(decoded);
          final theme = ThemeReader().read(decoded);
          return Style(
            name: base.name,
            theme: theme,
            providers: base.providers,
            sprites: base.sprites,
            center: base.center,
            zoom: base.zoom,
          );
        }
      }
    } catch (_) {
      // Fall through to the unmodified style below.
    }
    return base;
  }

  static void _normalizeTransparent(Map<String, dynamic> style) {
    final layers = style['layers'];
    if (layers is! List) return;
    for (final layer in layers) {
      if (layer is! Map) continue;
      final paint = layer['paint'];
      if (paint is! Map) continue;
      for (final key in paint.keys.toList()) {
        paint[key] = _replaceTransparent(paint[key]);
      }
    }
  }

  static dynamic _replaceTransparent(dynamic value) {
    if (value is String) {
      return value.trim().toLowerCase() == 'transparent'
          ? 'rgba(0,0,0,0)'
          : value;
    }
    if (value is List) {
      return value.map(_replaceTransparent).toList();
    }
    return value;
  }
}

/// A small circular control button matching the app's map-pin iconography —
/// used for the zoom in/out, compass and locate-me buttons. Deliberately
/// dark regardless of the light map underneath, matching the rest of the
/// app's floating dark UI chrome.
class _MapControlButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _MapControlButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xE1141414),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x40000000), blurRadius: 6),
          ],
        ),
        child: child,
      ),
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

/// The device's own position on the map — a soft glow ring, a mid ring, a
/// solid core and a white center dot, matching the "user pin" used
/// throughout the design's map screens (radial glow + layered circles).
class _UserLocationPin extends StatelessWidget {
  const _UserLocationPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.35),
                AppColors.primary.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.18),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// A ready-made marker pin matching the app's iconography — used as
/// [AppMapMarker.child] so screens don't hand-roll marker art. [color]
/// distinguishes marker types (e.g. mechanic vs destination) at a glance.
class AppMapPin extends StatelessWidget {
  final IconData icon;
  final Color color;

  const AppMapPin({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A2A),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

/// Extracts a [LatLng] from a Firestore GeoPoint-shaped value, falling back
/// to Lagos (the app's reference city) if it can't be parsed.
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

/// Marker icon for a car owner's own location — matches the discovery
/// screens' person iconography.
Widget buildUserMarkerIcon() =>
    const AppMapPin(icon: Icons.person_rounded, color: AppColors.primary);

/// Marker icon for a mechanic's location — matches the discovery screens'
/// wrench iconography.
Widget buildMechanicMarkerIcon() =>
    const AppMapPin(icon: Icons.build_rounded, color: AppColors.blue);

/// Marker icon for a fixed destination/search-center point.
Widget buildDestinationMarkerIcon() =>
    const AppMapPin(icon: Icons.place_rounded, color: AppColors.success);

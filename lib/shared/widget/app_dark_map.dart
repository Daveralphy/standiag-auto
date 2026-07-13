// Free, no-API-key dark-mode map used by the two nav-tab map screens
// (User Mechanics tab, Mechanic Users tab). Google Maps requires a billed
// API key to render tiles/places — since that isn't configured here and the
// map was failing to render, this uses flutter_map instead. No account, no
// key, no billing.
//
// Tiles are vector — CARTO's own "Dark Matter" GL style, served free with no
// API key from CARTO's public basemap CDN — rather than raster, so they're
// sharp at any zoom instead of the blurry, low-detail look of plain PNG
// tiles. Dark Matter is meant as a quiet data-viz underlay, so several of
// its label colors are deliberately dim; those are brightened once here (see
// _brightenStyleJson) so place/road names are actually readable on their
// own, not just as a backdrop for other data. If the style fails to load
// (e.g. no network yet), this falls back to CARTO's free raster dark tiles
// so the map is never left blank — same free/no-key guarantee either way.
//
// The style (and its brightened theme) is fetched once per app run and
// cached in _DarkMatterStyleCache — without this, every time this widget
// remounts (e.g. switching tabs and back) it would re-fetch and re-parse the
// whole style from scratch, which is most of what made the map feel slow to
// appear on every visit.

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
  StreamSubscription<MapEvent>? _mapEventSub;
  LatLng? _currentLocation;
  bool _isResolvingLocation = true;
  bool _isRecentering = false;
  Style? _vectorStyle;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
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

  /// Loads (or reuses the cached) CARTO "Dark Matter" vector style. On any
  /// failure (no network, style temporarily unreachable) [_vectorStyle]
  /// simply stays null and the map falls back to the raster CARTO tiles
  /// below — never a blank map, just a lower-detail one until the vector
  /// style is available.
  Future<void> _loadVectorStyle() async {
    try {
      final style = await _DarkMatterStyleCache.load();
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
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            _buildTileLayer(context),
            if (widget.radiusMeters != null)
              CircleLayer(circles: [
                CircleMarker(
                  point: circleCenter,
                  radius: widget.radiusMeters!,
                  useRadiusInMeter: true,
                  color: const Color(0x00000000),
                  borderColor: AppColors.primaryBorder,
                  borderStrokeWidth: 1.5,
                ),
              ]),
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

        // ─── Map controls — zoom, compass, locate-me ───────────────────
        // Vertically centered on the right edge so nothing screen-specific
        // (a bottom CTA, the floating nav bar) can ever cover it.
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
            ),
          ),
        ),
      ],
      ),
    );
  }

  /// Vector tiles once the Dark Matter style has loaded; the old raster
  /// CARTO tiles as an immediate placeholder while it loads and as a
  /// permanent fallback if it never does (e.g. no network).
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
        // exact one is still loading, instead of leaving that area blank —
        // directly addresses the "empty patches while panning" symptom.
        maximumTileSubstitutionDifference: 3,
      );
    }
    return TileLayer(
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      subdomains: const ['a', 'b', 'c', 'd'],
      userAgentPackageName: 'com.standiagauto.standiag_auto',
      maxZoom: 20,
      retinaMode: RetinaMode.isHighDensity(context),
      errorTileCallback: (tile, error, stackTrace) {},
    );
  }
}

/// Fetches CARTO's Dark Matter style once per app run, brightens its dim
/// label colors, and caches the result so every [AppDarkMap] instance for
/// the rest of this app session reuses it instantly instead of re-fetching
/// and re-parsing the whole style from scratch on every remount.
class _DarkMatterStyleCache {
  _DarkMatterStyleCache._();

  static const _uri =
      'https://tiles.basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

  static Future<Style>? _future;

  static Future<Style> load() => _future ??= _load();

  static Future<Style> _load() async {
    // StyleReader resolves the theme, tile providers and sprites from the
    // style — reused as-is except the theme, which we rebuild from a
    // brightened copy of the same style JSON.
    final base = await StyleReader(uri: _uri).read();
    try {
      final response = await http.get(Uri.parse(_uri));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final brightened = _brightenStyleJson(decoded);
          final theme = ThemeReader().read(brightened);
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
      // Fall through to the unmodified style below — dim labels beat no
      // vector map at all.
    }
    return base;
  }

  /// Dark Matter is designed as a quiet underlay for data visualization, so
  /// many of its text-color paint values are deliberately dim greys (some
  /// as dark as #383838 on a near-black background). This lifts any label
  /// color that's too dim up to a comfortably readable brightness, while
  /// leaving already-bright labels and all halo/outline colors untouched.
  ///
  /// It also normalizes every literal "transparent" keyword found in any
  /// paint property to "rgba(0,0,0,0)" — the renderer's color parser only
  /// understands hex/rgba forms, not the CSS keyword, and Dark Matter uses
  /// "transparent" for at least its house-number layer. Left as-is, every
  /// tile touching that layer throws a parse exception on every paint,
  /// which is what caused the black patches and frame drops while zooming.
  static Map<String, dynamic> _brightenStyleJson(Map<String, dynamic> style) {
    final layers = style['layers'];
    if (layers is! List) return style;
    for (final layer in layers) {
      if (layer is! Map) continue;
      final paint = layer['paint'];
      if (paint is! Map) continue;
      for (final key in paint.keys.toList()) {
        // Normalize first (handles both plain strings and "transparent"
        // nested inside zoom-interpolation expression arrays), then apply
        // label brightening only to a plain text-color string.
        final normalized = _replaceTransparent(paint[key]);
        paint[key] = normalized;
        if (layer['type'] == 'symbol' && key == 'text-color' && normalized is String) {
          final brightened = _brightenColor(normalized);
          if (brightened != null) paint[key] = brightened;
        }
      }
    }
    return style;
  }

  /// Recursively replaces the literal "transparent" keyword with a
  /// "rgba(0,0,0,0)" equivalent the color parser actually understands —
  /// walks into expression arrays (e.g. zoom interpolations) too, since
  /// "transparent" can appear as one branch of those instead of a bare
  /// string value.
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

  /// Only handles plain "#rgb"/"#rrggbb"/"rgba(r,g,b,a)" strings — anything
  /// else (zoom-interpolated expressions etc.) is left untouched rather
  /// than risk corrupting a value we can't safely parse.
  static String? _brightenColor(String input) {
    final rgb = _parseColor(input.trim());
    if (rgb == null) return null;
    final luminance = 0.299 * rgb.$1 + 0.587 * rgb.$2 + 0.114 * rgb.$3;
    const targetLuminance = 210.0;
    if (luminance >= 175) return null; // already bright enough
    final scale = luminance <= 0 ? 4.0 : (targetLuminance / luminance).clamp(1.0, 4.0);
    int scaled(int c) => (c * scale).round().clamp(0, 255);
    return 'rgba(${scaled(rgb.$1)}, ${scaled(rgb.$2)}, ${scaled(rgb.$3)}, 1)';
  }

  static (int, int, int)? _parseColor(String s) {
    if (s.startsWith('#')) {
      final hex = s.substring(1);
      if (hex.length == 3) {
        return (
          int.parse(hex[0] * 2, radix: 16),
          int.parse(hex[1] * 2, radix: 16),
          int.parse(hex[2] * 2, radix: 16),
        );
      }
      if (hex.length == 6) {
        return (
          int.parse(hex.substring(0, 2), radix: 16),
          int.parse(hex.substring(2, 4), radix: 16),
          int.parse(hex.substring(4, 6), radix: 16),
        );
      }
      return null;
    }
    final match =
        RegExp(r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)').firstMatch(s);
    if (match == null) return null;
    return (
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}

/// A small circular control button matching the app's map-pin iconography —
/// used for the zoom in/out, compass and locate-me buttons.
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

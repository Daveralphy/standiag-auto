import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import 'mechanic_profile_screen.dart';

class MechanicsScreen extends StatefulWidget {
  const MechanicsScreen({super.key});

  @override
  State<MechanicsScreen> createState() => _MechanicsScreenState();
}

class _MechanicsScreenState extends State<MechanicsScreen> {
  List<Map<String, dynamic>> _mechanics = [];
  bool _loading = true;
  String _activeFilter = 'All';
  final _filters = ['All', 'Featured', 'Online', 'Nearby'];
  Position? _userPosition;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadMechanics();
    _getUserLocation();
  }

  Future<void> _loadMechanics() async {
    final json =
        await rootBundle.loadString('assets/data/mechanics.json');
    final data = jsonDecode(json);
    if (mounted) {
      setState(() {
        _mechanics =
            List<Map<String, dynamic>>.from(data['mechanics']);
        _loading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() => _userPosition = position);
        // Move map to user location
        _mapController.move(
            LatLng(position.latitude, position.longitude), 12.0);
      }
    } catch (_) {}
  }

  double _distanceTo(Map<String, dynamic> mechanic) {
    if (_userPosition == null) return -1;
    final lat = (mechanic['latitude'] as num).toDouble();
    final lng = (mechanic['longitude'] as num).toDouble();
    return Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          lat,
          lng,
        ) /
        1000; // km
  }

  String _distanceLabel(Map<String, dynamic> mechanic) {
    final d = _distanceTo(mechanic);
    if (d < 0) return '';
    if (d < 1) return '${(d * 1000).round()}m away';
    return '${d.toStringAsFixed(1)}km away';
  }

  List<Map<String, dynamic>> get _filtered {
    List<Map<String, dynamic>> list;
    switch (_activeFilter) {
      case 'Featured':
        list = _mechanics
            .where((m) => m['is_featured'] == true)
            .toList();
        break;
      case 'Online':
        list = _mechanics
            .where((m) => m['is_online'] == true)
            .toList();
        break;
      case 'Nearby':
        list = List.from(_mechanics);
        if (_userPosition != null) {
          list.sort((a, b) =>
              _distanceTo(a).compareTo(_distanceTo(b)));
        }
        break;
      default:
        list = List.from(_mechanics);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 12),
                        _buildMap(),
                        const SizedBox(height: 16),
                        _buildFilterChips(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final m = _filtered[i];
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 12),
                            child: _MechanicCard(
                              mechanic: m,
                              distanceLabel:
                                  _distanceLabel(m),
                              onTap: () =>
                                  Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MechanicProfileScreen(
                                          mechanic: m),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _filtered.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Find a Mechanic',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(
            _userPosition != null
                ? '${_mechanics.length} mechanics near you'
                : '${_mechanics.length} mechanics in Lagos',
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_mechanics.isEmpty) return const SizedBox.shrink();

    // Default to Lagos center, move to user when available
    final center = _userPosition != null
        ? LatLng(
            _userPosition!.latitude, _userPosition!.longitude)
        : const LatLng(6.5244, 3.3792);

    // Mechanic markers
    final mechanicMarkers = _mechanics.map((mechData) {
      final m = Map<String, dynamic>.from(mechData);
      final lat = (m['latitude'] as num).toDouble();
      final lng = (m['longitude'] as num).toDouble();
      final isOnline = m['is_online'] == true;

      return Marker(
        point: LatLng(lat, lng),
        width: 40,
        height: 48,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  MechanicProfileScreen(mechanic: m),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.primary
                      : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary, width: 2),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary
                          .withValues(alpha: 0.4),
                      blurRadius: 8)],
                ),
                child: Center(
                  child: Text(m['initials'] ?? '',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isOnline
                              ? Colors.white
                              : AppColors.primary,
                          fontFamily: 'Inter')),
                ),
              ),
              Container(width: 2, height: 8,
                  color: AppColors.primary),
            ],
          ),
        ),
      );
    }).toList();

    // User location marker (blue dot)
    final userMarkers = _userPosition != null
        ? [
            Marker(
              point: LatLng(_userPosition!.latitude,
                  _userPosition!.longitude),
              width: 24,
              height: 24,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(
                      color: const Color(0xFF4A90E2)
                          .withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2)],
                ),
              ),
            ),
          ]
        : <Marker>[];

    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.davelop.standiag_auto',
              ),
              MarkerLayer(
                  markers: [...userMarkers, ...mechanicMarkers]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _filters[i] == _activeFilter;
          return GestureDetector(
            onTap: () =>
                setState(() => _activeFilter = _filters[i]),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border),
              ),
              child: Text(_filters[i],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ),
          );
        },
      ),
    );
  }
}

// ── MECHANIC CARD ─────────────────────────────────────────────
class _MechanicCard extends StatelessWidget {
  final Map<String, dynamic> mechanic;
  final String distanceLabel;
  final VoidCallback onTap;

  const _MechanicCard({
    required this.mechanic,
    required this.distanceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = mechanic['is_online'] == true;
    final isFeatured = mechanic['is_featured'] == true;
    final rating =
        (mechanic['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = mechanic['review_count'] ?? 0;
    final specs =
        List<String>.from(mechanic['specialisations'] ?? []);
    final avatarColor = Color(
        int.parse('FF${mechanic['avatar_color']}', radix: 16));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isFeatured
                  ? AppColors.primaryBorder
                  : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primaryBorder,
                        width: 1.5),
                  ),
                  child: Center(
                    child: Text(mechanic['initials'] ?? '',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Inter')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(mechanic['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'Inter')),
                        if (isFeatured) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                            child: const Text('TOP',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight:
                                        FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Inter')),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 2),
                      Row(children: [
                        Flexible(
                          child: Text(
                            mechanic['location'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter'),
                          ),
                        ),
                        if (distanceLabel.isNotEmpty) ...[
                          const Text('  •  ',
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppColors.textTertiary)),
                          Flexible(
                            child: Text(
                              distanceLabel,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.advisoryBg
                            : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(100),
                        border: Border.all(
                            color: isOnline
                                ? AppColors.advisoryBorder
                                : AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOnline
                                  ? AppColors.advisory
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isOnline
                                    ? AppColors.advisory
                                    : AppColors.textTertiary,
                                fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF5A623), size: 13),
                      const SizedBox(width: 3),
                      Text('$rating ($reviewCount)',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
                    ]),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: specs.take(3).map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDeep,
                      borderRadius: BorderRadius.circular(100),
                      border:
                          Border.all(color: AppColors.border),
                    ),
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  )).toList(),
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.work_outline_rounded,
                  color: AppColors.textTertiary, size: 13),
              const SizedBox(width: 4),
              Text('${mechanic['jobs_done']} jobs done',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter')),
              const SizedBox(width: 12),
              const Icon(Icons.flash_on_rounded,
                  color: AppColors.textTertiary, size: 13),
              const SizedBox(width: 4),
              Text('${mechanic['response_speed']} response',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter')),
            ]),
          ],
        ),
      ),
    );
  }
}







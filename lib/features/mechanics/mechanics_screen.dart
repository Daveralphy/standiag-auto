import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/vehicle_provider.dart';
import 'mechanic_profile_screen.dart';

class MechanicsScreen extends ConsumerStatefulWidget {
  const MechanicsScreen({super.key});

  @override
  ConsumerState<MechanicsScreen> createState() =>
      _MechanicsScreenState();
}

enum _SearchState {
  idle,       // Initial state — show Find button
  searching,  // Ripple + mechanics appearing
  offered,    // Mechanic has offered — show slide-in card
}

class _MechanicsScreenState extends ConsumerState<MechanicsScreen>
    with TickerProviderStateMixin {
  // Map
  final _mapController = MapController();
  Position? _userPosition;

  // Mechanics data
  List<Map<String, dynamic>> _allMechanics = [];
  final List<Map<String, dynamic>> _visibleMechanics = [];

  // Search state
  _SearchState _state = _SearchState.idle;
  String? _currentRequestId;
  Map<String, dynamic>? _currentOffer;

  // Selected vehicle + problem
  Map<String, dynamic>? _selectedVehicle;
  final _problemController = TextEditingController();

  // Search
  bool _showSearch = false;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];

  // Animation controllers
  late AnimationController _rippleController;
  late AnimationController _slideController;
  late Animation<double> _ripple1;
  late Animation<double> _ripple2;
  late Animation<double> _ripple3;
  late Animation<Offset> _slideIn;

  // Realtime subscription
  RealtimeChannel? _channel;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _ripple1 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _rippleController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));
    _ripple2 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _rippleController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _ripple3 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _rippleController,
            curve: const Interval(0.15, 0.85, curve: Curves.easeOut)));

    _slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideController, curve: Curves.easeOutCubic));

    _loadMechanics();
    _getUserLocation();
  }

  Future<void> _loadMechanics() async {
    final json =
        await rootBundle.loadString('assets/data/mechanics.json');
    final data = jsonDecode(json);
    setState(() {
      _allMechanics =
          List<Map<String, dynamic>>.from(data['mechanics']);
    });
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
        _mapController.move(
            LatLng(position.latitude, position.longitude), 13.0);
      }
    } catch (_) {}
  }

  double _distanceTo(Map<String, dynamic> m) {
    if (_userPosition == null) return 999;
    return Geolocator.distanceBetween(
          _userPosition!.latitude, _userPosition!.longitude,
          (m['latitude'] as num).toDouble(),
          (m['longitude'] as num).toDouble(),
        ) / 1000;
  }

  // ── SEARCH LOGIC ──────────────────────────────────────────
  void _startSearch() async {
    if (_selectedVehicle == null) {
      _showBottomSheet();
      return;
    }
    if (_problemController.text.trim().isEmpty) {
      _showBottomSheet();
      return;
    }

    // Request location if not yet
    if (_userPosition == null) {
      await _getUserLocation();
      if (_userPosition == null) {
        _showSnack('Location required to find nearby mechanics.');
        return;
      }
    }

    // Create request in Supabase
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final res = await supabase.from('mechanic_requests').insert({
        'user_id': userId,
        'vehicle_id': _selectedVehicle!['id'],
        'problem_description': _problemController.text.trim(),
        'status': 'searching',
        'user_lat': _userPosition!.latitude,
        'user_lng': _userPosition!.longitude,
      }).select().single();

      setState(() {
        _currentRequestId = res['id'] as String;
        _state = _SearchState.searching;
        _visibleMechanics.clear();
      });

      _rippleController.repeat();
      _revealMechanicsSequentially();
      _listenForOffers();
    } catch (e) {
      _showSnack('Could not start search. Please try again.');
    }
  }

  // Reveal mechanics one by one sorted by distance
  void _revealMechanicsSequentially() {
    final sorted = List<Map<String, dynamic>>.from(_allMechanics)
      ..sort((a, b) => _distanceTo(a).compareTo(_distanceTo(b)));

    for (int i = 0; i < sorted.length; i++) {
      Future.delayed(Duration(milliseconds: 800 * (i + 1)), () {
        if (mounted && _state == _SearchState.searching) {
          setState(() => _visibleMechanics.add(sorted[i]));
        }
      });
    }

    // MVP simulation: after 5 seconds, simulate a mechanic offering
    // In production this would come from Realtime
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _state == _SearchState.searching &&
          sorted.isNotEmpty) {
        _simulateMechanicOffer(sorted.first);
      }
    });
  }

  // Simulate mechanic offer (MVP — replace with Realtime in production)
  void _simulateMechanicOffer(Map<String, dynamic> mechanic) async {
    if (_currentRequestId == null) return;
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('mechanic_offers').insert({
        'request_id': _currentRequestId,
        'mechanic_id': mechanic['id'],
        'mechanic_name': mechanic['name'],
        'mechanic_initials': mechanic['initials'],
        'mechanic_rating': mechanic['rating'],
        'mechanic_location': mechanic['location'],
        'mechanic_phone': mechanic['phone_number'],
        'mechanic_whatsapp': mechanic['whatsapp_number'],
        'mechanic_avatar_color': mechanic['avatar_color'],
        'quoted_price': 5000.0, // Mechanic sets this
        'status': 'pending',
      });
    } catch (_) {}
  }

  // Listen for mechanic offers via Realtime
  void _listenForOffers() {
    if (_currentRequestId == null) return;
    final supabase = Supabase.instance.client;

    _channel = supabase.channel('offers_$_currentRequestId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'mechanic_offers',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'request_id',
          value: _currentRequestId!,
        ),
        callback: (payload) {
          if (mounted && _state == _SearchState.searching) {
            final offer = payload.newRecord;
            setState(() {
              _currentOffer = offer;
              _state = _SearchState.offered;
            });
            _slideController.forward();
          }
        },
      )
      .subscribe();
  }

  void _acceptOffer() async {
    if (_currentOffer == null || _currentRequestId == null) return;
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Update offer status
      await supabase.from('mechanic_offers')
          .update({'status': 'accepted'})
          .eq('id', _currentOffer!['id']);

      // Update request status
      await supabase.from('mechanic_requests')
          .update({'status': 'accepted'})
          .eq('id', _currentRequestId!);

      // Create job session
      await supabase.from('job_sessions').insert({
        'request_id': _currentRequestId,
        'offer_id': _currentOffer!['id'],
        'user_id': userId,
        'status': 'active',
        'final_amount': _currentOffer!['quoted_price'],
      });

      _channel?.unsubscribe();

      // Build mechanic map for profile screen
      final mechanic = _allMechanics.firstWhere(
        (m) => m['id'] == _currentOffer!['mechanic_id'],
        orElse: () => {
          'name': _currentOffer!['mechanic_name'],
          'initials': _currentOffer!['mechanic_initials'],
          'rating': _currentOffer!['mechanic_rating'],
          'location': _currentOffer!['mechanic_location'],
          'phone_number': _currentOffer!['mechanic_phone'],
          'whatsapp_number': _currentOffer!['mechanic_whatsapp'],
          'avatar_color': _currentOffer!['mechanic_avatar_color'],
          'specialisations': [],
          'experience_years': 0,
          'jobs_done': 0,
          'response_speed': 'Fast',
          'is_online': true,
          'is_featured': false,
          'bio': '',
        },
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MechanicProfileScreen(mechanic: mechanic),
          ),
        );
        setState(() => _state = _SearchState.idle);
        _slideController.reset();
        _visibleMechanics.clear();
      }
    } catch (e) {
      _showSnack('Something went wrong. Please try again.');
    }
  }

  void _declineOffer() async {
    if (_currentOffer == null) return;
    final supabase = Supabase.instance.client;

    await supabase.from('mechanic_offers')
        .update({'status': 'declined'})
        .eq('id', _currentOffer!['id']);

    setState(() {
      _currentOffer = null;
      _state = _SearchState.searching;
    });
    _slideController.reset();

    // Continue searching — try next mechanic
    final sorted = List<Map<String, dynamic>>.from(_allMechanics)
      ..sort((a, b) => _distanceTo(a).compareTo(_distanceTo(b)));

    final declinedId = _currentOffer?['mechanic_id'];
    final remaining =
        sorted.where((m) => m['id'] != declinedId).toList();

    if (remaining.isNotEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _state == _SearchState.searching) {
          _simulateMechanicOffer(remaining.first);
        }
      });
    }
  }

  void _cancelSearch() async {
    _searchTimer?.cancel();
    _channel?.unsubscribe();
    _rippleController.stop();
    _slideController.reset();

    if (_currentRequestId != null) {
      await Supabase.instance.client
          .from('mechanic_requests')
          .update({'status': 'cancelled'})
          .eq('id', _currentRequestId!);
    }

    setState(() {
      _state = _SearchState.idle;
      _visibleMechanics.clear();
      _currentRequestId = null;
      _currentOffer = null;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13)),
      backgroundColor: AppColors.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── BOTTOM SHEET ──────────────────────────────────────────
  void _showBottomSheet() {
    final vehiclesAsync = ref.read(userVehiclesProvider);
    final vehicles = vehiclesAsync.value ?? [];

    // Auto-select if only one vehicle
    if (vehicles.length == 1 && _selectedVehicle == null) {
      _selectedVehicle = vehicles.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Find a Mechanic',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 4),
                const Text(
                    'Tell us your car and problem to find the right mechanic nearby.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 24),

                // ── Vehicle selector ──────────────────────
                const Text('SELECT VEHICLE',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 1.5,
                        fontFamily: 'Inter')),
                const SizedBox(height: 8),
                if (vehicles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                        'No vehicles added. Add a vehicle first.',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  )
                else
                  ...vehicles.map((v) {
                    final isSelected =
                        _selectedVehicle?['id'] == v['id'];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setSheet(
                            () => _selectedVehicle = v);
                        setState(
                            () => _selectedVehicle = v);
                      },
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySubtle
                              : AppColors.background,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border),
                        ),
                        child: Row(children: [
                          Icon(Icons.directions_car_outlined,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${v['make']} ${v['model']}  •  ${v['year']}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 18),
                        ]),
                      ),
                    );
                  }),
                const SizedBox(height: 20),

                // ── Problem description ───────────────────
                const Text('DESCRIBE THE PROBLEM',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 1.5,
                        fontFamily: 'Inter')),
                const SizedBox(height: 8),
                TextField(
                  controller: _problemController,
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter'),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. My car won\'t start, strange noise when braking...',
                    hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDisabled,
                        fontFamily: 'Inter'),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Find button ───────────────────────────
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_selectedVehicle == null) {
                      _showSnack(
                          'Please select a vehicle first.');
                      return;
                    }
                    if (_problemController.text
                        .trim()
                        .isEmpty) {
                      _showSnack(
                          'Please describe the problem.');
                      return;
                    }
                    Navigator.of(ctx).pop();
                    _startSearch();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6))],
                    ),
                    child: const Center(
                      child: Text('FIND MECHANIC',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                              fontFamily: 'Inter')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _slideController.dispose();
    _problemController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _channel?.unsubscribe();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Full screen map ───────────────────────────
            _buildMap(),

            // ── Top fade ─────────────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background,
                        AppColors.background.withValues(alpha: 0.85),
                        AppColors.background.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // ── Bottom fade ───────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.background,
                        AppColors.background.withValues(alpha: 0.85),
                        AppColors.background.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // ── Header overlay ────────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              child: _buildHeader(),
            ),

            // ── Search bar + results ──────────────────
            if (_showSearch)
              Positioned(
                top: 70, left: 16, right: 16,
                child: _buildSearchOverlay(),
              ),
            // ── Bottom: idle state ────────────────────────
            if (_state == _SearchState.idle)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: _buildIdleBottom(),
              ),

            // ── Bottom: searching state ───────────────────
            if (_state == _SearchState.searching)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: _buildSearchingBottom(),
              ),

            // ── Slide-in offer card ───────────────────────
            if (_state == _SearchState.offered &&
                _currentOffer != null)
              Positioned(
                bottom: 100, right: 0,
                child: SlideTransition(
                  position: _slideIn,
                  child: _buildOfferCard(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _searchResults = _allMechanics.where((m) {
        final name = (m['name'] ?? '').toString().toLowerCase();
        final location =
            (m['location'] ?? '').toString().toLowerCase();
        final specs = (m['specialisations'] as List?)
                ?.map((s) => s.toString().toLowerCase())
                .join(' ') ??
            '';
        return name.contains(q) ||
            location.contains(q) ||
            specs.contains(q);
      }).toList();
    });
  }

  Widget _buildSearchOverlay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryBorder),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16)],
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter'),
                decoration: const InputDecoration(
                  hintText: 'Search mechanics by name, location...',
                  hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDisabled,
                      fontFamily: 'Inter'),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          ]),
        ),
        // Results
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16)],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, color: AppColors.borderSubtle),
              itemBuilder: (_, i) {
                final m = _searchResults[i];
                final isOnline = m['is_online'] == true;
                final avatarColor = Color(int.parse(
                    'FF',
                    radix: 16));
                final dist = _distanceTo(m);
                final distLabel = dist < 999
                    ? ' km'
                    : '';

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _showSearch = false;
                      _searchResults = [];
                      _searchController.clear();
                    });
                    _searchFocus.unfocus();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MechanicProfileScreen(mechanic: m),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primaryBorder,
                              width: 1.5),
                        ),
                        child: Center(
                          child: Text(m['initials'] ?? '',
                              style: const TextStyle(
                                  fontSize: 13,
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
                            Text(m['name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Inter')),
                            Text(
                              m['location'] ?? '',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOnline
                                  ? AppColors.advisory
                                  : AppColors.textTertiary,
                            ),
                          ),
                          if (distLabel.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(distLabel,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter')),
                          ],
                        ],
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const Text('Nearby Mechanics',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const Spacer(),
          // Search icon only
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => _showSearch = !_showSearch);
              if (_showSearch) {
                Future.delayed(const Duration(milliseconds: 100),
                    () => _searchFocus.requestFocus());
              } else {
                _searchResults = [];
                _searchController.clear();
                _searchFocus.unfocus();
              }
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8)],
              ),
              child: Icon(
                _showSearch
                    ? Icons.close_rounded
                    : Icons.search_rounded,
                color: AppColors.textPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMap() {
    final center = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : const LatLng(6.5244, 3.3792);

    // Build mechanic markers
    final mechanicMarkers = _visibleMechanics.map((m) {
      final mechanic = m;
      final lat = (mechanic['latitude'] as num).toDouble();
      final lng = (mechanic['longitude'] as num).toDouble();
      final avatarColor = Color(int.parse(
          'FF${mechanic['avatar_color']}',
          radix: 16));

      return Marker(
        point: LatLng(lat, lng),
        width: 44,
        height: 44,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(
              scale: v, child: child),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8)],
            ),
            child: Center(
              child: Text(mechanic['initials'] ?? '',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Inter')),
            ),
          ),
        ),
      );
    }).toList();

    // User marker with ripple
    final userMarkers = _userPosition != null
        ? [
            Marker(
              point: center,
              width: 14, height: 14,
              child: _state == _SearchState.searching
                  ? AnimatedBuilder(
                      animation: _rippleController,
                      builder: (_, __) => Stack(
                        alignment: Alignment.center,
                        children: [
                          _Ripple(progress: _ripple1.value,
                              color: AppColors.primary),
                          _Ripple(progress: _ripple2.value,
                              color: AppColors.primary),
                          _Ripple(progress: _ripple3.value,
                              color: AppColors.primary),
                          _UserDotWidget(),
                        ],
                      ),
                    )
                  : _UserDotWidget(),
            ),
          ]
        : <Marker>[];

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.9,  0,    0,    0, 245,
         0,   -0.9,  0,    0, 245,
         0,    0,   -0.9,  0, 245,
         0,    0,    0,    1,   0,
      ]),
      child: FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.davelop.standiag_auto',
        ),
        MarkerLayer(markers: [...userMarkers, ...mechanicMarkers]),
      ],
    ),
    );
  }

  Widget _buildIdleBottom() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: const Icon(Icons.car_repair,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need a mechanic?',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                SizedBox(height: 2),
                Text('Tap "Find Mechanic" to search nearby',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _showBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Search',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Inter')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingBottom() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Pulsing dot
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (_, v, __) => Transform.scale(
                  scale: v,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.5),
                          blurRadius: 8)],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Searching for mechanics...',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter')),
                    Text(
                      '${_visibleMechanics.length} mechanic${_visibleMechanics.length == 1 ? '' : 's'} found nearby',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _cancelSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.criticalBg,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.criticalBorder),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFamily: 'Inter')),
                ),
              ),
            ],
          ),
          if (_selectedVehicle != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                const Icon(Icons.directions_car_outlined,
                    color: AppColors.textTertiary, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_selectedVehicle!['make']} ${_selectedVehicle!['model']}  •  ${_problemController.text}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter'),
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferCard() {
    final name = _currentOffer!['mechanic_name'] ?? '';
    final initials = _currentOffer!['mechanic_initials'] ?? '';
    final rating =
        (_currentOffer!['mechanic_rating'] as num?)?.toDouble() ??
            0.0;
    final location = _currentOffer!['mechanic_location'] ?? '';
    final price =
        (_currentOffer!['quoted_price'] as num?)?.toDouble() ?? 0.0;
    final avatarColor = Color(int.parse(
        'FF${_currentOffer!['mechanic_avatar_color'] ?? 'C0272D'}',
        radix: 16));

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                  bottom:
                      BorderSide(color: AppColors.primaryBorder)),
            ),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.advisory,
                    shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text('Mechanic Found!',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Inter')),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mechanic info
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primaryBorder,
                          width: 1.5),
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 14,
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
                        Text(name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'Inter')),
                        Text(location,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter')),
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF5A623),
                              size: 13),
                          Text(' $rating',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter')),
                        ]),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.payments_outlined,
                        color: AppColors.advisory, size: 16),
                    const SizedBox(width: 8),
                    const Text('Quoted price:',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                    const Spacer(),
                    Text(
                      '₦${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.advisory,
                          fontFamily: 'Inter'),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                // Accept / Decline
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _declineOffer,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.criticalBg,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.criticalBorder),
                        ),
                        child: const Center(
                          child: Text('Decline',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontFamily: 'Inter')),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _acceptOffer,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.35),
                              blurRadius: 10)],
                        ),
                        child: const Center(
                          child: Text('Accept',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Inter')),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SUPPORTING WIDGETS ────────────────────────────────────────
class _Ripple extends StatelessWidget {
  final double progress;
  final Color color;
  const _Ripple({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (1.0 - progress).clamp(0.0, 1.0),
      child: Container(
        width: 80 * progress,
        height: 80 * progress,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: color.withValues(alpha: 0.6), width: 2),
        ),
      ),
    );
  }
}

class _UserDotWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.5),
            blurRadius: 10, spreadRadius: 2)],
      ),
    );
  }
}


















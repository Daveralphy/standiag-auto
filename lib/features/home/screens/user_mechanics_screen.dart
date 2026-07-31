// User Mechanics tab — full-screen map of nearby mechanics, matching the
// "Great Mechanics / Standby Nearby" design. The "Find Nearby Mechanics"
// card at the bottom is the entire search flow: type the problem, tap
// search, and incoming mechanic quotes slide in right there on this same
// screen — there's no separate searching screen. Accepting a quote pushes
// the mechanic's profile, where the job actually gets started.

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/quote_model.dart';
import '../../jobs/models/service_request_model.dart';
import '../../jobs/providers/service_request_provider.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../../profile/screens/user_drawer_screen.dart';

// The radius nearby mechanics are alerted within — fixed, no manual step.
const double _searchRadiusKm = 15.0;

class UserMechanicsScreen extends ConsumerStatefulWidget {
  const UserMechanicsScreen({super.key});

  @override
  ConsumerState<UserMechanicsScreen> createState() =>
      _UserMechanicsScreenState();
}

class _UserMechanicsScreenState extends ConsumerState<UserMechanicsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isFindingMechanic = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _issueController.dispose();
    _pulseController.dispose();
    final request = ref.read(serviceRequestProvider).activeRequest;
    if (request != null && request.status == ServiceRequestStatus.open) {
      ref.read(serviceRequestProvider.notifier).cancelRequest(request.id);
    }
    ref.read(serviceRequestProvider.notifier).stopWatching();
    super.dispose();
  }

  Future<void> _startFinding() async {
    final issue = _issueController.text.trim();
    if (issue.isEmpty) return;
    setState(() => _isFindingMechanic = true);

    final carOwnerId = ref.read(currentUserIdProvider);
    if (carOwnerId == null) return;

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
      // Broadcast without a location below rather than blocking the search
      // on it — mechanics just won't get a distance figure for this one.
    }
    if (!mounted) return;

    await ref.read(serviceRequestProvider.notifier).createRequest(
          carOwnerId: carOwnerId,
          carOwnerLocation: origin == null
              ? null
              : GeoPoint(origin.latitude, origin.longitude),
          issue: issue,
          vehicleId: '',
          radiusKm: _searchRadiusKm,
        );
  }

  void _cancelFinding() {
    final request = ref.read(serviceRequestProvider).activeRequest;
    if (request != null && request.status == ServiceRequestStatus.open) {
      ref.read(serviceRequestProvider.notifier).cancelRequest(request.id);
    }
    ref.read(serviceRequestProvider.notifier).stopWatching();
    setState(() => _isFindingMechanic = false);
  }

  void _acceptQuote(ServiceRequestModel request, QuoteModel quote) {
    context.push(RouteNames.mechanicProfile, extra: {
      'mechanicId': quote.mechanicId,
      'requestId': request.id,
    });
  }

  void _declineQuote(ServiceRequestModel request, QuoteModel quote) {
    ref
        .read(serviceRequestProvider.notifier)
        .declineQuote(request.id, quote.mechanicId);
  }

  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(nearbyMechanicsProvider);
    final mechanics = mechanicsAsync.valueOrNull ?? const [];
    final markers = [
      for (final entry in mechanics)
        if (entry.mechanic.location != null)
          AppMapMarker(
            id: entry.mechanic.uid,
            position: LatLng(entry.mechanic.location!.latitude,
                entry.mechanic.location!.longitude),
            child: const AppMapPin(icon: Icons.build_rounded),
            onTap: () => context.push(RouteNames.mechanicProfile,
                extra: entry.mechanic.uid),
          ),
    ];

    // Only resolved once the user's actually typed something — avoids
    // triggering a name lookup for every nearby mechanic on every build.
    final searchResults = _searchQuery.trim().isEmpty
        ? const <NearbyMechanic>[]
        : mechanics.where((entry) {
            final user =
                ref.watch(mechanicUserProvider(entry.mechanic.uid)).valueOrNull;
            if (user == null) return false;
            final name = '${user.firstName} ${user.lastName}'.trim().toLowerCase();
            return name.contains(_searchQuery.trim().toLowerCase());
          }).toList();

    final activeRequest = ref.watch(serviceRequestProvider).activeRequest;
    final quotesAsync = _isFindingMechanic && activeRequest != null
        ? ref.watch(quotesForRequestProvider(activeRequest.id))
        : null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mapBackground,
      drawer: const UserDrawerScreen(),
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 13.2,
            markers: markers,
          ),

          // ─── Header — solid backdrop sized to its own content; a hard
          // edge, not a fade, since fading dark-to-transparent directly
          // over this light Positron map just reads as a muddy grey smudge
          // rather than a clean transition ───────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.mapBackground,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppScreenHeader(
                      scaffoldKey: _scaffoldKey,
                      title: 'Great Mechanics',
                      subtitle: 'Standby Nearby',
                      trailingIcon: Icons.search_rounded,
                      onTrailingTap: () =>
                          setState(() => _isSearching = true),
                      isSearching: _isSearching,
                      searchController: _searchController,
                      searchHint: 'Search mechanics by name',
                      onSearchChanged: (value) =>
                          setState(() => _searchQuery = value),
                      onSearchClose: () => setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                    ),
                    if (_isSearching && _searchQuery.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal),
                        child: _SearchResultsList(results: searchResults),
                      ),
                  ],
                ),
              ),
            ),
          ),

          if (!_isSearching && !_isFindingMechanic) ...[
            if (mechanicsAsync.isLoading)
              const Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: Center(child: _StatusPill(text: 'Finding mechanics nearby…')),
              )
            else if (mechanicsAsync.hasError)
              const Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: Center(
                    child: _StatusPill(text: 'Unable to load mechanics')),
              )
            else if (mechanics.isEmpty)
              const Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: Center(
                    child: _StatusPill(text: 'No mechanics available nearby')),
              ),
          ],

          // ─── Footer — solid backdrop behind the find-mechanic card and
          // nav bar; the map fades up into it from above ──────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.mapBackground],
                    ),
                  ),
                ),
                Expanded(child: Container(color: AppColors.mapBackground)),
              ],
            ),
          ),

          // ─── Find Nearby Mechanics card ──────────────────────────────
          Positioned(
            bottom: AppSpacing.navBarHeight + AppSpacing.navBarBottomOffset + 12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: !_isFindingMechanic
                ? _buildIdleCard()
                : quotesAsync == null
                    ? _buildPulseCard('Alerting nearby mechanics…')
                    : quotesAsync.when(
                        data: (quotes) => quotes.isEmpty
                            ? _buildPulseCard('Waiting for mechanics to respond…')
                            : _buildQuoteCard(activeRequest!, quotes.first),
                        loading: () =>
                            _buildPulseCard('Waiting for mechanics to respond…'),
                        error: (_, __) =>
                            _buildPulseCard('Unable to reach nearby mechanics.'),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's the problem?",
              style: AppTypography.heading4,
              overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 10),
          TextField(
            controller: _issueController,
            maxLines: 2,
            style: AppTypography.input,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'e.g. "Car won\'t start, battery might be dead"',
              hintStyle: AppTypography.inputLabel,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Find Nearby Mechanics',
            onTap: _issueController.text.trim().isEmpty ? null : _startFinding,
          ),
        ],
      ),
    );
  }

  Widget _buildPulseCard(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySubtle,
                border: Border.all(color: AppColors.primaryBorder, width: 1.5),
              ),
              child: const Icon(Icons.search_rounded,
                  color: AppColors.primary, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: AppTypography.body,
                overflow: TextOverflow.ellipsis, maxLines: 2),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _cancelFinding,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0x0DFFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(ServiceRequestModel request, QuoteModel quote) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _QuoteCard(
        key: ValueKey(quote.mechanicId),
        request: request,
        quote: quote,
        onAccept: () => _acceptQuote(request, quote),
        onDecline: () => _declineQuote(request, quote),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE10E0E0E),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Text(text,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
          maxLines: 1),
    );
  }
}

/// Dropdown of mechanics matching the current search text — tap one to view
/// their profile.
class _SearchResultsList extends ConsumerWidget {
  final List<NearbyMechanic> results;
  const _SearchResultsList({required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: const Color(0xE1141414),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: results.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.xl4),
              child: Text('No mechanics found with that name.',
                  style: AppTypography.body, textAlign: TextAlign.center),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (context, i) {
                final entry = results[i];
                final user =
                    ref.watch(mechanicUserProvider(entry.mechanic.uid)).valueOrNull;
                final name = user != null
                    ? '${user.firstName} ${user.lastName}'.trim()
                    : 'Mechanic';
                return GestureDetector(
                  onTap: () => context.push(RouteNames.mechanicProfile,
                      extra: entry.mechanic.uid),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        AppAvatar(
                            name: name, imageUrl: user?.profilePhoto, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name,
                              style: AppTypography.bodyLarge,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        if (entry.distanceKm != null)
                          Text('${entry.distanceKm!.toStringAsFixed(1)} km',
                              style: AppTypography.caption,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// One mechanic's incoming quote, slid in from the side — price and note up
/// front since that's what's actually being decided on here, name/rating
/// below it. Accept opens their profile to start the job from there;
/// Decline dismisses the quote and lets the next one waiting take its place.
class _QuoteCard extends ConsumerWidget {
  final ServiceRequestModel request;
  final QuoteModel quote;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _QuoteCard({
    super.key,
    required this.request,
    required this.quote,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanicAsync = ref.watch(mechanicByIdProvider(quote.mechanicId));
    final userAsync = ref.watch(mechanicUserProvider(quote.mechanicId));
    final mechanic = mechanicAsync.valueOrNull;
    final user = userAsync.valueOrNull;
    final name =
        user != null ? '${user.firstName} ${user.lastName}'.trim() : 'Mechanic';

    double? distanceKm;
    final mechanicLocation = mechanic?.location;
    if (mechanicLocation != null && request.carOwnerLocation != null) {
      distanceKm = Geolocator.distanceBetween(
            request.carOwnerLocation!.latitude,
            request.carOwnerLocation!.longitude,
            mechanicLocation.latitude,
            mechanicLocation.longitude,
          ) /
          1000;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(name: name, imageUrl: user?.profilePhoto, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
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
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                      ],
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km away',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.primary),
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₦${quote.price.toStringAsFixed(0)}',
                      style: AppTypography.heading3
                          .copyWith(color: AppColors.primary),
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const Text('quote',
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ],
          ),
          if (quote.note != null && quote.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x0DFFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(quote.note!,
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Decline',
                  onTap: onDecline,
                  variant: AppButtonVariant.ghost,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Accept',
                  onTap: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

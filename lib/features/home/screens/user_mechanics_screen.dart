// User Mechanics tab — full-screen map of nearby mechanics, matching the
// "Great Mechanics / Standby Nearby" design. Tapping "Find Nearby Mechanics"
// starts the radius-selector → searching → mechanic-card flow.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_dark_map.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/map_search_bar.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../../profile/screens/user_drawer_screen.dart';

class UserMechanicsScreen extends ConsumerStatefulWidget {
  const UserMechanicsScreen({super.key});

  @override
  ConsumerState<UserMechanicsScreen> createState() =>
      _UserMechanicsScreenState();
}

class _UserMechanicsScreenState extends ConsumerState<UserMechanicsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(nearbyMechanicsProvider);
    final mechanics = mechanicsAsync.valueOrNull ?? const [];
    final markers = [
      for (final entry in mechanics)
        if (entry.mechanic.location != null)
          AppDarkMapMarker(
            id: entry.mechanic.uid,
            position: LatLng(entry.mechanic.location!.latitude,
                entry.mechanic.location!.longitude),
            child: const AppDarkMapPin(icon: Icons.build_rounded),
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mapBackground,
      drawer: const UserDrawerScreen(),
      body: Stack(
        children: [
          AppDarkMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 13.2,
            markers: markers,
          ),

          // ─── Top gradient ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
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

          // ─── Header ──────────────────────────────────────────────────
          SafeArea(
            child: _isSearching
                ? MapSearchBar(
                    controller: _searchController,
                    hint: 'Search mechanics by name',
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    onClose: () => setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    }),
                  )
                : AppScreenHeader(
                    scaffoldKey: _scaffoldKey,
                    title: 'Great Mechanics',
                    subtitle: 'Standby Nearby',
                    trailingIcon: Icons.search_rounded,
                    onTrailingTap: () =>
                        setState(() => _isSearching = true),
                  ),
          ),

          if (_isSearching && _searchQuery.trim().isNotEmpty)
            Positioned(
              top: 74,
              left: AppSpacing.pageHorizontal,
              right: AppSpacing.pageHorizontal,
              child: _SearchResultsList(results: searchResults),
            ),

          if (!_isSearching) ...[
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

          // ─── Find button — sits above the floating nav ─────────────────
          Positioned(
            bottom: AppSpacing.navBarHeight +
                AppSpacing.navBarBottomOffset +
                12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: GestureDetector(
              onTap: () => context.go(RouteNames.radiusSelector),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40E8281E),
                        blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: const Center(
                  child: Text('Find Nearby Mechanics',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 15,
                        fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                ),
              ),
            ),
          ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.carOwner,
            onScanTap: () => context.go(RouteNames.userScan),
            onHomeTap: () => context.go(RouteNames.userHome),
            onThirdTap: () {},
          ),
        ],
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

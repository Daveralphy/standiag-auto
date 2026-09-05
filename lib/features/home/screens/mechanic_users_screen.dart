// Mechanic Users screen — map view showing car owners with an open request
// nearby. Nav bar active: Users. Search icon top right. Tapping a pin, a
// search result, or the quote button opens Send Quote for that request.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/jobs/providers/service_request_provider.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicUsersScreen extends ConsumerStatefulWidget {
  const MechanicUsersScreen({super.key});

  @override
  ConsumerState<MechanicUsersScreen> createState() => _MechanicUsersScreenState();
}

class _MechanicUsersScreenState extends ConsumerState<MechanicUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mechanicId = ref.watch(currentUserIdProvider);
    final requests = mechanicId == null
        ? const <NearbyServiceRequest>[]
        : ref.watch(nearbyServiceRequestsProvider(mechanicId)).valueOrNull ??
            const <NearbyServiceRequest>[];
    final markers = [
      for (final entry in requests)
        if (entry.request.carOwnerLocation != null)
          AppMapMarker(
            id: entry.request.id,
            position: LatLng(entry.request.carOwnerLocation!.latitude,
                entry.request.carOwnerLocation!.longitude),
            child: const AppMapPin(icon: Icons.person_outline_rounded),
            onTap: () => context.push(RouteNames.sendQuote,
                extra: entry.request.id),
          ),
    ];

    final searchResults = _searchQuery.trim().isEmpty
        ? const <NearbyServiceRequest>[]
        : requests.where((entry) {
            final user = ref
                .watch(mechanicUserProvider(entry.request.carOwnerId))
                .valueOrNull;
            if (user == null) return false;
            final name = '${user.firstName} ${user.lastName}'.trim().toLowerCase();
            return name.contains(_searchQuery.trim().toLowerCase());
          }).toList();
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
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
                      title: 'Nearby Users',
                      subtitle: 'Car owners near you',
                      trailingIcon: Icons.search_rounded,
                      onTrailingTap: () =>
                          setState(() => _isSearching = true),
                      isSearching: _isSearching,
                      searchController: _searchController,
                      searchHint: 'Search users by name',
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
                        child: _UserSearchResultsList(results: searchResults),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Footer — solid backdrop behind the nav bar; the map fades
          // up into it from above ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 130,
            child: Column(
              children: [
                Container(
                  height: 32,
                  decoration: BoxDecoration(
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
        ],
      ),
    );
  }
}

/// Dropdown of open requests matching the current search text — tap one to
/// send that car owner a quote.
class _UserSearchResultsList extends ConsumerWidget {
  final List<NearbyServiceRequest> results;
  const _UserSearchResultsList({required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: results.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.xl4),
              child: Text('No users found with that name.',
                  style: AppTypography.body, textAlign: TextAlign.center),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (context, i) {
                final entry = results[i];
                final user = ref
                    .watch(mechanicUserProvider(entry.request.carOwnerId))
                    .valueOrNull;
                final name = user != null
                    ? '${user.firstName} ${user.lastName}'.trim()
                    : 'User';
                return GestureDetector(
                  onTap: () => context.push(RouteNames.sendQuote,
                      extra: entry.request.id),
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

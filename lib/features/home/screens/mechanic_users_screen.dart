// Mechanic Users screen — map view showing nearby car owners.
// Nav bar active: Users. Search icon top right.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/jobs/models/job_model.dart';
import '../../../features/jobs/providers/job_provider.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/map_search_bar.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../profile/screens/mechanic_drawer_screen.dart';

class MechanicUsersScreen extends ConsumerStatefulWidget {
  const MechanicUsersScreen({super.key});

  @override
  ConsumerState<MechanicUsersScreen> createState() => _MechanicUsersScreenState();
}

class _MechanicUsersScreenState extends ConsumerState<MechanicUsersScreen> {
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
    final mechanicId = ref.watch(currentUserIdProvider);
    final requests = mechanicId == null
        ? const <JobModel>[]
        : ref.watch(pendingJobsForMechanicProvider(mechanicId)).valueOrNull ??
            const <JobModel>[];
    final markers = [
      for (final job in requests)
        if (job.carOwnerLocation != null)
          AppMapMarker(
            id: job.id,
            position: LatLng(
                job.carOwnerLocation!.latitude, job.carOwnerLocation!.longitude),
            child: const AppMapPin(icon: Icons.person_outline_rounded),
          ),
    ];

    final searchResults = _searchQuery.trim().isEmpty
        ? const <JobModel>[]
        : requests.where((job) {
            final user =
                ref.watch(mechanicUserProvider(job.carOwnerId)).valueOrNull;
            if (user == null) return false;
            final name = '${user.firstName} ${user.lastName}'.trim().toLowerCase();
            return name.contains(_searchQuery.trim().toLowerCase());
          }).toList();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mapBackground,
      drawer: const MechanicDrawerScreen(),
      body: Stack(
        children: [
          AppMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 13.2,
            markers: markers,
            circles: const [
              AppMapCircle(
                id: 'service-radius',
                center: LatLng(6.5244, 3.3792),
                radiusMeters: 2000,
              ),
            ],
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
                    hint: 'Search users by name',
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
                    title: 'Nearby Users',
                    subtitle: 'Car owners near you',
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
              child: _UserSearchResultsList(results: searchResults),
            ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Dropdown of pending job requests matching the current search text — this
/// app has no standalone "car owner profile" screen, so tapping a result
/// just dismisses the search (there's nowhere else to send it to yet).
class _UserSearchResultsList extends ConsumerWidget {
  final List<JobModel> results;
  const _UserSearchResultsList({required this.results});

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
              child: Text('No users found with that name.',
                  style: AppTypography.body, textAlign: TextAlign.center),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (context, i) {
                final job = results[i];
                final user =
                    ref.watch(mechanicUserProvider(job.carOwnerId)).valueOrNull;
                final name = user != null
                    ? '${user.firstName} ${user.lastName}'.trim()
                    : 'User';
                return Padding(
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
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textMuted, size: 16),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

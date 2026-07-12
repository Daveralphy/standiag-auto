import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/providers/job_provider.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../../profile/models/vehicle_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/user_drawer_screen.dart';
import '../../scan/providers/scan_provider.dart';

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;
      ref.read(profileProvider.notifier).fetchVehicles(userId);
      ref.read(jobProvider.notifier).fetchHistory(userId);
      ref.read(scanProvider.notifier).fetchHistory(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(nearbyMechanicsProvider);
    final vehiclesState = ref.watch(profileProvider);
    final vehicle =
        vehiclesState.vehicles.isNotEmpty ? vehiclesState.vehicles.first : null;

    final serviceCount = ref.watch(
        jobProvider.select((s) => s.jobHistory.where((j) => j.status == JobStatus.completed).length));
    final latestScan = ref.watch(scanProvider.select((s) => s.latestScan)) ??
        (ref.watch(scanProvider.select((s) => s.history)).isNotEmpty
            ? ref.watch(scanProvider.select((s) => s.history)).first
            : null);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const UserDrawerScreen(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppScreenHeader(
                  scaffoldKey: _scaffoldKey,
                  showGreeting: true,
                  subtitle: 'Your Dashboard',
                  trailingIcon: Icons.notifications_outlined,
                  onTrailingTap: () =>
                      context.push(RouteNames.userNotifications),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.navBarClearance),
                    children: [
                        // ─── Vehicle card ────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: vehicle == null
                              ? _NoVehicleCard(
                                  onAddVehicle: () =>
                                      context.push(RouteNames.addVehicle))
                              : _VehicleCard(vehicle: vehicle),
                        ),
                        const SizedBox(height: 24),

                        // ─── Quick Actions ───────────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Text('Quick Actions',
                              style: AppTypography.heading3,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Row(
                            children: [
                              _QuickAction(
                                  icon: Icons.history_rounded,
                                  label: 'Service History',
                                  sublabel: serviceCount == 0
                                      ? 'No records'
                                      : '$serviceCount record${serviceCount == 1 ? '' : 's'}',
                                  onTap: () => context
                                      .go(RouteNames.serviceHistory)),
                              const SizedBox(width: 10),
                              _QuickAction(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Book Service',
                                  sublabel: 'Schedule',
                                  onTap: () =>
                                      context.go(RouteNames.myJobs)),
                              const SizedBox(width: 10),
                              _QuickAction(
                                  icon: Icons.qr_code_scanner_rounded,
                                  label: 'Previous Scan',
                                  sublabel: latestScan == null
                                      ? 'No scans yet'
                                      : _relativeDays(latestScan.createdAt),
                                  onTap: () => context
                                      .go(RouteNames.userScanHistory)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Nearby Mechanics ────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text('Nearby Mechanics',
                                    style: AppTypography.heading3,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.go(RouteNames.userMechanics),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('See all',
                                        style: AppTypography.bodySmall
                                            .copyWith(
                                                color: AppColors.primary)),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.arrow_forward_rounded,
                                        size: 14, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: mechanicsAsync.when(
                            data: (mechanics) {
                              if (mechanics.isEmpty) {
                                return const Text(
                                    'No mechanics available nearby.',
                                    style: AppTypography.body);
                              }
                              final preview = mechanics.take(3).toList();
                              return Column(
                                children: [
                                  for (int i = 0; i < preview.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 10),
                                    _MiniMechanicCard(entry: preview[i]),
                                  ],
                                ],
                              );
                            },
                            loading: () => const Column(
                              children: [
                                _MiniMechanicCardSkeleton(),
                                SizedBox(height: 10),
                                _MiniMechanicCardSkeleton(),
                                SizedBox(height: 10),
                                _MiniMechanicCardSkeleton(),
                              ],
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppNavBar(
            activeItem: NavBarItem.home,
            userType: NavBarUserType.carOwner,
            onScanTap: () => context.go(RouteNames.userScan),
            onHomeTap: () {},
            onThirdTap: () => context.go(RouteNames.userMechanics),
          ),
        ],
      ),
    );
  }

  String _relativeDays(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vehicle.displayName,
              style: AppTypography.heading2,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          const SizedBox(height: 4),
          Text(
            [vehicle.type, vehicle.fuelType, vehicle.colour]
                .where((s) => s.isNotEmpty)
                .join(' · '),
            style: AppTypography.body,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Diagnose My Car',
            onTap: () => context.go(RouteNames.userScan),
          ),
        ],
      ),
    );
  }
}

class _NoVehicleCard extends StatelessWidget {
  final VoidCallback onAddVehicle;
  const _NoVehicleCard({required this.onAddVehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('No vehicle added yet',
              style: AppTypography.heading3,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          const SizedBox(height: 4),
          const Text('Add your car to start diagnosing it with OBD.',
              style: AppTypography.body),
          const SizedBox(height: 16),
          AppButton(label: 'Add a Vehicle', onTap: onAddVehicle),
        ],
      ),
    );
  }
}

class _MiniMechanicCard extends ConsumerWidget {
  final NearbyMechanic entry;
  const _MiniMechanicCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanic = entry.mechanic;
    final userAsync = ref.watch(mechanicUserProvider(mechanic.uid));
    return GestureDetector(
      onTap: () => context.push(RouteNames.mechanicProfile, extra: mechanic.uid),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            userAsync.when(
              data: (user) => AppAvatar(
                name: user != null
                    ? '${user.firstName} ${user.lastName}'.trim()
                    : 'Mechanic',
                imageUrl: user?.profilePhoto,
                size: 44,
              ),
              loading: () => const AppSkeleton.circle(size: 44),
              error: (_, __) => const AppAvatar(name: 'Mechanic', size: 44),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userAsync.when(
                    data: (user) => Text(
                      user != null
                          ? '${user.firstName} ${user.lastName}'.trim()
                          : 'Mechanic',
                      style: AppTypography.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    loading: () => Container(
                        width: 100, height: 13,
                        decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(4))),
                    error: (_, __) =>
                        const Text('Mechanic', style: AppTypography.bodyLarge),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.primary, size: 12),
                      const SizedBox(width: 2),
                      Text(mechanic.rating.toStringAsFixed(1),
                          style: AppTypography.caption),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.distanceKm != null
                              ? '${entry.distanceKm!.toStringAsFixed(1)} km away'
                              : 'Distance unknown',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textDisabled, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MiniMechanicCardSkeleton extends StatelessWidget {
  const _MiniMechanicCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 13,
                    decoration: BoxDecoration(color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 70, height: 10,
                    decoration: BoxDecoration(color: const Color(0x0AFFFFFF),
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x14E8281E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: AppTypography.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
              const SizedBox(height: 2),
              Text(sublabel,
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}

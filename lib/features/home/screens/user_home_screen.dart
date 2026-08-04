import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/mini_mechanic_card.dart';
import '../../../shared/widget/app_screen_backdrop.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/providers/job_provider.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../../profile/models/vehicle_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../../scan/providers/scan_provider.dart';

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(nearbyMechanicsProvider);
    final vehiclesState = ref.watch(profileProvider);
    final vehicle = vehiclesState.vehicles.isNotEmpty
        ? vehiclesState.vehicles.first
        : null;

    final serviceCount = ref.watch(
      jobProvider.select(
        (s) =>
            s.jobHistory.where((j) => j.status == JobStatus.completed).length,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AppScreenBackdrop(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppScreenHeader(
                  showGreeting: true,
                  subtitle: _greeting(),
                  trailingIcon: Icons.notifications_outlined,
                  onTrailingTap: () =>
                      context.push(RouteNames.userNotifications),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.navBarClearance,
                    ),
                    children: [
                      // ─── Vehicle card ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: vehicle == null
                            ? _NoVehicleCard(
                                onAddVehicle: () =>
                                    context.push(RouteNames.addVehicle),
                              )
                            : _VehicleCard(vehicle: vehicle),
                      ),
                      const SizedBox(height: 24),

                      // ─── Quick Actions ───────────────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: Text(
                          'Quick Actions',
                          style: AppTypography.heading3,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: Row(
                          children: [
                            _QuickAction(
                              icon: Icons.history_rounded,
                              label: 'Service History',
                              sublabel: serviceCount == 0
                                  ? 'No records'
                                  : '$serviceCount record${serviceCount == 1 ? '' : 's'}',
                              onTap: () =>
                                  context.go(RouteNames.serviceHistory),
                            ),
                            const SizedBox(width: 10),
                            _QuickAction(
                              icon: Icons.calendar_today_outlined,
                              label: 'Book Service',
                              sublabel: 'Schedule',
                              onTap: () => context.go(RouteNames.myJobs),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── Nearby Mechanics ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Nearby Mechanics',
                                style: AppTypography.heading3,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go(RouteNames.userMechanics),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'See all',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: mechanicsAsync.when(
                          data: (mechanics) {
                            if (mechanics.isEmpty) {
                              return const Text(
                                'No mechanics available nearby.',
                                style: AppTypography.body,
                              );
                            }
                            final preview = mechanics.take(3).toList();
                            return Column(
                              children: [
                                for (int i = 0; i < preview.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 10),
                                  MiniMechanicCard(entry: preview[i]),
                                ],
                              ],
                            );
                          },
                          loading: () => const Column(
                            children: [
                              MiniMechanicCardSkeleton(),
                              SizedBox(height: 10),
                              MiniMechanicCardSkeleton(),
                              SizedBox(height: 10),
                              MiniMechanicCardSkeleton(),
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
        ],
      ),
    );
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
          Text(
            vehicle.displayName,
            style: AppTypography.heading2,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            [
              vehicle.type,
              vehicle.fuelType,
              vehicle.colour,
            ].where((s) => s.isNotEmpty).join(' · '),
            style: AppTypography.body,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Diagnose My Car',
            onTap: () => context.go(RouteNames.userVehicle),
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
          const Text(
            'No vehicle added yet',
            style: AppTypography.heading3,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          const Text(
            'Add your car to start diagnosing it with OBD.',
            style: AppTypography.body,
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Add a Vehicle', onTap: onAddVehicle),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x14E8281E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: AppTypography.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: AppTypography.caption,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

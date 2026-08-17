// User Mechanics tab — a browse screen matching Home/Vehicle/Profile's dim
// photo-backdrop look, rather than the full-bleed map it used to be. The
// live map + matching experience lives on its own screen now
// (SearchingMechanicScreen), reached via FindMechanicSheet; "Schedule
// Repair" reaches the same flow through MechanicIdLookupSheet first, for a
// car owner who already knows a specific mechanic's ID.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/find_mechanic_sheet.dart';
import '../../../shared/widget/image_ad_carousel.dart';
import '../../../shared/widget/mechanic_id_lookup_sheet.dart';
import '../../../shared/widget/mini_mechanic_card.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/providers/job_provider.dart';
import '../../mechanics/providers/mechanics_provider.dart';

class UserMechanicsScreen extends ConsumerStatefulWidget {
  const UserMechanicsScreen({super.key});

  @override
  ConsumerState<UserMechanicsScreen> createState() =>
      _UserMechanicsScreenState();
}

class _UserMechanicsScreenState extends ConsumerState<UserMechanicsScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  /// Where the active-job header icon leads — depends on the mechanic's
  /// current status, matching each job-flow screen's own place in the
  /// sequence.
  String? _activeJobRoute(JobModel job) {
    switch (job.status) {
      case JobStatus.accepted:
        return RouteNames.userMechanicAccepted;
      case JobStatus.enRoute:
        return RouteNames.userTracking;
      case JobStatus.arrived:
        return RouteNames.userMechanicArrived;
      case JobStatus.inProgress:
        return RouteNames.userJobInProgress;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(nearbyMechanicsProvider);

    final carOwnerId = ref.watch(currentUserIdProvider);
    final activeJob = carOwnerId == null
        ? null
        : ref.watch(activeJobForCarOwnerProvider(carOwnerId)).valueOrNull;
    final activeJobRoute = activeJob == null
        ? null
        : _activeJobRoute(activeJob);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppScreenHeader(
              title: 'Mechanics',
              subtitle: 'Standby Nearby',
              trailingIcon: Icons.route_rounded,
              trailingBadge: activeJobRoute != null,
              onTrailingTap: activeJobRoute == null
                  ? null
                  : () => context.push(activeJobRoute, extra: activeJob!.id),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.navBarClearance,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.search_rounded,
                            label: 'Find Nearby\nMechanic',
                            onTap: () => FindMechanicSheet.show(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.calendar_today_outlined,
                            label: 'Schedule\nRepair',
                            onTap: () => MechanicIdLookupSheet.show(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: ImageAdCarousel(),
                  ),
                  const SizedBox(height: 24),

                  // ─── Nearby ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Text(
                      'Nearby Mechanics',
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
                    child: mechanicsAsync.when(
                      data: (mechanics) {
                        if (mechanics.isEmpty) {
                          return Text(
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
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          ],
        ),
      ),
    );
  }
}

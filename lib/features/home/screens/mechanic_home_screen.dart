// Mechanic Home screen — dashboard for mechanics.
// Shows greeting, diagnose car button, and incoming job requests.
// Nav bar: Scan (left) | Home (center, active) | Users (right).
// Bell icon top right.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/providers/job_provider.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../../profile/screens/mechanic_drawer_screen.dart';
import '../../../shared/providers/user_provider.dart';

class MechanicHomeScreen extends ConsumerStatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  ConsumerState<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends ConsumerState<MechanicHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final mechanicId = ref.watch(currentUserIdProvider);
    if (mechanicId != null) {
      // Foreground-only real-time listener for an incoming job request —
      // the one Rule-13-sanctioned case for a live query on this screen.
      ref.listen(pendingJobForMechanicProvider(mechanicId), (previous, next) {
        final job = next.valueOrNull;
        if (job != null && previous?.valueOrNull?.id != job.id) {
          context.push(RouteNames.mechanicIncomingCall, extra: job.id);
        }
      });
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const MechanicDrawerScreen(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          width: AppSpacing.iconButtonSize,
                          height: AppSpacing.iconButtonSize,
                          decoration: BoxDecoration(
                            color: const Color(0x08FFFFFF),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.menu_rounded,
                              size: 16, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: userAsync.when(
                          data: (user) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${user?.firstName.isNotEmpty == true ? user!.firstName : 'there'} 👋',
                                style: AppTypography.heading2,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const Text(
                                'Your Dashboard',
                                style: AppTypography.body,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                          loading: () => const _GreetingSkeleton(),
                          error: (_, __) => const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, there 👋',
                                style: AppTypography.heading2,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                'Your Dashboard',
                                style: AppTypography.body,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: AppSpacing.iconButtonSize,
                        height: AppSpacing.iconButtonSize,
                        decoration: BoxDecoration(
                          color: const Color(0x08FFFFFF),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            size: 16, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.navBarClearance),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Diagnose Car card ───────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: GestureDetector(
                            onTap: () => context.go(RouteNames.mechanicScan),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryButtonGradient,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33E8281E),
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.qr_code_scanner_rounded,
                                      color: Colors.white, size: 28),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Scan Customer',
                                    style: AppTypography.heading2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const Text(
                                    'Vehicle',
                                    style: AppTypography.heading2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to diagnose a customer\'s car with OBD',
                                    style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Job Requests section ────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Text(
                            'Job Requests',
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Builder(builder: (context) {
                            if (mechanicId == null) {
                              return const MechanicCardSkeleton();
                            }
                            final requestsAsync = ref.watch(
                                pendingJobsForMechanicProvider(mechanicId));
                            return requestsAsync.when(
                              data: (jobs) => jobs.isEmpty
                                  ? const Text('No job requests right now.',
                                      style: AppTypography.body)
                                  : Column(
                                      children: [
                                        for (final job in jobs) ...[
                                          _JobRequestTile(job: job),
                                          const SizedBox(height: 10),
                                        ],
                                      ],
                                    ),
                              loading: () => const Column(
                                children: [
                                  MechanicCardSkeleton(),
                                  SizedBox(height: 10),
                                  MechanicCardSkeleton(),
                                ],
                              ),
                              error: (_, __) => const Text(
                                  'Unable to load job requests.',
                                  style: AppTypography.body),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          AppNavBar(
            activeItem: NavBarItem.home,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () {},
            onThirdTap: () => context.go(RouteNames.mechanicUsers),
          ),
        ],
      ),
    );
  }
}

class _GreetingSkeleton extends StatelessWidget {
  const _GreetingSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 140, height: 20,
            decoration: BoxDecoration(color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 6),
        Container(width: 100, height: 14,
            decoration: BoxDecoration(color: const Color(0x0AFFFFFF),
                borderRadius: BorderRadius.circular(6))),
      ],
    );
  }
}

class _JobRequestTile extends ConsumerWidget {
  final JobModel job;
  const _JobRequestTile({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerAsync = ref.watch(mechanicUserProvider(job.carOwnerId));
    final ownerName = ownerAsync.valueOrNull != null
        ? '${ownerAsync.valueOrNull!.firstName} ${ownerAsync.valueOrNull!.lastName}'
            .trim()
        : 'Car Owner';
    return GestureDetector(
      onTap: () =>
          context.push(RouteNames.mechanicIncomingCall, extra: job.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x12FFFFFF)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ownerName,
                      style: AppTypography.bodyLarge,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  Text(job.issue,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0x33FFFFFF)),
          ],
        ),
      ),
    );
  }
}
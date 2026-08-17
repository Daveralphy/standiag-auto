// Mechanic Home screen — dashboard for mechanics.
// Shows greeting, own profile summary, and Pending/Active job sections.
// Nav bar: Scan (left) | Home (center, active) | Users (right).
// Bell icon top right.

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/services/fcm_token_service.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/providers/job_provider.dart';
import '../../jobs/providers/service_request_provider.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/mechanic_drawer_screen.dart';

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
    SystemUiStyle.apply();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mechanicId = ref.read(currentUserIdProvider);
      if (mechanicId != null) {
        registerMechanicFcmToken(mechanicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      // Counterpart for the quote flow: a job that lands directly in the
      // accepted state (the car owner picked this mechanic's quote) skips
      // the incoming-call screen entirely and goes straight to en route.
      ref.listen(acceptedJobForMechanicProvider(mechanicId), (previous, next) {
        final job = next.valueOrNull;
        if (job != null && previous?.valueOrNull?.id != job.id) {
          context.push(RouteNames.mechanicEnRoute, extra: job.id);
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
                AppScreenHeader(
                  scaffoldKey: _scaffoldKey,
                  showGreeting: true,
                  subtitle: 'Your Dashboard',
                  trailingIcon: Icons.notifications_outlined,
                  onTrailingTap: () =>
                      context.push(RouteNames.mechanicNotifications),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal).copyWith(
                        bottom: AppSpacing.navBarClearance),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Own profile summary card ────────────────────
                        if (mechanicId == null)
                          const _ProfileCardSkeleton()
                        else
                          _MechanicProfileCard(mechanicId: mechanicId),
                        const SizedBox(height: 24),

                        // ─── Pending section ──────────────────────────────
                        Text(
                          'PENDING',
                          style: AppTypography.captionLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 10),
                        if (mechanicId == null)
                          const _JobTileSkeleton()
                        else
                          Consumer(builder: (context, ref, _) {
                            final requestsAsync = ref.watch(
                                pendingJobsForMechanicProvider(mechanicId));
                            return requestsAsync.when(
                              data: (jobs) => jobs.isEmpty
                                  ? Text('No pending requests right now.',
                                      style: AppTypography.body)
                                  : Column(
                                      children: [
                                        for (final job in jobs) ...[
                                          _PendingJobTile(
                                              job: job, mechanicId: mechanicId),
                                          const SizedBox(height: 10),
                                        ],
                                      ],
                                    ),
                              loading: () => const Column(
                                children: [
                                  _JobTileSkeleton(),
                                  SizedBox(height: 10),
                                  _JobTileSkeleton(),
                                ],
                              ),
                              error: (_, __) => Text(
                                  'Unable to load pending requests.',
                                  style: AppTypography.body),
                            );
                          }),
                        const SizedBox(height: 24),

                        // ─── Nearby open requests — car owners who
                        // broadcast a search; quote to be considered ──────
                        Text(
                          'NEARBY REQUESTS',
                          style: AppTypography.captionLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 10),
                        if (mechanicId == null)
                          const _JobTileSkeleton()
                        else
                          Consumer(builder: (context, ref, _) {
                            final requestsAsync = ref
                                .watch(nearbyServiceRequestsProvider(mechanicId));
                            return requestsAsync.when(
                              data: (requests) => requests.isEmpty
                                  ? Text(
                                      'No one nearby is searching for a mechanic right now.',
                                      style: AppTypography.body)
                                  : Column(
                                      children: [
                                        for (final entry in requests) ...[
                                          _NearbyRequestTile(entry: entry),
                                          const SizedBox(height: 10),
                                        ],
                                      ],
                                    ),
                              loading: () => const Column(
                                children: [
                                  _JobTileSkeleton(),
                                  SizedBox(height: 10),
                                  _JobTileSkeleton(),
                                ],
                              ),
                              error: (_, __) => Text(
                                  'Unable to load nearby requests.',
                                  style: AppTypography.body),
                            );
                          }),
                        const SizedBox(height: 24),

                        // ─── Active section ───────────────────────────────
                        if (mechanicId != null)
                          Consumer(builder: (context, ref, _) {
                            final activeAsync = ref.watch(
                                activeJobForMechanicProvider(mechanicId));
                            return activeAsync.when(
                              data: (job) => job == null
                                  ? const SizedBox.shrink()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ACTIVE',
                                          style: AppTypography.captionLarge,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 10),
                                        _ActiveJobTile(job: job),
                                      ],
                                    ),
                              loading: () => const _JobTileSkeleton(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          }),
                      ],
                    ),
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

/// Haversine distance in kilometers between two Firestore GeoPoints.
double _distanceKm(GeoPoint a, GeoPoint b) {
  const earthRadiusKm = 6371.0;
  final dLat = _deg2rad(b.latitude - a.latitude);
  final dLon = _deg2rad(b.longitude - a.longitude);
  final lat1 = _deg2rad(a.latitude);
  final lat2 = _deg2rad(b.latitude);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
}

double _deg2rad(double deg) => deg * (math.pi / 180);

String _statusLabel(JobStatus status) {
  switch (status) {
    case JobStatus.accepted:
      return 'Accepted';
    case JobStatus.enRoute:
      return 'On The Way';
    case JobStatus.arrived:
      return 'Arrived';
    case JobStatus.inProgress:
      return 'In Progress';
    default:
      return 'Active';
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────

class _MechanicProfileCard extends ConsumerWidget {
  final String mechanicId;
  const _MechanicProfileCard({required this.mechanicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanicAsync = ref.watch(mechanicByIdProvider(mechanicId));
    final userAsync = ref.watch(userProfileProvider);

    return mechanicAsync.when(
      data: (mechanic) {
        final name = userAsync.valueOrNull?.firstName.isNotEmpty == true
            ? '${userAsync.valueOrNull!.firstName} ${userAsync.valueOrNull!.lastName}'
                .trim()
            : 'Your Profile';
        final expertise = mechanic?.expertise ?? const <String>[];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppTypography.heading4,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
              const SizedBox(height: 4),
              if (mechanic != null)
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 3),
                    Text(mechanic.rating.toStringAsFixed(1),
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Text('${mechanic.totalJobs} jobs',
                        style: AppTypography.bodySmall),
                  ],
                ),
              const SizedBox(height: 10),
              if (expertise.isEmpty)
                Text('No expertise added yet',
                    style: AppTypography.bodySmall)
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in expertise)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.borderSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(tag, style: AppTypography.captionLarge),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Diagnose a Car',
                onTap: () => context.go(RouteNames.mechanicScan),
              ),
            ],
          ),
        );
      },
      loading: () => const _ProfileCardSkeleton(),
      error: (_, __) => const _ProfileCardSkeleton(),
    );
  }
}

class _PendingJobTile extends ConsumerWidget {
  final JobModel job;
  final String mechanicId;
  const _PendingJobTile({required this.job, required this.mechanicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerAsync = ref.watch(mechanicUserProvider(job.carOwnerId));
    final vehicleAsync = ref.watch(vehicleByIdProvider(job.vehicleId));
    final mechanicAsync = ref.watch(mechanicByIdProvider(mechanicId));

    final ownerName = ownerAsync.valueOrNull != null
        ? '${ownerAsync.valueOrNull!.firstName} ${ownerAsync.valueOrNull!.lastName}'
            .trim()
        : 'Car Owner';
    final vehicleName = vehicleAsync.valueOrNull?.displayName;
    final subtitle =
        vehicleName != null ? '${job.issue} · $vehicleName' : job.issue;

    String? distanceLabel;
    final mechanicLocation = mechanicAsync.valueOrNull?.location;
    if (mechanicLocation != null && job.carOwnerLocation != null) {
      final km = _distanceKm(mechanicLocation, job.carOwnerLocation!);
      distanceLabel = '${km.toStringAsFixed(1)} km away';
    }

    return GestureDetector(
      onTap: () =>
          context.push(RouteNames.mechanicIncomingCall, extra: job.id),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ownerName,
                      style: AppTypography.heading4,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  if (distanceLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(distanceLabel,
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => context.push(RouteNames.mechanicActiveCall,
                  extra: job.id),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One open service request a mechanic can respond to with a quote — no
/// job exists yet, so unlike [_PendingJobTile] this always routes to the
/// send-quote screen rather than a call.
class _NearbyRequestTile extends ConsumerWidget {
  final NearbyServiceRequest entry;
  const _NearbyRequestTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = entry.request;
    final ownerAsync = ref.watch(mechanicUserProvider(request.carOwnerId));
    final ownerName = ownerAsync.valueOrNull != null
        ? '${ownerAsync.valueOrNull!.firstName} ${ownerAsync.valueOrNull!.lastName}'
            .trim()
        : 'Car Owner';

    return GestureDetector(
      onTap: () => context.push(RouteNames.sendQuote, extra: request.id),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ownerName,
                      style: AppTypography.heading4,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  const SizedBox(height: 2),
                  Text(request.issue,
                      style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  if (entry.distanceKm != null) ...[
                    const SizedBox(height: 2),
                    Text('${entry.distanceKm!.toStringAsFixed(1)} km away',
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryButtonGradient,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Text('Quote',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobTile extends ConsumerWidget {
  final JobModel job;
  const _ActiveJobTile({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerAsync = ref.watch(mechanicUserProvider(job.carOwnerId));
    final vehicleAsync = ref.watch(vehicleByIdProvider(job.vehicleId));

    final ownerName = ownerAsync.valueOrNull != null
        ? '${ownerAsync.valueOrNull!.firstName} ${ownerAsync.valueOrNull!.lastName}'
            .trim()
        : 'Car Owner';
    final vehicleName = vehicleAsync.valueOrNull?.displayName;
    final subtitle =
        vehicleName != null ? '${job.issue} · $vehicleName' : job.issue;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ownerName,
              style: AppTypography.heading4,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          const SizedBox(height: 2),
          Text(subtitle,
              style: AppTypography.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                      boxShadow: [
                        const BoxShadow(color: Color(0xCC4CAF50), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_statusLabel(job.status),
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.success)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ref
                      .read(jobProvider.notifier)
                      .updateStatus(job.id, JobStatus.completed);
                  context.go(RouteNames.mechanicJobCompleted, extra: job.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0x14E8281E),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: const Color(0x33E8281E)),
                  ),
                  child: Text('Close Job',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 140, height: 16,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 10),
          Container(width: 90, height: 12,
              decoration: BoxDecoration(color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 44,
              decoration: BoxDecoration(color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.full))),
        ],
      ),
    );
  }
}

class _JobTileSkeleton extends StatelessWidget {
  const _JobTileSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 14,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 80, height: 11,
                    decoration: BoxDecoration(color: AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

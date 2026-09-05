// Service History screen — user's past mechanic jobs.
// Matches design/history_screens.html Screen 1: title/vehicle/mechanic name/
// date/completed-badge card, no rating stars (those live in Job History).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/jobs/models/job_model.dart';
import '../../../features/jobs/providers/job_provider.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class ServiceHistoryScreen extends ConsumerStatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  ConsumerState<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends ConsumerState<ServiceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      ref.read(jobProvider.notifier).fetchHistory(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<JobState>(jobProvider, (_, next) {
      if (next.error != null) {
        AppErrorToast.showMessage(context, next.error!);
      }
    });

    final state = ref.watch(jobProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final history = state.jobHistory
        .where((job) => job.carOwnerId == userId && job.status == JobStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.userHome);
                    }
                  },
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(AppStrings.serviceHistoryTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: state.isLoading && history.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal),
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(height: 11),
                      itemBuilder: (_, __) => const _HistoryCardSkeleton(),
                    )
                  : history.isEmpty
                      ? Center(
                          child: Text('No completed services yet.',
                              style: AppTypography.body),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          itemCount: history.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 11),
                          itemBuilder: (_, i) =>
                              _HistoryCard(job: history[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final JobModel job;
  const _HistoryCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(job.vehicleId));
    final mechanicAsync = ref.watch(mechanicUserProvider(job.mechanicId));
    final vehicleName = vehicleAsync.valueOrNull?.displayName;
    final mechanicName = mechanicAsync.valueOrNull != null
        ? '${mechanicAsync.valueOrNull!.firstName} ${mechanicAsync.valueOrNull!.lastName}'
            .trim()
        : null;
    final duration = job.startedAt != null && job.completedAt != null
      ? _formatDuration(job.completedAt!.difference(job.startedAt!))
      : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(job.issue, style: AppTypography.bodyLarge,
            overflow: TextOverflow.ellipsis, maxLines: 1),
        if (vehicleName != null) ...[
          const SizedBox(height: 3),
          Text(vehicleName, style: AppTypography.body,
              overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
        const SizedBox(height: 3),
        Text(mechanicName ?? 'Mechanic', style: AppTypography.caption,
            overflow: TextOverflow.ellipsis, maxLines: 1),
        Text(
            Formatters.shortDate(job.completedAt ?? job.createdAt),
            style: AppTypography.caption,
            overflow: TextOverflow.ellipsis, maxLines: 1),
        if (duration != null)
          Text('Duration: $duration',
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis, maxLines: 1),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0x1A4CAF50),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: const Color(0x334CAF50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: AppColors.success, size: 11),
              const SizedBox(width: 4),
              Text('Completed',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11.5,
                    fontWeight: FontWeight.w700, color: AppColors.success,
                  )),
            ],
          ),
        ),
      ]),
    );
  }
}

String _formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return hours > 0
      ? '${hours}h ${minutes}m'
      : '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
}

class _HistoryCardSkeleton extends StatelessWidget {
  const _HistoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.wide(height: 14),
          SizedBox(height: 8),
          AppSkeleton(width: 120, height: 11),
          SizedBox(height: 6),
          AppSkeleton(width: 90, height: 10),
        ],
      ),
    );
  }
}

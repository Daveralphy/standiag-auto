// Job History screen — mechanic's completed job history.

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
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class JobHistoryScreen extends ConsumerStatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  ConsumerState<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends ConsumerState<JobHistoryScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
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
        .where((job) => job.mechanicId == userId && job.status == JobStatus.completed)
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
                  onTap: () => context.go(RouteNames.mechanicHome),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text(AppStrings.jobHistoryTitle,
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, __) => const _JobHistoryCardSkeleton(),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final job = history[i];
                        return _JobHistoryCard(
                          title: job.issue,
                          subtitle: job.vehicleId,
                          date: Formatters.relativeDate(
                              job.completedAt ?? job.createdAt),
                          rating: job.rating?.round() ?? 0,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobHistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final int rating;

  const _JobHistoryCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: AppTypography.bodyLarge,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
          Row(children: List.generate(5, (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < rating ? AppColors.amber : AppColors.textDisabled,
            size: 12))),
        ]),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTypography.body,
            overflow: TextOverflow.ellipsis, maxLines: 1),
        const SizedBox(height: 4),
        Text(date, style: AppTypography.caption,
            overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );
  }
}

class _JobHistoryCardSkeleton extends StatelessWidget {
  const _JobHistoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: AppSkeleton.wide(height: 14)),
              SizedBox(width: 12),
              AppSkeleton(width: 70, height: 12),
            ],
          ),
          SizedBox(height: 8),
          AppSkeleton(width: 120, height: 11),
          SizedBox(height: 6),
          AppSkeleton(width: 90, height: 10),
        ],
      ),
    );
  }
}

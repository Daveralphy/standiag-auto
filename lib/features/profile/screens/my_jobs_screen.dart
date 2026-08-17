// My Jobs screen — mechanic's list of active and completed jobs.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/jobs/models/job_model.dart';
import '../../../features/jobs/providers/job_provider.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
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
    final jobs = state.jobHistory
        .where((job) =>
            job.mechanicId == userId &&
            job.status != JobStatus.completed &&
            job.status != JobStatus.rejected)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.mechanicHome);
                    }
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(AppStrings.myJobsTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: state.isLoading && jobs.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal),
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, __) => const _JobCardSkeleton(),
                    )
                  : jobs.isEmpty
                      ? Center(
                          child: Text('No active jobs right now.',
                              style: AppTypography.body))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          itemCount: jobs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _JobCard(job: jobs[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  final JobModel job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerAsync = ref.watch(mechanicUserProvider(job.carOwnerId));
    final ownerName = ownerAsync.valueOrNull != null
        ? '${ownerAsync.valueOrNull!.firstName} ${ownerAsync.valueOrNull!.lastName}'
            .trim()
        : 'Car Owner';
    final isActive = job.status != JobStatus.completed;
    final statusLabel = switch (job.status) {
      JobStatus.pending => 'Pending',
      JobStatus.accepted => 'Accepted',
      JobStatus.enRoute => 'En Route',
      JobStatus.arrived => 'Arrived',
      JobStatus.inProgress => 'In Progress',
      JobStatus.completed => 'Completed',
      JobStatus.rejected => 'Rejected',
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ownerName, style: AppTypography.bodyLarge,
                overflow: TextOverflow.ellipsis, maxLines: 1),
            const SizedBox(height: 3),
            Text(job.issue, style: AppTypography.caption,
                overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primarySubtle : const Color(0x144CAF50),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isActive ? AppColors.primaryBorder : const Color(0x334CAF50))),
          child: Text(statusLabel,
              style: AppTypography.micro.copyWith(
                  color: isActive ? AppColors.primary : AppColors.success),
              overflow: TextOverflow.ellipsis, maxLines: 1)),
      ]),
    );
  }
}

class _JobCardSkeleton extends StatelessWidget {
  const _JobCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(child: AppSkeleton.wide(height: 14)),
          SizedBox(width: 12),
          AppSkeleton(width: 70, height: 20),
        ],
      ),
    );
  }
}

// My Jobs screen — mechanic's list of active and completed jobs.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/system_ui_style.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => context.pop(),
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
                Expanded(child: Text(AppStrings.myJobsTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _JobCard(
                  customerName: ['John Doe', 'Mary Johnson', 'Peter Smith'][i],
                  issue: ['Engine Problem', 'Brake Repair', 'AC Not Working'][i],
                  status: i == 0 ? 'In Progress' : 'Completed',
                  isActive: i == 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String customerName;
  final String issue;
  final String status;
  final bool isActive;

  const _JobCard({
    required this.customerName, required this.issue,
    required this.status, required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(customerName, style: AppTypography.bodyLarge,
                overflow: TextOverflow.ellipsis, maxLines: 1),
            const SizedBox(height: 3),
            Text(issue, style: AppTypography.caption,
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
          child: Text(status,
              style: AppTypography.micro.copyWith(
                  color: isActive ? AppColors.primary : AppColors.success),
              overflow: TextOverflow.ellipsis, maxLines: 1)),
      ]),
    );
  }
}
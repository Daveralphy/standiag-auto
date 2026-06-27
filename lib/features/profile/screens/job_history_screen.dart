// Job History screen — mechanic's completed job history.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/system_ui_style.dart';

class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _JobHistoryCard(
                  customer: ['John Doe', 'Mary Johnson',
                      'Peter Smith', 'Sarah Lee'][i],
                  issue: ['Engine Problem', 'Brake Repair',
                      'AC Not Working', 'Oil Change'][i],
                  date: ['29 May 2026', '15 Apr 2026',
                      '2 Mar 2026', '10 Jan 2026'][i],
                  rating: [4, 5, 3, 5][i],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobHistoryCard extends StatelessWidget {
  final String customer;
  final String issue;
  final String date;
  final int rating;

  const _JobHistoryCard({
    required this.customer, required this.issue,
    required this.date, required this.rating,
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
          Expanded(child: Text(customer, style: AppTypography.bodyLarge,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
          Row(children: List.generate(5, (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < rating ? AppColors.amber : AppColors.textDisabled,
            size: 12))),
        ]),
        const SizedBox(height: 4),
        Text(issue, style: AppTypography.body,
            overflow: TextOverflow.ellipsis, maxLines: 1),
        const SizedBox(height: 4),
        Text(date, style: AppTypography.caption,
            overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );
  }
}
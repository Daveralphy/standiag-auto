// Scan History screen — list of past OBD scans for the user.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/system_ui_style.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
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
                Expanded(child: Text(AppStrings.scanHistoryTitle,
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
                itemBuilder: (_, i) => _ScanCard(
                  vehicle: ['Toyota Corolla 2019', 'Toyota Corolla 2019',
                      'Honda Civic 2021', 'Honda Civic 2021'][i],
                  score: [8, 6, 9, 7][i],
                  date: ['29 May 2026', '20 Apr 2026',
                      '10 Mar 2026', '5 Jan 2026'][i],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final String vehicle;
  final int score;
  final String date;

  const _ScanCard({
    required this.vehicle, required this.score, required this.date,
  });

  Color get _scoreColor {
    if (score >= 8) return AppColors.success;
    if (score >= 5) return AppColors.amber;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _scoreColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: _scoreColor.withValues(alpha: 0.3))),
          child: Center(child: Text('$score',
              style: AppTypography.heading3.copyWith(color: _scoreColor),
              overflow: TextOverflow.ellipsis, maxLines: 1))),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vehicle, style: AppTypography.bodyLarge,
                overflow: TextOverflow.ellipsis, maxLines: 1),
            const SizedBox(height: 3),
            Text(date, style: AppTypography.caption,
                overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        )),
        Text('/10', style: AppTypography.caption,
            overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );
  }
}
// Credits Overview screen — shows balance, how credits work, and recent activity.
// History icon top right navigates to credits history.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/system_ui_style.dart';

class CreditsOverviewScreen extends StatefulWidget {
  const CreditsOverviewScreen({super.key});

  @override
  State<CreditsOverviewScreen> createState() => _CreditsOverviewScreenState();
}

class _CreditsOverviewScreenState extends State<CreditsOverviewScreen> {
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
                  onTap: () => context.go(RouteNames.userHome),
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
                const Expanded(child: Text(AppStrings.creditsTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                // History icon
                GestureDetector(
                  onTap: () => context.go(RouteNames.userCreditsHistory),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.history_rounded,
                        size: 16, color: AppColors.textMuted)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: AppColors.creditsCardGradient,
                        borderRadius:
                            BorderRadius.circular(AppRadius.creditsCard),
                        border: Border.all(
                            color: AppColors.primaryBorder)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.creditsBalance,
                              style: AppTypography.micro.copyWith(
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Text('48',
                                style: AppTypography.balanceDisplay,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            const SizedBox(width: 6),
                            Text('credits',
                                style: AppTypography.body.copyWith(
                                    color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                          ]),
                          const SizedBox(height: 16),
                          AppButton(
                            label: AppStrings.creditsBuy,
                            onTap: () => context.go(RouteNames.userBuyCredits),
                            width: 140,
                            paddingV: 11,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // How credits work
                    Text(AppStrings.creditsHowItWorks,
                        style: AppTypography.microBold.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 0.8),
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 10),
                    const _CreditRule(
                        label: AppStrings.creditsContactMechanic,
                        cost: AppStrings.creditsContactCost),
                    const SizedBox(height: 6),
                    const _CreditRule(
                        label: AppStrings.creditsOBDScan,
                        cost: AppStrings.creditsScanCost),
                    const SizedBox(height: 20),

                    // Recent activity
                    Text(AppStrings.creditsRecentActivity,
                        style: AppTypography.microBold.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 0.8),
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 10),
                    ...[
                      ('OBD Scan', 'Today · 10:24 AM', false, 10),
                      ('Contacted Kwame Asante', 'Today · 9:58 AM', false, 5),
                      ('Bought 100 credits', 'Yesterday · 3:12 PM', true, 100),
                      ('OBD Scan', '27 May · 2:05 PM', false, 10),
                    ].map((t) => _TransactionRow(
                      label: t.$1, date: t.$2,
                      isCredit: t.$3, amount: t.$4)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditRule extends StatelessWidget {
  final String label;
  final String cost;
  const _CreditRule({required this.label, required this.cost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle)),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTypography.bodySmall,
            overflow: TextOverflow.ellipsis, maxLines: 1)),
        Text(cost, style: AppTypography.bodySmall.copyWith(
            color: AppColors.primary, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String label;
  final String date;
  final bool isCredit;
  final int amount;

  const _TransactionRow({
    required this.label, required this.date,
    required this.isCredit, required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isCredit
                ? const Color(0x144CAF50)
                : AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isCredit
                  ? const Color(0x334CAF50)
                  : AppColors.primaryBorder)),
          child: Center(child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isCredit ? AppColors.success : AppColors.primary,
              shape: BoxShape.circle)))),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            Text(date, style: AppTypography.caption,
                overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        )),
        Text('${isCredit ? '+' : '-'}$amount cr',
            style: AppTypography.bodySmall.copyWith(
                color: isCredit ? AppColors.success : AppColors.primary,
                fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );
  }
}
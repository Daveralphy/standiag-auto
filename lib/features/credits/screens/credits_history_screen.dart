// Credits History screen — full transaction history for user credits.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/system_ui_style.dart';

class CreditsHistoryScreen extends StatefulWidget {
  const CreditsHistoryScreen({super.key});

  @override
  State<CreditsHistoryScreen> createState() => _CreditsHistoryScreenState();
}

class _CreditsHistoryScreenState extends State<CreditsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  static const List<_Transaction> _transactions = [
    _Transaction('OBD Scan', 'Today · 10:24 AM', false, 10),
    _Transaction('Contacted Kwame Asante', 'Today · 9:58 AM', false, 5),
    _Transaction('Bought 100 credits', 'Yesterday · 3:12 PM', true, 100),
    _Transaction('OBD Scan', '27 May · 2:05 PM', false, 10),
    _Transaction('Contacted Marc Dupont', '26 May · 11:30 AM', false, 5),
    _Transaction('Bought 250 credits', '20 May · 8:45 AM', true, 250),
    _Transaction('OBD Scan', '18 May · 4:20 PM', false, 10),
    _Transaction('Contacted Yusuf Ramos', '15 May · 1:10 PM', false, 5),
    _Transaction('First-time bonus', '1 May · 9:00 AM', true, 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.go(RouteNames.userCredits),
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
                const Expanded(child: Text(AppStrings.creditsHistoryTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                itemCount: _transactions.length,
                separatorBuilder: (_, __) => const Divider(
                    color: AppColors.borderSubtle, height: 1),
                itemBuilder: (_, i) {
                  final t = _transactions[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: t.isCredit
                              ? const Color(0x144CAF50)
                              : AppColors.primarySubtle,
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: t.isCredit
                                ? const Color(0x334CAF50)
                                : AppColors.primaryBorder)),
                        child: Center(child: Icon(
                          t.isCredit
                              ? Icons.add_rounded
                              : Icons.remove_rounded,
                          color: t.isCredit
                              ? AppColors.success
                              : AppColors.primary,
                          size: 16))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.label,
                              style: AppTypography.body,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                          Text(t.date,
                              style: AppTypography.caption,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ],
                      )),
                      Text('${t.isCredit ? '+' : '-'}${t.amount} cr',
                          style: AppTypography.bodySmall.copyWith(
                            color: t.isCredit
                                ? AppColors.success
                                : AppColors.primary,
                            fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ]),
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

class _Transaction {
  final String label;
  final String date;
  final bool isCredit;
  final int amount;
  const _Transaction(this.label, this.date, this.isCredit, this.amount);
}
// Credits History screen — full transaction history for user credits.

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
import '../../../core/utils/formatters.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/credits/providers/credits_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class CreditsHistoryScreen extends ConsumerStatefulWidget {
  const CreditsHistoryScreen({super.key});

  @override
  ConsumerState<CreditsHistoryScreen> createState() =>
      _CreditsHistoryScreenState();
}

class _CreditsHistoryScreenState extends ConsumerState<CreditsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      ref.read(creditsProvider.notifier).fetchHistory(userId);
      ref.read(creditsProvider.notifier).fetchBalance(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CreditsState>(creditsProvider, (_, next) {
      if (next.error != null) {
        AppErrorToast.showMessage(context, next.error!);
      }
    });

    final state = ref.watch(creditsProvider);
    final type = ref.watch(currentUserTypeProvider);
    final isMechanic = type == UserType.mechanic;

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
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(isMechanic
                          ? RouteNames.mechanicCredits
                          : RouteNames.userCredits);
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
                Expanded(child: Text(AppStrings.creditsHistoryTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.isLoading && state.history.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal),
                      itemCount: 8,
                      separatorBuilder: (_, __) => Divider(
                          color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: TransactionRowSkeleton(),
                      ),
                    )
                  : state.history.isEmpty
                      ? Center(
                          child: Text('No credit activity yet.',
                              style: AppTypography.body),
                        )
                      : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal),
                      itemCount: state.history.length,
                      itemBuilder: (_, i) {
                        final transaction = state.history[i];
                        final showMonthHeader = i == 0 ||
                            Formatters.monthYear(state.history[i - 1].createdAt) !=
                                Formatters.monthYear(transaction.createdAt);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showMonthHeader)
                              Padding(
                                padding: EdgeInsets.only(top: i == 0 ? 0 : 8, bottom: 8),
                                child: Text(
                                    Formatters.monthYear(transaction.createdAt)
                                        .toUpperCase(),
                                    style: AppTypography.microBold.copyWith(
                                        color: AppColors.textMuted,
                                        letterSpacing: 0.8)),
                              ),
                            Divider(color: AppColors.borderSubtle, height: 1),
                            Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: transaction.isCredit
                                    ? const Color(0x144CAF50)
                                    : AppColors.primarySubtle,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                border: Border.all(
                                  color: transaction.isCredit
                                      ? const Color(0x334CAF50)
                                      : AppColors.primaryBorder)),
                              child: Center(child: Icon(
                                transaction.isCredit
                                    ? Icons.add_rounded
                                    : Icons.remove_rounded,
                                color: transaction.isCredit
                                    ? AppColors.success
                                    : AppColors.primary,
                                size: 16))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.reason,
                                    style: AppTypography.body,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                                Text(Formatters.relativeDate(transaction.createdAt),
                                    style: AppTypography.caption,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              ],
                            )),
                            Text('${transaction.isCredit ? '+' : '-'}${transaction.amount} cr',
                                style: AppTypography.bodySmall.copyWith(
                                  color: transaction.isCredit
                                      ? AppColors.success
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                          ]),
                            ),
                          ],
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
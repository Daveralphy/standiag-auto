// Buy Credits screen — shows credit bundles for purchase in Naira.
// Bundle options: 10 free (first time), 100cr, 250cr, 500cr (best value), 1000cr.

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
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/credits_provider.dart';

class BuyCreditsScreen extends ConsumerStatefulWidget {
  const BuyCreditsScreen({super.key});

  @override
  ConsumerState<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends ConsumerState<BuyCreditsScreen> {
  int? _selectedBundle;

  static const List<_Bundle> _bundles = [
    _Bundle(credits: 100, priceNaira: 2000, label: null),
    _Bundle(credits: 250, priceNaira: 4500, label: null),
    _Bundle(credits: 500, priceNaira: 8500, label: 'Best Value'),
    _Bundle(credits: 1000, priceNaira: 15000, label: null),
  ];

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      ref.read(creditsProvider.notifier).fetchBalance(userId);
    }
  }

  Future<void> _purchase() async {
    final bundleIndex = _selectedBundle;
    final userId = ref.read(currentUserIdProvider);
    if (bundleIndex == null || userId == null) return;
    await ref
        .read(creditsProvider.notifier)
        .purchase(userId, _bundles[bundleIndex].credits);
    if (!mounted) return;
    final error = ref.read(creditsProvider).error;
    if (error != null) {
      AppErrorToast.showMessage(context, error);
      return;
    }
    context.go(RouteNames.userCredits);
  }

  @override
  Widget build(BuildContext context) {
    final creditsState = ref.watch(creditsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                      context.go(RouteNames.userCredits);
                    }
                  },
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
                const Expanded(child: Text(AppStrings.buyCreditsTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
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
                    // Current balance
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(AppStrings.creditsBalance,
                                style: AppTypography.caption,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            const SizedBox(height: 4),
                            Text('${creditsState.balance} credits',
                                style: AppTypography.heading3,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                          ],
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0x144CAF50),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                                color: const Color(0x334CAF50))),
                          child: Text('Active',
                              style: AppTypography.micro.copyWith(
                                  color: AppColors.success),
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    Text(AppStrings.buyCreditsChoose,
                        style: AppTypography.microBold.copyWith(
                            color: AppColors.textMuted, letterSpacing: 0.8),
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 10),

                    // Bundle cards
                    ...List.generate(_bundles.length, (i) {
                      final b = _bundles[i];
                      final isSelected = _selectedBundle == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedBundle = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySubtle
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1)),
                          child: Row(children: [
                            // Selection circle
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderActive,
                                  width: 1.5)),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 12, color: Colors.white)
                                  : null),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text('${b.credits} Credits',
                                      style: AppTypography.bodyLarge,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                  if (b.label != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.full)),
                                      child: Text(b.label!,
                                          style: AppTypography.micro.copyWith(
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1)),
                                  ],
                                ]),
                                Text(Formatters.naira(b.priceNaira),
                                    style: AppTypography.body.copyWith(
                                        color: AppColors.textMuted),
                                    overflow: TextOverflow.ellipsis, maxLines: 1),
                              ],
                            )),
                          ]),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                    AppButton(
                      label: _selectedBundle != null
                          ? 'Pay ${Formatters.naira(_bundles[_selectedBundle!].priceNaira)}'
                          : AppStrings.buyCreditsConfirm,
                      onTap: _selectedBundle != null ? _purchase : null,
                      isLoading: creditsState.isPurchasing,
                    ),
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

class _Bundle {
  final int credits;
  final int priceNaira;
  final String? label;
  const _Bundle({
    required this.credits,
    required this.priceNaira,
    this.label,
  });
}
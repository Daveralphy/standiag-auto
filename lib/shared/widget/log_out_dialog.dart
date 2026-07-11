// Shared "Log Out" confirmation dialog used by both the CarOwner and
// Mechanic drawers. Matches the log-out modal in design/drawers.html.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import 'app_button.dart';

class LogOutDialog {
  LogOutDialog._();

  /// Shows the confirmation dialog and resolves to true if the user
  /// confirmed the log out, false (or null) if they cancelled/dismissed it.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xB8000000),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.modal),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(false),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0x0FFFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 13, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                AppStrings.logOutTitle,
                style: AppTypography.heading3,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.logOutMessage,
                style: AppTypography.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppStrings.logOutCancel,
                      variant: AppButtonVariant.ghost,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: AppStrings.logOutConfirm,
                      variant: AppButtonVariant.danger,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }
}

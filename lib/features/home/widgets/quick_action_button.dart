// Quick Action Button widget — a compact icon + label button used
// on the home screen for quick navigation to key features.

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primarySubtle
                  : const Color(0x0DFFFFFF),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isActive
                    ? AppColors.primaryBorder
                    : AppColors.border,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.micro,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
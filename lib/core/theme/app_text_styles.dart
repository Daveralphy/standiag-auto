import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle heroTitle = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.2,
  );
  static const TextStyle stepTitle = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.5, height: 1.15,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600,
    color: AppColors.textTertiary, letterSpacing: 1.5,
  );
  static const TextStyle button = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: 0.8,
  );
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
  );
  static const TextStyle dtcCode = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700,
    color: AppColors.primary, fontFamily: 'monospace', letterSpacing: 0.5,
  );
  static const TextStyle navLabel = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w500,
  );
  static const TextStyle inputLabel = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600,
    color: AppColors.textTertiary, letterSpacing: 1.5,
  );
  static const TextStyle stepLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.primary, letterSpacing: 1.5,
  );
  static const TextStyle statValue = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
  );
  static const TextStyle statLabel = TextStyle(
    fontSize: 9, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.8,
  );
  static const TextStyle link = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary,
  );
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Field Labels ─────────────────────────────────────────
  // Used above input fields — small, uppercase, muted
  static const fieldLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    letterSpacing: 1.5,
    fontFamily: 'Inter',
  );

  // ── Input Text ───────────────────────────────────────────
  // The actual text the user types
  static const inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // ── Hint Text ────────────────────────────────────────────
  static const hintText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textDisabled,
    fontFamily: 'Inter',
  );

  // ── Section Labels ───────────────────────────────────────
  // ACCOUNT, NOTIFICATIONS, MY VEHICLES etc.
  static const sectionLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    letterSpacing: 1.5,
    fontFamily: 'Inter',
  );

  // ── Screen Title ─────────────────────────────────────────
  static const screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // ── Card Title ───────────────────────────────────────────
  static const cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // ── Body ─────────────────────────────────────────────────
  static const body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
    fontFamily: 'Inter',
  );

  // ── Caption ──────────────────────────────────────────────
  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    fontFamily: 'Inter',
  );

  // ── Button Label ─────────────────────────────────────────
  static const buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.3,
    fontFamily: 'Inter',
  );

  // ── Auth Heading ─────────────────────────────────────────
  // "Welcome back." / "What's your name?" etc.
  static const authHeading = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.4,
    fontFamily: 'Inter',
  );

  // ── Auth Subheading ──────────────────────────────────────
  static const authSubheading = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );
}

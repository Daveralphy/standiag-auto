// Defines every text style used in StanDiag Auto.
// Never define a TextStyle inline in any widget — always reference this class.
// All values are derived directly from the HTML design files in /design/.
// All fonts use Inter. Font files must exist in /assets/fonts/Inter/.

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Private constructor — this class is never instantiated.
  AppTypography._();

  // ─── Font Family ───────────────────────────────────────────────────────────

  static const String _fontFamily = 'Inter';

  // ─── Display ───────────────────────────────────────────────────────────────

  /// 28px, weight 900. Used for large page titles like "Who are you?".
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.1,
  );

  /// 26px, weight 900. Used for onboarding and section page titles.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.1,
  );

  // ─── Headings ──────────────────────────────────────────────────────────────

  /// 24px, weight 900. Used for large section headers and balance figures.
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.1,
  );

  /// 20px, weight 800. Used for card titles and prominent names.
  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );

  /// 16px, weight 800. Used for screen nav headers and section titles.
  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.1,
  );

  /// 15px, weight 800. Used for mechanic/user names on profile cards.
  static const TextStyle heading4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.2,
  );

  // ─── Body ──────────────────────────────────────────────────────────────────

  /// 13px, weight 600. Used for list item titles and card primary labels.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.4,
  );

  /// 13px, weight 500. Used for general body text and descriptions.
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// 12px, weight 500. Used for secondary body text and form hints.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.6,
  );

  /// 11.5px, weight 400. Used for subtitles and helper descriptions.
  static const TextStyle subtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.6,
  );

  /// 11px, weight 500. Used for drawer menu items and form subtitles.
  static const TextStyle bodyXSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // ─── Captions & Labels ─────────────────────────────────────────────────────

  /// 10.5px, weight 600. Used for status labels and secondary identifiers.
  static const TextStyle captionLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// 10px, weight 500. Used for meta text, dates, and secondary info.
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textDim,
    height: 1.4,
  );

  /// 9.5px, weight 600. Used for small labels on cards and list items.
  static const TextStyle captionSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textDim,
    height: 1.4,
  );

  /// 9px, weight 600. Used for nav bar labels and status bar time.
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// 9px, weight 700. Used for active nav bar label.
  static const TextStyle labelActive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.0,
  );

  /// 9px, weight 600. Used for inactive nav bar label.
  static const TextStyle labelInactive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    height: 1.0,
  );

  // ─── Micro ─────────────────────────────────────────────────────────────────

  /// 8.5px, weight 600. Used for expertise tags, badge labels.
  static const TextStyle micro = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 8.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textTag,
    height: 1.0,
  );

  /// 8px, weight 700. Used for "Best Value" badge and tiny uppercase labels.
  static const TextStyle microBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.5,
    height: 1.0,
  );

  // ─── Button ────────────────────────────────────────────────────────────────

  /// 13.5px, weight 700. Used for primary action buttons.
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// 13px, weight 600. Used for ghost/secondary buttons.
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    height: 1.0,
  );

  // ─── Input ─────────────────────────────────────────────────────────────────

  /// 12px, weight 500. Used for text inside input fields.
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// 9.5px, weight 600. Used for floating input field labels.
  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    height: 1.0,
  );

  /// 9.5px, weight 600. Used for focused floating input field labels.
  static const TextStyle inputLabelFocused = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.0,
  );

  // ─── Special ───────────────────────────────────────────────────────────────

  /// Large balance number. Used for the credits balance display.
  static const TextStyle balanceDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -2,
    height: 1.0,
  );

  /// Large health score number. Used for OBD scan result display.
  static const TextStyle healthScore = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -2,
    height: 1.0,
  );

  /// Large stat number. Used for ETA, distance, and job count displays.
  static const TextStyle statNumber = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.0,
  );

  /// Wordmark style. Used for "StanDiag Auto" branding text if rendered in Flutter.
  static const TextStyle wordmark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.0,
  );
}
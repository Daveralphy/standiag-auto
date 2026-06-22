// Defines every color used in StanDiag Auto.
// Never use a raw hex color anywhere in the app — always reference this class.
// All values are derived directly from the HTML design files in /design/.

import 'package:flutter/material.dart';

class AppColors {
  // Private constructor — this class is never instantiated.
  AppColors._();

  // ─── Backgrounds ───────────────────────────────────────────────────────────

  /// Main app background. Used on every screen.
  static const Color background = Color(0xFF0A0A0A);

  /// Outer page background. Used as the scaffold background.
  static const Color backgroundPage = Color(0xFF0D0D0D);

  /// Card and surface background. Used on cards, drawers, modals.
  static const Color surface = Color(0xFF141414);

  /// Slightly elevated surface. Used on error toasts and raised elements.
  static const Color surfaceElevated = Color(0xFF1A1A1A);

  /// Map background color.
  static const Color mapBackground = Color(0xFF0F1218);

  /// Map road color (main roads).
  static const Color mapRoad = Color(0xFF182028);

  /// Map road color (secondary roads).
  static const Color mapRoadSecondary = Color(0xFF141B22);

  /// Map building color.
  static const Color mapBuilding = Color(0xFF111820);

  /// Map park / green area color.
  static const Color mapPark = Color(0xFF0D1A10);

  // ─── Primary (Brand Red) ───────────────────────────────────────────────────

  /// Main brand color. Used on active buttons, selected states, accents.
  static const Color primary = Color(0xFFE8281E);

  /// Button gradient start (top).
  static const Color primaryLight = Color(0xFFF03328);

  /// Button gradient end (bottom).
  static const Color primaryDark = Color(0xFFC41F16);

  /// Subtle primary tint. Used as card background on selected state.
  static const Color primarySubtle = Color(0x14E8281E); // 8% opacity

  /// Primary border tint. Used as card border on selected state.
  static const Color primaryBorder = Color(0x33E8281E); // 20% opacity

  // ─── Text ──────────────────────────────────────────────────────────────────

  /// Full white. Used for primary headings and important labels.
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// 70% white. Used for secondary text and body content.
  static const Color textSecondary = Color(0xB3FFFFFF);

  /// 40% white. Used for subtitles, hints, and muted labels.
  static const Color textMuted = Color(0x66FFFFFF);

  /// 25% white. Used for placeholder text and very muted labels.
  static const Color textDim = Color(0x40FFFFFF);

  /// 20% white. Used for disabled and inactive text.
  static const Color textDisabled = Color(0x33FFFFFF);

  /// 35% white. Used for tag labels and expertise pills.
  static const Color textTag = Color(0x59FFFFFF);

  // ─── Semantic ──────────────────────────────────────────────────────────────

  /// Green. Used for completed jobs, online status, good health scores.
  static const Color success = Color(0xFF4CAF50);

  /// Subtle green tint. Used as background on success banners.
  static const Color successSubtle = Color(0x14E8281E); // matches design

  /// Amber. Used for pending states and star rating fill color.
  static const Color amber = Color(0xFFF59E0B);

  /// Yellow. Used for warning indicators.
  static const Color warning = Color(0xFFFFC107);

  /// Blue. Used for mechanic map pin and OBD connected indicator.
  static const Color blue = Color(0xFF3B82F6);

  /// Subtle blue tint. Used as mechanic pin background on map.
  static const Color blueSubtle = Color(0xFF1A2535);

  // ─── Borders ───────────────────────────────────────────────────────────────

  /// Standard card border.
  static const Color border = Color(0x12FFFFFF); // 7% opacity

  /// Subtle divider border.
  static const Color borderSubtle = Color(0x0DFFFFFF); // 5% opacity

  /// Active element border (inputs, focused cards).
  static const Color borderActive = Color(0x1AFFFFFF); // 10% opacity

  // ─── Navigation Bar ────────────────────────────────────────────────────────

  /// Nav bar background with blur. Applied as a Color only — blur handled in widget.
  static const Color navBarBackground = Color(0xE10E0E0E); // 88% opacity

  /// Nav bar border.
  static const Color navBarBorder = Color(0x14FFFFFF); // 8% opacity

  /// Nav bar outer ring for active item glow.
  static const Color navBarActiveGlow = Color(0x40E8281E); // 25% opacity

  // ─── Gradients ─────────────────────────────────────────────────────────────

  /// Primary button gradient. Use with LinearGradient, top to bottom.
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, primaryDark],
  );

  /// Dark red card gradient. Used on the credits balance card.
  static const LinearGradient creditsCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A0A0A), Color(0xFF1F0D0D)],
  );
}
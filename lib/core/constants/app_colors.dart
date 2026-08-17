// Defines every color used in StanDiag Auto.
// Never use a raw hex color anywhere in the app — always reference this class.
// Dark values are derived directly from the HTML design files in /design/.
// Light values were derived from the dark palette (no light mockups exist):
// backgrounds/text/borders inverted, brand red and semantic colors kept
// identical since they already read fine on both backgrounds.
//
// Every field below is a getter, not a constant, so it can reflect whichever
// theme is currently active — set once per frame by StanDiagApp via
// [setBrightness], read by every screen through the same AppColors.xxx call
// sites as before. [dark] and [light] expose the two raw, independent
// palettes directly — that's what AppTheme uses to build two stable
// ThemeData objects, deliberately bypassing the current-theme flag so
// MaterialApp always has both to switch between.

import 'package:flutter/material.dart';

class AppColors {
  // Private constructor — this class is never instantiated.
  AppColors._();

  static Brightness _brightness = Brightness.dark;
  static bool get _isDark => _brightness == Brightness.dark;

  /// Called once per frame from StanDiagApp's build(), before any
  /// descendant widget builds, so every getter below is consistent for the
  /// whole frame.
  static void setBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static const AppColorPalette dark = AppColorPalette.dark();
  static const AppColorPalette light = AppColorPalette.light();

  // ─── Backgrounds ───────────────────────────────────────────────────────────

  static Color get background => _isDark ? dark.background : light.background;
  static Color get backgroundPage => _isDark ? dark.backgroundPage : light.backgroundPage;
  static Color get surface => _isDark ? dark.surface : light.surface;
  static Color get surfaceElevated => _isDark ? dark.surfaceElevated : light.surfaceElevated;
  static Color get mapBackground => _isDark ? dark.mapBackground : light.mapBackground;
  static Color get mapRoad => _isDark ? dark.mapRoad : light.mapRoad;
  static Color get mapRoadSecondary => _isDark ? dark.mapRoadSecondary : light.mapRoadSecondary;
  static Color get mapBuilding => _isDark ? dark.mapBuilding : light.mapBuilding;
  static Color get mapPark => _isDark ? dark.mapPark : light.mapPark;

  // ─── Primary (Brand Red) ───────────────────────────────────────────────────

  static Color get primary => _isDark ? dark.primary : light.primary;
  static Color get primaryLight => _isDark ? dark.primaryLight : light.primaryLight;
  static Color get primaryDark => _isDark ? dark.primaryDark : light.primaryDark;
  static Color get primarySubtle => _isDark ? dark.primarySubtle : light.primarySubtle;
  static Color get primaryBorder => _isDark ? dark.primaryBorder : light.primaryBorder;

  // ─── Text ──────────────────────────────────────────────────────────────────

  static Color get textPrimary => _isDark ? dark.textPrimary : light.textPrimary;
  static Color get textSecondary => _isDark ? dark.textSecondary : light.textSecondary;
  static Color get textMuted => _isDark ? dark.textMuted : light.textMuted;
  static Color get textDim => _isDark ? dark.textDim : light.textDim;
  static Color get textDisabled => _isDark ? dark.textDisabled : light.textDisabled;
  static Color get textTag => _isDark ? dark.textTag : light.textTag;

  // ─── Semantic ──────────────────────────────────────────────────────────────

  static Color get success => _isDark ? dark.success : light.success;
  static Color get successSubtle => _isDark ? dark.successSubtle : light.successSubtle;
  static Color get amber => _isDark ? dark.amber : light.amber;
  static Color get warning => _isDark ? dark.warning : light.warning;
  static Color get blue => _isDark ? dark.blue : light.blue;
  static Color get blueSubtle => _isDark ? dark.blueSubtle : light.blueSubtle;

  // ─── Borders ───────────────────────────────────────────────────────────────

  static Color get border => _isDark ? dark.border : light.border;
  static Color get borderSubtle => _isDark ? dark.borderSubtle : light.borderSubtle;
  static Color get borderActive => _isDark ? dark.borderActive : light.borderActive;

  // ─── Navigation Bar ────────────────────────────────────────────────────────

  static Color get navBarBackground => _isDark ? dark.navBarBackground : light.navBarBackground;
  static Color get navBarBorder => _isDark ? dark.navBarBorder : light.navBarBorder;
  static Color get navBarActiveGlow => _isDark ? dark.navBarActiveGlow : light.navBarActiveGlow;

  // ─── Gradients ─────────────────────────────────────────────────────────────

  static LinearGradient get primaryButtonGradient =>
      _isDark ? dark.primaryButtonGradient : light.primaryButtonGradient;
  static LinearGradient get creditsCardGradient =>
      _isDark ? dark.creditsCardGradient : light.creditsCardGradient;
}

/// Raw, theme-independent color values. Two const instances (dark/light)
/// exist below — this class itself is never used for anything but holding
/// one palette's worth of values.
class AppColorPalette {
  final Color background;
  final Color backgroundPage;
  final Color surface;
  final Color surfaceElevated;
  final Color mapBackground;
  final Color mapRoad;
  final Color mapRoadSecondary;
  final Color mapBuilding;
  final Color mapPark;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primarySubtle;
  final Color primaryBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDim;
  final Color textDisabled;
  final Color textTag;
  final Color success;
  final Color successSubtle;
  final Color amber;
  final Color warning;
  final Color blue;
  final Color blueSubtle;
  final Color border;
  final Color borderSubtle;
  final Color borderActive;
  final Color navBarBackground;
  final Color navBarBorder;
  final Color navBarActiveGlow;
  final LinearGradient primaryButtonGradient;
  final LinearGradient creditsCardGradient;

  const AppColorPalette.dark()
      : background = const Color(0xFF0A0A0A),
        backgroundPage = const Color(0xFF0D0D0D),
        surface = const Color(0xFF141414),
        surfaceElevated = const Color(0xFF1A1A1A),
        mapBackground = const Color(0xFF0F1218),
        mapRoad = const Color(0xFF182028),
        mapRoadSecondary = const Color(0xFF141B22),
        mapBuilding = const Color(0xFF111820),
        mapPark = const Color(0xFF0D1A10),
        primary = const Color(0xFFE8281E),
        primaryLight = const Color(0xFFF03328),
        primaryDark = const Color(0xFFC41F16),
        primarySubtle = const Color(0x14E8281E), // 8% opacity
        primaryBorder = const Color(0x33E8281E), // 20% opacity
        textPrimary = const Color(0xFFFFFFFF),
        textSecondary = const Color(0xB3FFFFFF), // 70% white
        textMuted = const Color(0x66FFFFFF), // 40% white
        textDim = const Color(0x40FFFFFF), // 25% white
        textDisabled = const Color(0x33FFFFFF), // 20% white
        textTag = const Color(0x59FFFFFF), // 35% white
        success = const Color(0xFF4CAF50),
        successSubtle = const Color(0x14E8281E), // matches design
        amber = const Color(0xFFF59E0B),
        warning = const Color(0xFFFFC107),
        blue = const Color(0xFF3B82F6),
        blueSubtle = const Color(0xFF1A2535),
        border = const Color(0x12FFFFFF), // 7% opacity
        borderSubtle = const Color(0x0DFFFFFF), // 5% opacity
        borderActive = const Color(0x1AFFFFFF), // 10% opacity
        navBarBackground = const Color(0xE10E0E0E), // 88% opacity
        navBarBorder = const Color(0x14FFFFFF), // 8% opacity
        navBarActiveGlow = const Color(0x40E8281E), // 25% opacity
        primaryButtonGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF03328), Color(0xFFC41F16)],
        ),
        creditsCardGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A0A), Color(0xFF1F0D0D)],
        );

  const AppColorPalette.light()
      : background = const Color(0xFFF2F2F3),
        backgroundPage = const Color(0xFFF5F5F6),
        surface = const Color(0xFFFDFDFD),
        surfaceElevated = const Color(0xFFFFFFFF),
        mapBackground = const Color(0xFFF5F6F8),
        mapRoad = const Color(0xFFFFFFFF),
        mapRoadSecondary = const Color(0xFFF0F1F3),
        mapBuilding = const Color(0xFFE8EAED),
        mapPark = const Color(0xFFDCEEDC),
        primary = const Color(0xFFE8281E),
        primaryLight = const Color(0xFFF03328),
        primaryDark = const Color(0xFFC41F16),
        primarySubtle = const Color(0x14E8281E), // 8% opacity — reads on either bg
        primaryBorder = const Color(0x33E8281E), // 20% opacity
        textPrimary = const Color(0xFF121212),
        textSecondary = const Color(0xB3121212), // 70%
        textMuted = const Color(0x66121212), // 40%
        textDim = const Color(0x40121212), // 25%
        textDisabled = const Color(0x33121212), // 20%
        textTag = const Color(0x59121212), // 35%
        success = const Color(0xFF4CAF50),
        successSubtle = const Color(0x14E8281E), // matches design
        amber = const Color(0xFFF59E0B),
        warning = const Color(0xFFFFC107),
        blue = const Color(0xFF3B82F6),
        blueSubtle = const Color(0xFFE3EDFC),
        border = const Color(0x12121212), // 7% opacity
        borderSubtle = const Color(0x0D121212), // 5% opacity
        borderActive = const Color(0x1A121212), // 10% opacity
        navBarBackground = const Color(0xE1FAFAFA), // 88% opacity
        navBarBorder = const Color(0x14121212), // 8% opacity
        navBarActiveGlow = const Color(0x40E8281E), // 25% opacity
        primaryButtonGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF03328), Color(0xFFC41F16)],
        ),
        // Deliberately kept dark even in light mode — a "hero" balance card
        // that pops against a light background, same idea many finance apps
        // use regardless of overall theme.
        creditsCardGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A0A), Color(0xFF1F0D0D)],
        );
}

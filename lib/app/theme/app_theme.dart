import 'package:flutter/material.dart';

/// Standiag Auto dark visual system: near-black foundations, readable white
/// text, and crimson actions with deeper burgundy surfaces.
abstract final class AppTheme {
  static const Color background = Color(0xFF090A0C);
  static const Color surface = Color(0xFF151518);
  static const Color elevatedSurface = Color(0xFF1D1D22);
  static const Color burgundy = Color(0xFF4A0D18);
  static const Color crimson = Color(0xFFD71935);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE1E1E5);
  static const Color outline = Color(0xFF48484F);

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: crimson,
      brightness: Brightness.dark,
      primary: crimson,
      onPrimary: Colors.white,
      secondary: burgundy,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: const Color(0xFFFF6B75),
      onError: const Color(0xFF240006),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: textPrimary,
            displayColor: textPrimary,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: Color(0xFFB8B8C0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: crimson, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: crimson,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4A2027),
          disabledForegroundColor: const Color(0xFFD2C5C8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: crimson,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4A2027),
          disabledForegroundColor: const Color(0xFFD2C5C8),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: textPrimary,
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF667A)),
      ),
      dividerTheme: const DividerThemeData(color: outline, space: 1),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: elevatedSurface,
        contentTextStyle: TextStyle(color: textPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: crimson,
      ),
    );
  }
}

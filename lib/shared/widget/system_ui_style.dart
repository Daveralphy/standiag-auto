// Controls the appearance of the phone's system status bar.
// This file does NOT draw a status bar widget.
// The phone's OS owns and renders the actual status bar.
// This file uses SystemChrome to style it — icon brightness and background.
//
// Call SystemUiStyle.apply() at the start of each screen's initState — it
// picks whichever style matches the app's current theme, kept in sync by
// StanDiagApp via setBrightness(). applyDark()/applyLight() below remain
// for anywhere that deliberately wants one specific style regardless of
// the current theme (there's currently no such place, but no reason to
// remove the option).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiStyle {
  // Private constructor — this class is never instantiated.
  SystemUiStyle._();

  static Brightness _brightness = Brightness.dark;

  /// Kept in sync with AppColors' brightness by StanDiagApp's build() —
  /// same single source of truth (settingsProvider.theme), read here so
  /// apply() knows which style to use.
  static void setBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  /// Light icons (white) on a transparent background. Used on dark screens.
  static const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // white icons on Android
    statusBarBrightness: Brightness.dark, // dark background hint for iOS
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Dark icons (black) on a transparent background. Used on light screens.
  static const SystemUiOverlayStyle light = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // dark icons on Android
    statusBarBrightness: Brightness.light, // light background hint for iOS
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Applies whichever style matches the app's current theme. This is what
  /// every screen should call — not applyDark()/applyLight() directly.
  static void apply() {
    SystemChrome.setSystemUIOverlayStyle(
        _brightness == Brightness.dark ? dark : light);
  }

  /// Applies the dark (white icons) style immediately, regardless of the
  /// app's current theme.
  static void applyDark() {
    SystemChrome.setSystemUIOverlayStyle(dark);
  }

  /// Applies the light (dark icons) style immediately, regardless of the
  /// app's current theme.
  static void applyLight() {
    SystemChrome.setSystemUIOverlayStyle(light);
  }

  /// Makes the status bar and navigation bar fully transparent
  /// and sets edge-to-edge mode so the app draws behind them.
  /// Call once in main.dart before runApp().
  static void setEdgeToEdge() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(dark);
  }
}

// Controls the appearance of the phone's system status bar.
// This file does NOT draw a status bar widget.
// The phone's OS owns and renders the actual status bar.
// This file uses SystemChrome to style it — icon brightness and background.
//
// Call the appropriate method at the start of each screen's initState,
// or wrap screen builds with the relevant style.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiStyle {
  // Private constructor — this class is never instantiated.
  SystemUiStyle._();

  /// Light icons (white) on a transparent background.
  /// Use on all dark screens — which is every screen in this app.
  static const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // white icons on Android
    statusBarBrightness: Brightness.dark, // dark background hint for iOS
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Dark icons (black) on a transparent background.
  /// Not used in StanDiag Auto by default (app is dark-only),
  /// but defined here in case a light-mode variant is added later.
  static const SystemUiOverlayStyle light = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // dark icons on Android
    statusBarBrightness: Brightness.light, // light background hint for iOS
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Applies the dark (white icons) style immediately.
  /// Call in initState or at the top of build() when needed.
  static void applyDark() {
    SystemChrome.setSystemUIOverlayStyle(dark);
  }

  /// Applies the light (dark icons) style immediately.
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
import 'package:flutter/material.dart';

/// Responsive sizing utility for StanDiag Auto.
/// Usage: context.sp(14) — scales font size to screen width.
/// Usage: context.r(16)  — scales any dimension to screen width.
extension ResponsiveExt on BuildContext {
  double get _base {
    final w = MediaQuery.of(this).size.width;
    // Base scale: 390px (iPhone 14) = 1.0
    // Tablets (768px+) capped at 1.35 so UI doesnt get too huge
    return (w / 390).clamp(0.85, 1.35);
  }

  /// Scale a font size
  double sp(double size) => size * _base;

  /// Scale any dimension (padding, icon size, etc)
  double r(double size) => size * _base;
}
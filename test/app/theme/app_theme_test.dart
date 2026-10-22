import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('provides Material 3 light and dark themes', () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.dark.useMaterial3, isTrue);
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test('uses the shared brand action color in both modes', () {
      expect(AppTheme.light.colorScheme.primary, const Color(0xFFDC2626));
      expect(AppTheme.dark.colorScheme.primary, const Color(0xFFDC2626));
    });
  });
}

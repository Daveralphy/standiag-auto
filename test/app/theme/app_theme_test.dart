import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app.dart';
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

  testWidgets('shows setup guidance when Firebase is not configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StanDiagApp(startupError: 'Firebase configuration missing'),
    );

    expect(find.text('One setup step left'), findsOneWidget);
    expect(find.textContaining('FIREBASE_API_KEY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('setup screen remains usable at a narrow phone width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const StanDiagApp(startupError: 'Firebase configuration missing'),
    );

    expect(find.text('One setup step left'), findsOneWidget);
    expect(find.textContaining('FIREBASE_API_KEY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('setup guidance respects the system dark theme', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      const StanDiagApp(startupError: 'Firebase configuration missing'),
    );

    expect(find.text('One setup step left'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

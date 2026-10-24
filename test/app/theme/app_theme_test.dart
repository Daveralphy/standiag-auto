import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app.dart';
import 'package:standiag_auto/app/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('provides a Material 3 dark-only theme with readable contrast', () {
      expect(AppTheme.dark.useMaterial3, isTrue);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.dark.scaffoldBackgroundColor, const Color(0xFF090A0C));
      expect(AppTheme.dark.colorScheme.primary, const Color(0xFFD71935));
      expect(AppTheme.dark.colorScheme.onSurface, Colors.white);
    });
  });

  testWidgets('shows setup guidance when Firebase is not configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      StanDiagApp(startupError: StateError('Firebase configuration missing')),
    );

    expect(find.text('Complete app setup'), findsOneWidget);
    expect(find.textContaining('Firebase client values'), findsOneWidget);
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
      StanDiagApp(startupError: StateError('Firebase configuration missing')),
    );

    expect(find.text('Complete app setup'), findsOneWidget);
    expect(find.textContaining('Firebase client values'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('setup guidance stays dark regardless of system theme', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      StanDiagApp(startupError: StateError('Firebase configuration missing')),
    );

    expect(find.text('Complete app setup'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

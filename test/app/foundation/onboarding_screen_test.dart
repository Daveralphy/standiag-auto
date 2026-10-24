import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/foundation/onboarding_screen.dart';
import 'package:standiag_auto/app/theme/app_theme.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const OnboardingScreen(),
    );
  }

  testWidgets('starts with the first onboarding slide in the dark theme',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.textContaining('Help for your'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.byTooltip('Next'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Next advances to the second onboarding slide', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Trusted'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Skip opens the welcome account-choice screen', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Let’s get you started'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

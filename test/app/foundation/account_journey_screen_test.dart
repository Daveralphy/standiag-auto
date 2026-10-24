import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/foundation/account_journey_screen.dart';
import 'package:standiag_auto/app/foundation/mechanic_application_status_screen.dart';
import 'package:standiag_auto/app/theme/app_theme.dart';

void main() {
  Widget buildScreen() {
    return MaterialApp(
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      home: AccountJourneyScreen(
        email: 'verified@example.com',
        onSignOut: () async {},
        isSigningOut: false,
      ),
    );
  }

  testWidgets('offers customer use and mechanic application on one account', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());

    expect(find.text('I need car care'), findsOneWidget);
    expect(find.text('I repair vehicles'), findsOneWidget);
    expect(find.text('verified@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mechanic form validates details without claiming submission', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());

    await tester.scrollUntilVisible(
      find.text('Apply as a mechanic'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Apply as a mechanic'));
    await tester.pumpAndSettle();

    expect(find.text('Base address or service area'), findsOneWidget);
    await tester.tap(find.text('Submit for review'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Complete all required fields.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('journey screen lays out at a narrow width', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen());

    expect(find.text('I need car care'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mechanic application is clear that approval is separate', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.scrollUntilVisible(
      find.text('Apply as a mechanic'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Apply as a mechanic'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('does not automatically approve'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('already-applied mechanic opens the dedicated status screen', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());

    await tester.scrollUntilVisible(
      find.text('Already applied as a mechanic?'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Already applied as a mechanic?'));
    await tester.pumpAndSettle();

    expect(find.byType(MechanicApplicationStatusScreen), findsOneWidget);
    expect(find.text('Check application status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}

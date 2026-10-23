import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/foundation/support_pages.dart';

void main() {
  group('NotificationsScreen', () {
    testWidgets('shows a useful empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotificationsScreen()),
      );

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Notifications'),
        ),
        findsOneWidget,
      );
      expect(find.text('Notifications need a connection'), findsOneWidget);
      expect(find.textContaining('Connect Firebase to load notifications'), findsOneWidget);
    });
  });

  group('AccountSettingsScreen', () {
    testWidgets('shows the signed-in account details', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountSettingsScreen(
            email: 'driver@example.com',
            roleLabel: 'Customer',
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Account settings'),
        ),
        findsOneWidget,
      );
      expect(find.text('driver@example.com'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Reset password'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Terms of service'), findsOneWidget);
    });
  });

  group('LegalInfoScreen', () {
    testWidgets('marks preliminary legal copy as a draft', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalInfoScreen(kind: LegalInfoKind.privacy),
        ),
      );

      expect(find.text('Privacy policy'), findsWidgets);
      expect(find.textContaining('DRAFT'), findsOneWidget);
      expect(find.text('Account information'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the about screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalInfoScreen(kind: LegalInfoKind.about),
        ),
      );

      expect(find.text('About Standiag Auto'), findsWidgets);
      expect(find.textContaining('Some workflows are still under development'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('HelpSupportScreen', () {
    testWidgets('lists common questions and expands answers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpSupportScreen()),
      );

      expect(find.text('How do I request a repair?'), findsOneWidget);
      expect(find.text('Why can I not access mechanic tools?'), findsOneWidget);

      await tester.tap(find.text('How do I request a repair?'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Save a vehicle, open Explore'), findsOneWidget);
    });
  });
}

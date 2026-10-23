import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/foundation/support_pages.dart';

void main() {
  group('NotificationsScreen', () {
    testWidgets('shows a useful empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotificationsScreen()),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('You are all caught up'), findsOneWidget);
      expect(find.textContaining('account or repair updates'), findsOneWidget);
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

      expect(find.text('Account settings'), findsOneWidget);
      expect(find.text('driver@example.com'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Profile editing, password and security controls will be added here when their account workflows are connected. Your account details are not editable from this preview.'), findsOneWidget);
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

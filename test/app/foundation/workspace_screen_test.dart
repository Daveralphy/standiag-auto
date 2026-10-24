import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/foundation/workspace_screen.dart';
import 'package:standiag_auto/app/theme/app_theme.dart';

void main() {
  Widget buildScreen(WorkspaceRole role, {Future<void> Function()? onSignOut}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: WorkspaceScreen(
        email: 'driver@example.com',
        role: role,
        onSignOut: onSignOut ?? () async {},
      ),
    );
  }

  testWidgets('customer workspace exposes the four planned destinations', (tester) async {
    await tester.pumpWidget(buildScreen(WorkspaceRole.customer));

    expect(find.text('Your car care, simplified.'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('My repairs'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer can navigate to mechanic discovery', (tester) async {
    await tester.pumpWidget(buildScreen(WorkspaceRole.customer));

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    expect(find.text('Find a mechanic'), findsOneWidget);
    expect(find.text('Mechanics will show up here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mechanic workspace uses its own navigation and job content', (tester) async {
    await tester.pumpWidget(buildScreen(WorkspaceRole.mechanic));

    expect(find.text('Ready for your next job?'), findsOneWidget);
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Earnings'), findsOneWidget);

    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();

    expect(find.text('Job requests'), findsOneWidget);
    expect(find.textContaining('Connect Firebase to load jobs assigned to your mechanic account.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer workspace lays out on a narrow phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen(WorkspaceRole.customer));

    expect(find.text('Your car care, simplified.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile sign out invokes the supplied callback', (tester) async {
    var signedOut = false;
    await tester.pumpWidget(buildScreen(
      WorkspaceRole.customer,
      onSignOut: () async { signedOut = true; },
    ));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(signedOut, isTrue);
    expect(tester.takeException(), isNull);
  });
}

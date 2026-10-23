import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/foundation/mechanic_jobs_screen.dart';
import 'package:standiag_auto/app/theme/app_theme.dart';

void main() {
  testWidgets('job detail and earnings screens show sign-in states without a user', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: Column(
          children: [
            Expanded(child: MechanicJobsScreen()),
            Expanded(child: MechanicEarningsScreen()),
          ],
        ),
      ),
    ));

    expect(find.text('Sign in to view jobs'), findsOneWidget);
    expect(find.text('Sign in to view earnings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mechanic job inbox fits a narrow screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: MechanicJobsScreen()),
    ));

    expect(find.text('Sign in to view jobs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

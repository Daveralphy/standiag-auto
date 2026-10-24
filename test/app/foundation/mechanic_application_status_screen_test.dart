import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app/foundation/mechanic_application_status_screen.dart';
import 'package:standiag_auto/app/theme/app_theme.dart';

void main() {
  testWidgets('shows status guidance and lets applicant return to setup', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: const MechanicApplicationStatusScreen(),
    ));

    expect(find.text('Mechanic application'), findsOneWidget);
    expect(find.text('Check your application'), findsOneWidget);
    expect(find.text('Check application status'), findsOneWidget);
    expect(find.textContaining('does not automatically grant mechanic access'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status screen fits a narrow phone width', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const MechanicApplicationStatusScreen(),
    ));

    expect(find.text('Check application status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

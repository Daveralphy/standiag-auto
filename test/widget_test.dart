import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StanDiagApp());
  });
}

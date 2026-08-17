import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:standiag_auto/app.dart';
import 'package:standiag_auto/core/cache/cache_keys.dart';

void main() {
  // StanDiagApp reads settingsProvider (to pick the app's theme), which
  // opens the settings Hive box on construction — main.dart normally opens
  // every box via CacheManager.instance.init() before runApp(). Hive.init
  // (rather than Hive.initFlutter) avoids needing path_provider's platform
  // channel, which plain `flutter test` doesn't mock.
  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('standiag_test_hive');
    Hive.init(dir.path);
    await Future.wait([
      Hive.openBox(CacheKeys.userBox),
      Hive.openBox(CacheKeys.mechanicBox),
      Hive.openBox(CacheKeys.vehiclesBox),
      Hive.openBox(CacheKeys.scansBox),
      Hive.openBox(CacheKeys.creditsBox),
      Hive.openBox(CacheKeys.settingsBox),
    ]);
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: StanDiagApp()));
  });
}

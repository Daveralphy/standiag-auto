import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/cache/cache_manager.dart';
import 'firebase_options.dart';
import 'shared/widget/system_ui_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Firebase ─────────────────────────────────────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics only ships plugin support for Android, iOS, and macOS —
  // calling it on web/Windows/Linux throws and would crash the app at
  // startup, so the hooks that call into it are only wired up there.
  final bool crashlyticsSupported =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
  if (crashlyticsSupported) {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  // ─── Local Cache ──────────────────────────────────────────────────────────
  await CacheManager.instance.init();

  // ─── System UI ────────────────────────────────────────────────────────────
  SystemUiStyle.setEdgeToEdge();

  // ─── Run ──────────────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: StanDiagApp()));
}
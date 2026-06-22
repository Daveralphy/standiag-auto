// Entry point for StanDiag Auto.
// Initialises Firebase, Hive cache, and edge-to-edge system UI
// before handing off to the root App widget.
//
// TODO: Run 'flutterfire configure' to generate firebase_options.dart,
// then uncomment the Firebase initialisation block below.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/cache/cache_manager.dart';
import 'shared/widget/system_ui_style.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Firebase ─────────────────────────────────────────────────────────────
  // Uncomment this block after running 'flutterfire configure':
  //
  // import 'package:firebase_core/firebase_core.dart';
  // import 'package:firebase_crashlytics/firebase_crashlytics.dart';
  // import 'firebase_options.dart';
  //
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FlutterError.onError = (details) =>
  //     FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   ErrorHandler.handle(error, stack);
  //   return true;
  // };
  // await FirebaseCrashlytics.instance
  //     .setCrashlyticsCollectionEnabled(!kDebugMode);

  // ─── Local Cache ──────────────────────────────────────────────────────────
  await CacheManager.instance.init();

  // ─── System UI ────────────────────────────────────────────────────────────
  SystemUiStyle.setEdgeToEdge();

  // ─── Run ──────────────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: StanDiagApp()));
}
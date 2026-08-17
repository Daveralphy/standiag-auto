import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/cache/cache_manager.dart';
import 'firebase_options.dart';
import 'shared/services/fcm_token_service.dart';
import 'shared/widget/system_ui_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Environment ──────────────────────────────────────────────────────────
  // .env is gitignored and won't exist on a fresh clone or CI runner until
  // someone copies .env.example and fills it in — features that need a key
  // from it (calls, OTP email) surface a clear "not configured" error at
  // the point of use instead of crashing startup here.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // ─── Firebase ─────────────────────────────────────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
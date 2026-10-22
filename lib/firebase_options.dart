import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase client configuration supplied at build/run time.
///
/// Firebase client API keys are configuration values, not Admin SDK secrets.
/// Pass the project's web API key with --dart-define=FIREBASE_API_KEY=... .
/// Keep service-account keys and other privileged credentials out of the app.
abstract final class DefaultFirebaseOptions {
  static const String _apiKey = String.fromEnvironment('FIREBASE_API_KEY');

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: _apiKey,
    appId: '1:625237396713:android:01cac950a4b6ab67b93478',
    messagingSenderId: '625237396713',
    projectId: 'standiag-auto',
  );

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: '1:625237396713:ios:584a19c3d7de0019b93478',
    messagingSenderId: '625237396713',
    projectId: 'standiag-auto',
  );

  static const FirebaseOptions _web = FirebaseOptions(
    apiKey: _apiKey,
    appId: '1:625237396713:web:7b220ba8bf77ce6bb93478',
    messagingSenderId: '625237396713',
    projectId: 'standiag-auto',
  );

  static FirebaseOptions get currentPlatform {
    if (_apiKey.isEmpty) {
      throw StateError(
        'Firebase is not configured. Run the app with '
        '--dart-define=FIREBASE_API_KEY=YOUR_FIREBASE_WEB_API_KEY. '
        'Find the client API key in the Firebase project settings.',
      );
    }

    if (kIsWeb) return _web;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _android,
      TargetPlatform.iOS || TargetPlatform.macOS => _ios,
      TargetPlatform.windows || TargetPlatform.linux => _web,
      TargetPlatform.fuchsia => throw UnsupportedError(
          'Standiag Auto does not support Fuchsia.',
        ),
    };
  }
}

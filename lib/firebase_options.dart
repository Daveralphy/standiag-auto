import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase client configuration injected at build time.
///
/// These values identify a Firebase client app. Never put service-account
/// credentials, private keys, or privileged server secrets in a Flutter app.
abstract final class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _webAppId = String.fromEnvironment('FIREBASE_APP_ID_WEB');
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_APP_ID_ANDROID',
  );
  static const _iosAppId = String.fromEnvironment('FIREBASE_APP_ID_IOS');
  static const _macosAppId = String.fromEnvironment('FIREBASE_APP_ID_MACOS');

  static FirebaseOptions get currentPlatform {
    final appId = switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidAppId,
      TargetPlatform.iOS => _iosAppId,
      TargetPlatform.macOS => _macosAppId,
      TargetPlatform.windows || TargetPlatform.linux => '',
      TargetPlatform.fuchsia => '',
    };

    final effectiveAppId = kIsWeb ? _webAppId : appId;
    final missing = <String>[
      if (_apiKey.isEmpty) 'FIREBASE_API_KEY',
      if (_projectId.isEmpty) 'FIREBASE_PROJECT_ID',
      if (_senderId.isEmpty) 'FIREBASE_MESSAGING_SENDER_ID',
      if (effectiveAppId.isEmpty)
        kIsWeb
            ? 'FIREBASE_APP_ID_WEB'
            : switch (defaultTargetPlatform) {
                TargetPlatform.android => 'FIREBASE_APP_ID_ANDROID',
                TargetPlatform.iOS => 'FIREBASE_APP_ID_IOS',
                TargetPlatform.macOS => 'FIREBASE_APP_ID_MACOS',
                TargetPlatform.windows || TargetPlatform.linux =>
                  'a supported Firebase platform (Android, iOS, web, or macOS)',
                TargetPlatform.fuchsia => 'a supported Firebase platform',
              },
    ];

    if (missing.isNotEmpty) {
      throw StateError(
        'Firebase client configuration is incomplete. Missing: '
        '${missing.join(', ')}. Supply these values with --dart-define. '
        'Get the client app values from Firebase Console → Project settings. '
        'Do not use a service-account key.',
      );
    }

    return FirebaseOptions(
      apiKey: _apiKey,
      appId: effectiveAppId,
      messagingSenderId: _senderId,
      projectId: _projectId,
    );
  }
}

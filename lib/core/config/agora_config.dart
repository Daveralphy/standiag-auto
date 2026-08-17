// Agora powers StanDiag Auto's in-app voice calls between car owners and
// mechanics. The App ID lives in .env (gitignored, never committed) rather
// than here, so swapping to a different owner's Agora project — testing vs.
// the eventual brand owner's production project — never touches a tracked
// file. See .env.example for the full setup steps.
//
// Until AGORA_APP_ID is set, CallEngineService throws a clear "not
// configured" error before ever touching the microphone, instead of
// failing silently or crashing.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraConfig {
  AgoraConfig._();

  static String get appId => dotenv.env['AGORA_APP_ID'] ?? '';

  static bool get isConfigured => appId.isNotEmpty;
}

// Google and Apple sign-in credentials for StanDiag Auto. All of it lives
// in .env (gitignored, never committed) rather than here, so swapping to a
// different owner's Google Cloud / Apple Developer accounts — this dev
// setup vs. the eventual brand owner's production one — is just replacing
// values in .env, never touching code. See .env.example for the full
// setup steps for each provider.
//
// Until the relevant values are set, AuthController.signInWithGoogle /
// signInWithApple throw a clear "not configured" error before ever
// opening a sign-in sheet, instead of failing with a confusing native
// error partway through.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocialSignInConfig {
  SocialSignInConfig._();

  // Google — the "Web client ID" from Firebase console (Authentication >
  // Sign-in method > Google), used as serverClientId on Android/iOS (the
  // only way to get a Firebase-usable ID token there) and as the client ID
  // directly on web.
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  // Google — the iOS OAuth client ID. Normally read from
  // GoogleService-Info.plist, which this app deliberately doesn't use (see
  // firebase_options.dart) — so it's supplied explicitly instead.
  static String get googleIosClientId =>
      dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;

  // Apple — only needed for the Android/web sign-in path (native iOS/macOS
  // sign-in needs just the Xcode "Sign in with Apple" capability, already
  // wired in ios/Runner/Runner.entitlements). The Services ID is configured
  // in the Apple Developer portal under Certificates, Identifiers & Profiles
  // > Identifiers > Services IDs; the redirect URI is a page you host that
  // bounces the OAuth response back into the app.
  static String get appleServiceId =>
      dotenv.env['APPLE_SIGNIN_SERVICE_ID'] ?? '';
  static String get appleRedirectUri =>
      dotenv.env['APPLE_SIGNIN_REDIRECT_URI'] ?? '';

  static bool get isAppleConfiguredForAndroid =>
      appleServiceId.isNotEmpty && appleRedirectUri.isNotEmpty;
}

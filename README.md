# Standiag Auto

Standiag Auto is being rebuilt as an on-demand car-repair marketplace that helps customers find mechanics and workshops and helps providers manage repair work.

## Project status

This repository is in a fresh rebuild. The previous application is legacy reference material, not architecture that the new product must preserve. Features are being reintroduced only when they belong to the agreed product and their data contracts or integrations have been verified.

## Product experiences

### Customers
- Home
- Explore
- My Repairs
- Profile

### Mechanics and workshops
- Home
- Jobs
- Earnings
- Profile

## Technology

- Flutter / Dart
- Firebase Authentication and Cloud Firestore
- Material 3 with light and dark themes from the beginning

## Local setup

1. Install Flutter with a Dart SDK compatible with `pubspec.yaml`.
2. In Firebase Console, open **Project settings → General** and copy the client app configuration values for each platform you intend to run. The app expects these Dart defines:
   - `FIREBASE_API_KEY`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_APP_ID_WEB` for Chrome/web
   - `FIREBASE_APP_ID_ANDROID` for Android
   - `FIREBASE_APP_ID_IOS` for iOS
   - `FIREBASE_APP_ID_MACOS` for macOS
3. Fetch dependencies and run the web version, supplying the web app values:

   ```sh
   flutter pub get
   flutter run -d chrome \
     --dart-define=FIREBASE_API_KEY=YOUR_CLIENT_API_KEY \
     --dart-define=FIREBASE_PROJECT_ID=YOUR_PROJECT_ID \
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID \
     --dart-define=FIREBASE_APP_ID_WEB=YOUR_WEB_APP_ID
   ```

   For Android or iOS, provide that platform's app ID instead of the web app ID. Enable **Email/Password** in Firebase Console → Authentication → Sign-in method before testing account creation or sign-in. New accounts must verify their email before entering the signed-in workspace. Configure authorized domains for web authentication as needed.
4. Verify changes:

   ```sh
   dart format lib test
   flutter analyze
   flutter test
   ```

Firebase client configuration identifies the project and is not equivalent to a server credential. Never put service-account keys, private keys, signing credentials, or privileged secrets into a Flutter app or source control. Missing configuration is reported by a setup screen rather than silently replaced with invented IDs.

## Development rules

- Work on a feature branch; do not push directly to `main`.
- Follow [CONTRIBUTING.md](CONTRIBUTING.md).
- Verify whether persisted Firestore data, security rules, or deployed Cloud Functions depend on a field before changing it.
- Do not retain features merely because legacy code exists, and do not remove data-contract models before their production dependencies have been audited.
- Keep styling in the shared theme and use `Theme.of(context)` in widgets.
- Implement and verify light and dark appearances together.
- Design for narrow phones first, then adapt to larger phones, tablets, and desktop. Avoid fixed widths where content should wrap or constrain itself.
- Account for keyboard insets, safe areas, long text, and accessibility text scaling.
- Do not claim a feature, test, or build works unless it has actually been verified.

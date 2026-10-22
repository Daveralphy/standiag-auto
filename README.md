# Standiag Auto

Standiag Auto is being rebuilt as an on-demand car-repair marketplace that helps customers find mechanics and workshops and helps providers manage repair work.

## Project status

This repository is in a fresh rebuild. The existing application is legacy reference material, not the architecture that the new product must preserve. Features are being reintroduced only when they are part of the agreed product and their data contracts or integrations have been verified.

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
- Firebase Authentication and Cloud Firestore for identity and persisted data
- Material 3 with light and dark themes from the beginning

Additional dependencies will be added only when the rebuilt product needs them.

## Local setup

1. Install the Flutter SDK compatible with the Dart constraint in `pubspec.yaml`.
2. In Firebase Console, open **Project settings → General** and copy the project's **Web API key**. Firebase client API keys identify the project; never use an Admin SDK service-account key in the app.
3. Fetch packages and run the app with the key supplied at runtime:

   ```sh
   flutter pub get
   flutter run -d chrome --dart-define=FIREBASE_API_KEY=YOUR_FIREBASE_WEB_API_KEY
   ```

   For Android, use the same define when building/running. Android-specific Firebase configuration and platform tooling may also be required for some Firebase services. Enable Email/Password under Firebase Authentication → Sign-in method before testing sign-in or account creation.
4. Verify changes with:

   ```sh
   dart format lib test
   flutter analyze
   flutter test
   ```

If the Firebase configuration is missing, the app shows a setup screen instead of crashing during startup. Do not commit service-account keys, signing credentials, or other privileged secrets.

## Development rules

- Work on a feature branch; do not push directly to `main`.
- Follow [CONTRIBUTING.md](CONTRIBUTING.md).
- Verify whether persisted Firestore data, security rules, or deployed Cloud Functions depend on a field before changing it.
- Do not retain a feature merely because legacy code exists.
- Keep UI styling in the shared theme and use `Theme.of(context)` in widgets.
- Implement and verify light and dark appearances together.
- Design for narrow phone widths first, then adapt to larger phones, tablets, and desktop. Avoid fixed widths where content can wrap or constrain itself.
- Account for keyboard insets, safe areas, long text, and accessibility text scaling.
- Do not claim a feature, test, or build works unless it has actually been verified.

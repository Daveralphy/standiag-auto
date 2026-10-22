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
2. Configure Firebase for the platforms you intend to run and generate `lib/firebase_options.dart`.
3. Supply any required platform Firebase configuration locally. Never commit private keys or production secrets.
4. Run:

   ```sh
   flutter pub get
   dart format lib test
   flutter analyze
   flutter test
   flutter run
   ```

Some of these commands may currently report issues while the rebuild is in progress. Do not treat the legacy app as a finished product.

## Development rules

- Work on a feature branch; do not push directly to `main`.
- Follow [CONTRIBUTING.md](CONTRIBUTING.md).
- Verify whether persisted Firestore data, security rules, or deployed Cloud Functions depend on a field before changing it.
- Do not retain a feature merely because legacy code exists.
- Keep UI styling in the shared theme and use `Theme.of(context)` in widgets.
- Implement and verify light and dark appearances together.
- Do not claim a feature, test, or build works unless it has actually been verified.

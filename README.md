# Standiag Auto

**A redesigned car-repair experience built with Flutter.**

Standiag Auto is an on-demand car-repair app concept focused on making it easier for customers to find suitable mechanics or workshops and manage their repair journey.

> This repository showcases the current redesign and ongoing development. Features that depend on Firebase or external services may require project configuration and may not be available in a fresh install.

## Preview and Android build

- **Repository:** https://github.com/Daveralphy/standiag-auto
- **Download Android APK:** [Open the latest release](https://github.com/Daveralphy/standiag-auto/releases/latest)

The APK link will work once an APK has been attached to a GitHub Release. No release or downloadable APK is currently present in the repository, so a build still needs to be published there.

## Product experience

### Customer app
- **Home** — an at-a-glance dashboard and access to core tasks.
- **Explore** — discover mechanics and repair options.
- **My Repairs** — follow repair requests and repair activity.
- **Profile** — manage account details and supported profile features.

### Mechanics and workshops
The app is being developed to support service providers and workshop workflows alongside the customer experience. Availability depends on the current implementation and configured backend.

## Technology

- Flutter and Dart
- Firebase Authentication and Cloud Firestore
- Shared Material theming for consistent styling
- Responsive layouts and accessibility-aware interaction patterns

## Run locally

1. Install Flutter and a compatible Dart SDK.
2. Configure Firebase for the platform you want to run. The app reads client configuration through Dart defines:
   - `FIREBASE_API_KEY`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_APP_ID_WEB` for web
   - `FIREBASE_APP_ID_ANDROID` for Android
   - `FIREBASE_APP_ID_IOS` for iOS
   - `FIREBASE_APP_ID_MACOS` for macOS
3. Fetch dependencies:

   ```sh
   flutter pub get
   ```

4. Run on a configured device or emulator:

   ```sh
   flutter run
   ```

For web, pass the web Firebase values using `--dart-define` arguments. Enable the required Firebase Authentication providers in the Firebase Console before testing sign-in and registration.

## Verify changes

```sh
dart format lib test
flutter analyze
flutter test
```

Run these checks in your environment before relying on a build. This README does not claim the current branch has been freshly built or tested.

## Security notes

Firebase client configuration identifies the project; it is not a substitute for server credentials. Never commit service-account keys, private keys, signing credentials, or privileged secrets. Review Firestore rules and Cloud Functions before deploying changes to a production Firebase project.

## Development

- Use feature branches for future changes.
- Keep app colors and shared styling in the shared theme.
- Verify both light and dark appearances when changing UI.
- Test narrow-screen layouts, safe areas, keyboard insets, and accessibility text scaling.
- Do not claim a feature is complete until its implementation and dependencies have been verified.

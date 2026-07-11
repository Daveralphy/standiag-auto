# StanDiag Auto

Your mechanic, on demand.

StanDiag Auto connects car owners with nearby mechanics in real time. Car owners describe an issue, get matched with a verified mechanic nearby, call them in-app, and rate the job afterward. Mechanics receive incoming requests, negotiate, accept or reject jobs, navigate to the car owner, and complete jobs. Both roles share one app; the experience splits after the profile-type picker on first launch.

## Features

- **Car owners** — OBD-II vehicle diagnostics via Bluetooth, mechanic search by radius, in-app voice calls, live job tracking, ratings, vehicle and service history, a credits-based payment model.
- **Mechanics** — incoming job requests, live location sharing while en route, job history, a profile with expertise tags and ratings.
- Shared account features: phone/email verification, credits and purchase history, settings (language, appearance, privacy, notifications), password management, account deletion.

## Tech stack

- **Flutter** / Dart
- **Riverpod** for state management
- **GoRouter** for navigation
- **Firebase** — Auth, Firestore, Storage, Crashlytics
- **Agora** for in-app voice calls
- **Google Maps** for location and tracking
- **Hive** for local persistent caching

## Getting started

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Firebase setup
- Create a Firebase project at https://console.firebase.google.com
- Enable Authentication (Email/Password + Phone), Firestore, Storage, and Crashlytics
- Download `google-services.json` into `android/app/`
- Download `GoogleService-Info.plist` into `ios/Runner/`

These files are gitignored and must never be committed.

### 3. Google Maps
- Enable the Maps SDK for Android and iOS in Google Cloud Console
- Add your API key to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`

### 4. Agora
- Create a project at https://console.agora.io and add your App ID to your environment config (never hardcode it in source)

### 5. Run
```bash
flutter run
```

## Project structure

```
lib/
├── core/           # constants, navigation, error handling, caching, utils
├── features/       # one folder per feature area (auth, home, jobs, mechanics,
│                   # profile, credits, settings, scan, onboarding), each with
│                   # its own screens/, providers/, and models/
└── shared/         # widgets and providers used across multiple features
```

Further reading:
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — data model, provider ownership, caching strategy, navigation map
- [`DESIGN.md`](DESIGN.md) — colors, typography, spacing, and component specs
- [`ERRORS.md`](ERRORS.md) — the full error-message reference shown to users
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — setup, conventions, and how to add a new screen

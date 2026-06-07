# StanDiag Auto

**Your mechanic, on demand.**

StanDiag Auto is a mobile application that connects car owners with nearby mechanics in real time. Think of it as the Uber for car repairs — a car owner requests help, a nearby mechanic responds, they agree on a job, and it gets done.

---

## Repository

- **GitHub:** https://github.com/Daveralphy/standiag-auto.git
- **Owner:** @daveralphy
- **Platform:** Flutter (iOS & Android)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter |
| State Management | Riverpod |
| Backend / Database | Firebase (Firestore, Auth, Storage, Crashlytics) |
| Real-time Calls | Agora (voice over data) |
| Maps | Google Maps Flutter Plugin |
| OBD Diagnostics | Flutter Bluetooth Plugin |
| Local Cache | Hive |
| Analytics / Logs | Firebase Crashlytics |

---

## Exact Repository File Structure

Every file and folder in this repository must follow this structure exactly. No file should be created outside this structure without updating this README first.

```
standiag-auto/
│
├── README.md
├── CLAUDE.md
├── ARCHITECTURE.md
├── CONTRIBUTING.md
├── ERRORS.md
├── DESIGN.md
├── .gitignore
├── pubspec.yaml
├── analysis_options.yaml
│
├── design/
│   ├── onboarding_final.html
│   ├── auth_screens.html
│   ├── mechanic_auth.html
│   ├── login_screens.html
│   ├── home_screens.html
│   ├── mechanic_home.html
│   ├── mechanics_flow.html
│   ├── mechanics_flow_2.html
│   ├── mechanic_call_flow.html
│   ├── on_the_way.html
│   ├── job_flow.html
│   ├── job_completed.html
│   ├── drawers.html
│   ├── profile_screens.html
│   ├── vehicles_jobs.html
│   ├── history_screens.html
│   ├── settings_help.html
│   ├── language_appearance_privacy.html
│   ├── splash_screens.html
│   ├── password_delete.html
│   └── credits.html
│
├── assets/
│   ├── images/
│   │   ├── logo_icon.png
│   │   ├── logo_full.png
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   └── onboarding_3.png
│   └── fonts/
│       └── Inter/
│           ├── Inter-Regular.ttf
│           ├── Inter-Medium.ttf
│           ├── Inter-SemiBold.ttf
│           ├── Inter-Bold.ttf
│           ├── Inter-ExtraBold.ttf
│           └── Inter-Black.ttf
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_radius.dart
│   │   │   └── app_strings.dart
│   │   ├── errors/
│   │   │   ├── app_error.dart
│   │   │   ├── error_handler.dart
│   │   │   └── error_messages.dart
│   │   ├── cache/
│   │   │   ├── cache_manager.dart
│   │   │   └── cache_keys.dart
│   │   ├── navigation/
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       └── extensions.dart
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_nav_bar.dart
│   │   │   ├── app_skeleton.dart
│   │   │   ├── app_error_toast.dart
│   │   │   ├── app_avatar.dart
│   │   │   ├── app_badge.dart
│   │   │   └── app_status_bar.dart
│   │   └── providers/
│   │       ├── auth_provider.dart
│   │       └── user_provider.dart
│   │
│   └── features/
│       │
│       ├── onboarding/
│       │   ├── screens/
│       │   │   ├── onboarding_screen.dart
│       │   │   ├── splash_one_screen.dart
│       │   │   └── splash_two_screen.dart
│       │   └── widgets/
│       │       └── onboarding_page.dart
│       │
│       ├── auth/
│       │   ├── screens/
│       │   │   ├── profile_type_picker_screen.dart
│       │   │   ├── login_screen.dart
│       │   │   ├── otp_phone_screen.dart
│       │   │   ├── otp_email_screen.dart
│       │   │   ├── user_signup_step_one_screen.dart
│       │   │   ├── user_signup_step_two_screen.dart
│       │   │   ├── user_signup_step_three_screen.dart
│       │   │   ├── mechanic_signup_step_one_screen.dart
│       │   │   ├── mechanic_signup_step_two_screen.dart
│       │   │   └── mechanic_signup_step_three_screen.dart
│       │   ├── providers/
│       │   │   └── auth_provider.dart
│       │   └── models/
│       │       ├── user_model.dart
│       │       └── mechanic_model.dart
│       │
│       ├── home/
│       │   ├── screens/
│       │   │   ├── user_home_screen.dart
│       │   │   ├── user_scan_screen.dart
│       │   │   ├── user_mechanics_screen.dart
│       │   │   ├── mechanic_home_screen.dart
│       │   │   ├── mechanic_scan_screen.dart
│       │   │   └── mechanic_users_screen.dart
│       │   ├── providers/
│       │   │   └── home_provider.dart
│       │   └── widgets/
│       │       ├── vehicle_card.dart
│       │       ├── mechanic_card_small.dart
│       │       └── quick_action_button.dart
│       │
│       ├── mechanics/
│       │   ├── screens/
│       │   │   ├── radius_selector_screen.dart
│       │   │   ├── searching_screen.dart
│       │   │   ├── mechanic_card_screen.dart
│       │   │   ├── mechanic_profile_screen.dart
│       │   │   └── in_app_call_screen.dart
│       │   ├── providers/
│       │   │   └── mechanics_provider.dart
│       │   └── models/
│       │       └── mechanic_search_model.dart
│       │
│       ├── jobs/
│       │   ├── screens/
│       │   │   ├── mechanic_incoming_call_screen.dart
│       │   │   ├── mechanic_active_call_screen.dart
│       │   │   ├── mechanic_post_call_screen.dart
│       │   │   ├── user_mechanic_accepted_screen.dart
│       │   │   ├── mechanic_en_route_screen.dart
│       │   │   ├── user_tracking_screen.dart
│       │   │   ├── user_mechanic_arrived_screen.dart
│       │   │   ├── user_job_in_progress_screen.dart
│       │   │   ├── mechanic_job_in_progress_screen.dart
│       │   │   ├── user_job_completed_screen.dart
│       │   │   ├── user_rate_mechanic_screen.dart
│       │   │   └── mechanic_job_completed_screen.dart
│       │   ├── providers/
│       │   │   └── job_provider.dart
│       │   └── models/
│       │       └── job_model.dart
│       │
│       ├── scan/
│       │   ├── screens/
│       │   │   └── scan_history_screen.dart
│       │   ├── providers/
│       │   │   └── scan_provider.dart
│       │   └── models/
│       │       └── scan_model.dart
│       │
│       ├── credits/
│       │   ├── screens/
│       │   │   ├── credits_overview_screen.dart
│       │   │   ├── buy_credits_screen.dart
│       │   │   └── credits_history_screen.dart
│       │   ├── providers/
│       │   │   └── credits_provider.dart
│       │   └── models/
│       │       └── credits_model.dart
│       │
│       ├── profile/
│       │   ├── screens/
│       │   │   ├── user_profile_screen.dart
│       │   │   ├── mechanic_profile_screen.dart
│       │   │   ├── mechanic_profile_edit_screen.dart
│       │   │   ├── user_drawer_screen.dart
│       │   │   ├── mechanic_drawer_screen.dart
│       │   │   ├── my_vehicles_screen.dart
│       │   │   ├── add_vehicle_screen.dart
│       │   │   ├── my_jobs_screen.dart
│       │   │   ├── service_history_screen.dart
│       │   │   └── job_history_screen.dart
│       │   ├── providers/
│       │   │   └── profile_provider.dart
│       │   └── models/
│       │       └── vehicle_model.dart
│       │
│       └── settings/
│           ├── screens/
│           │   ├── settings_screen.dart
│           │   ├── help_support_screen.dart
│           │   ├── notification_settings_screen.dart
│           │   ├── language_screen.dart
│           │   ├── appearance_screen.dart
│           │   ├── privacy_screen.dart
│           │   ├── change_password_screen.dart
│           │   ├── verify_password_change_screen.dart
│           │   └── delete_account_screen.dart
│           ├── providers/
│           │   └── settings_provider.dart
│           └── models/
│               └── settings_model.dart
│
└── test/
    ├── core/
    │   └── error_handler_test.dart
    └── features/
        ├── auth/
        │   └── auth_provider_test.dart
        └── credits/
            └── credits_provider_test.dart
```

---

## User Types

There are two types of users in StanDiag Auto:

- **Car Owner** — a person who needs a mechanic. They search, call, and confirm jobs.
- **Mechanic** — a professional who receives calls, accepts jobs, and completes them.

Both user types share the same app binary. The experience diverges after the profile type is selected during onboarding.

---

## Key Flows

1. **Onboarding** → Profile Type Picker → Signup → Login
2. **User:** Home → Search Mechanics → Call → Job Accepted → En Route → Arrived → In Progress → Completed → Rate
3. **Mechanic:** Home → Incoming Call → Accept → Navigate → Arrived → In Progress → Awaiting Confirmation → Completed → See Rating
4. **OBD Scan:** Connect Bluetooth Adapter → Scan → View Health Score → History
5. **Credits:** View Balance → Buy Bundle → Use on Contact/Scan

---

## Design Reference

All screen designs are in the `/design/` folder as HTML files. Each HTML file is the pixel-perfect reference for its corresponding Flutter screen. The agent must open and read the relevant HTML file before building any screen.

---

## Running Locally

```bash
git clone https://github.com/Daveralphy/standiag-auto.git
cd standiag-auto
flutter pub get
flutter run
```

> Requires Flutter 3.x or higher. Firebase configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) must be added before running. See CONTRIBUTING.md for setup instructions.

---

## Documentation Files

| File | Purpose |
|---|---|
| `README.md` | Project overview, repo structure, how to run |
| `CLAUDE.md` | Instructions for the AI agent building this app |
| `ARCHITECTURE.md` | How data flows, Firebase structure, provider ownership |
| `CONTRIBUTING.md` | How to add screens, naming rules, setup guide |
| `ERRORS.md` | Every error code, user message, and log format |
| `DESIGN.md` | Design system — colors, typography, spacing, components |

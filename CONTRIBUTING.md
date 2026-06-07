# CONTRIBUTING.md — StanDiag Auto

How to set up the project, add new screens, and follow the conventions of this codebase.

---

## Initial Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Daveralphy/standiag-auto.git
cd standiag-auto
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
- Create a new Firebase project at https://console.firebase.google.com
- Enable **Authentication** (Email/Password + Phone)
- Enable **Firestore Database**
- Enable **Firebase Storage**
- Enable **Firebase Crashlytics**
- Download `google-services.json` → place in `android/app/`
- Download `GoogleService-Info.plist` → place in `ios/Runner/`

> These files are in `.gitignore`. Never commit them.

### 4. Google Maps Setup
- Enable the Google Maps SDK for Android and iOS in Google Cloud Console
- Add your API key to `android/app/src/main/AndroidManifest.xml`
- Add your API key to `ios/Runner/AppDelegate.swift`

### 5. Agora Setup
- Create an Agora project at https://console.agora.io
- Copy your App ID
- Add it to your environment config (never hardcode in source)

### 6. Run the App
```bash
flutter run
```

---

## Adding a New Screen

### Step 1: Check README.md
Confirm the screen file name is listed in the repository file structure in `README.md`.
If it is not listed, the screen should not be created without updating `README.md` first.

### Step 2: Check the HTML Reference
Open the corresponding HTML file in `/design/`.
Read it completely. Identify every element, color, font, spacing, icon, and interaction.

### Step 3: Check for Reusable Widgets
Before building any widget, check `/lib/shared/widgets/` for existing components.
Use existing components before building new ones.

### Step 4: Create the File
Create the file in the correct feature folder with the exact name from `README.md`.

### Step 5: File Structure Template
Every screen file follows this structure:
```dart
/// One-line description of what this screen does and who sees it.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... other imports

class ScreenNameScreen extends ConsumerWidget {
  const ScreenNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers here
    // Return the screen layout
  }
}

// Private sub-widgets below, each with a brief doc comment
```

---

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Screen files | `feature_description_screen.dart` | `user_job_in_progress_screen.dart` |
| Widget files | `feature_widget_name.dart` | `mechanic_card_small.dart` |
| Provider files | `feature_provider.dart` | `job_provider.dart` |
| Model files | `model_name_model.dart` | `job_model.dart` |
| Classes | PascalCase | `UserJobInProgressScreen` |
| Variables | camelCase | `currentJobStatus` |
| Constants | camelCase in const class | `AppColors.primary` |
| Route names | kebab-case strings | `'/user/job-in-progress'` |

---

## Code Conventions

### Colors
Never use a hex string in a widget. Always use `AppColors`:
```dart
// Wrong
color: Color(0xFFE8281E)

// Right
color: AppColors.primary
```

### Text Styles
Never define text styles inline. Always use `AppTypography`:
```dart
// Wrong
style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)

// Right
style: AppTypography.heading3
```

### Spacing
Never use raw numbers for padding or gaps. Always use `AppSpacing`:
```dart
// Wrong
padding: EdgeInsets.all(18)
SizedBox(height: 12)

// Right
padding: EdgeInsets.all(AppSpacing.lg)
SizedBox(height: AppSpacing.md)
```

### Text Overflow
Every `Text` widget must handle overflow:
```dart
Text(
  someValue,
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
)
```

### Text in Rows
Every `Text` inside a `Row` must be wrapped:
```dart
Row(
  children: [
    Expanded(
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    // other widgets
  ],
)
```

### Error Handling
Never use try/catch and print the error:
```dart
// Wrong
try {
  await someOperation();
} catch (e) {
  print(e);
}

// Right
try {
  await someOperation();
} catch (e, stack) {
  ErrorHandler.handle(e, stack);
}
```

---

## Commit Message Format

```
type(feature): short description

Examples:
feat(auth): add user signup step one screen
fix(jobs): resolve job status not updating in real time
chore(deps): update firebase_core to 2.x
style(home): adjust mechanic card spacing to match design
```

Types: `feat`, `fix`, `chore`, `style`, `docs`, `refactor`, `test`

---

## Before Submitting Code

Checklist:
- [ ] Screen matches HTML reference exactly (colors, layout, typography, icons)
- [ ] No hardcoded colors, sizes, or strings
- [ ] All `Text` widgets have overflow handling
- [ ] No unbounded containers
- [ ] Skeleton loading implemented for data-dependent sections
- [ ] Error states handled and routed through `ErrorHandler`
- [ ] No unused imports
- [ ] No `print()` statements
- [ ] All image assets confirmed to exist in `/assets/images/`
- [ ] All stream subscriptions disposed on widget disposal

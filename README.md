# CLAUDE.md — AI Agent Instructions for StanDiag Auto

This file is the single source of truth for any AI agent working on this repository.
Read this file completely before touching any code, any file, or any folder.
Every rule here is non-negotiable.

---

## What This App Is

StanDiag Auto connects car owners with nearby mechanics in real time.
- Car owners search for mechanics, initiate contact via in-app voice call, confirm the job, and rate the mechanic after.
- Mechanics receive incoming calls, negotiate, accept or reject jobs, navigate to users, and complete jobs.
- Both sides use the same Flutter app. The experience splits after profile type selection.

There are two user types: **CarOwner** and **Mechanic**.

---

## The Prime Directive

> **The HTML files in `/design/` are the law. Every screen must match its HTML reference exactly — not approximately, not mostly — exactly. Colors, spacing, layout, typography, border radius, icons, animations. Exactly.**

If something in the HTML is unclear, ask. Do not guess. Do not improvise.

---

## Rule 1: Read Before You Write

Before editing any file:
1. Read the entire file you are about to change.
2. Find every other file that imports from or depends on that file.
3. Read those files too.
4. Understand the full data flow.
5. Only then make changes.

Never patch a single line in isolation. A change in one place can break three others.
If you are correcting an error, fix the root cause — not the symptom.

---

## Rule 2: Never Assume

If anything is unclear — a feature behavior, a UI detail, a data structure, a business rule — stop and ask.
Ask one specific question at a time.
Wait for the answer before proceeding.
Never fill in gaps with your own judgment.

Examples of things that require asking:
- "Should this screen be accessible to both user types or only car owners?"
- "When the mechanic declines a call, does the job disappear from their home screen?"
- "This image is referenced but not in /assets/images/ — should I wait for it?"

---

## Rule 3: Images Must Exist Before You Reference Them

If a screen requires an image asset:
1. Check if it exists in `/assets/images/`.
2. If it does not exist, stop.
3. Tell the developer: "Screen X requires image `filename.png` in `/assets/images/`. Please add it and confirm."
4. Wait for confirmation.
5. Then write the code that references it.

Never write `Image.asset('assets/images/something.png')` for a file that does not exist.

---

## Rule 4: Icons Come From The HTML

The HTML files use inline SVG for all icons. When converting to Flutter:
- Convert SVG paths to `CustomPainter` or use the `flutter_svg` package.
- Do not substitute a Material icon or any other icon library icon for an SVG that was specifically designed.
- The icon in the HTML is the icon in the app. No exceptions.
- If an SVG is too complex to convert cleanly, ask before substituting.

---

## Rule 5: One Screen Per File

Every screen is its own `.dart` file. No exceptions.
File names follow this exact pattern: `feature_name_screen.dart`
Examples: `user_home_screen.dart`, `mechanic_job_in_progress_screen.dart`

The full list of screen files and their exact names is in `README.md`.
Do not create a screen file with a name that is not in that list.
If a new screen is needed that is not in the list, ask before creating it.

---

## Rule 6: Zero Redundant Code

Before writing any function, widget, or class:
1. Check if it already exists in `/lib/shared/widgets/` or anywhere in the codebase.
2. If it exists, use it. Do not duplicate it.
3. If it almost fits but not quite, extend or parameterize the existing one — do not create a parallel version.

Signs of redundant code to actively avoid:
- Two widgets that do the same thing with slightly different names
- The same color value written as a hex string in multiple places (use `AppColors`)
- The same spacing value hardcoded in multiple places (use `AppSpacing`)
- Logic duplicated in a provider and in a screen widget

---

## Rule 7: No Raw Errors Shown to Users

Every error the user can encounter has exactly one approved message defined in `ERRORS.md`.
The flow is:
```
Firebase/Agora/Network throws exception
    → error_handler.dart catches it
    → maps to an AppError with a user-friendly message
    → app_error_toast.dart displays the message
    → Crashlytics logs the raw technical error
```

Never let a raw exception message reach the UI.
Never show stack traces, Firebase error codes, or technical descriptions to users.

---

## Rule 8: Errors Never Affect Layout

Error messages are displayed as floating toasts or overlays.
They appear above the UI. They never push, shift, resize, or reflow any UI element.
The layout must be identical whether an error is showing or not.

Implementation rule: use an `Overlay` or a `Stack` with a positioned error widget.
Never use a `Column` that conditionally inserts an error widget between other widgets.

---

## Rule 9: Every Text Has Overflow Handling

Every `Text` widget must have:
```dart
overflow: TextOverflow.ellipsis,
maxLines: N, // appropriate for context
```

Every `Text` widget inside a `Row` must be wrapped in `Expanded` or `Flexible`.
No exceptions. Flutter's pixel overflow errors are not acceptable in production.

---

## Rule 10: Every Container Is Bounded

No widget should have unbounded height or width.
If a `ListView` or `Column` is inside a widget that does not have a fixed height, wrap it in `Expanded` or give it a `SizedBox` with explicit dimensions.
Test every screen with long text, missing images, and empty states.

---

## Rule 11: Caching Rules

Data is fetched once and cached. It is only re-fetched when:
1. A Firestore real-time listener fires a change.
2. The user explicitly pulls to refresh.
3. The cached data is older than its defined TTL (time-to-live).

Cache keys are defined in `/lib/core/cache/cache_keys.dart`.
TTL values are defined there too.
Hive is used for persistent local cache (survives app restarts).
Riverpod providers hold in-memory cache (survives navigation, cleared on logout).

Never call Firestore on every screen navigation. Fetch once, cache, use the cache.

---

## Rule 12: Skeleton Loading

Every screen that loads remote data shows a shimmer skeleton while loading.
Static elements (nav bar, header, buttons) render immediately.
Only data-dependent sections show skeletons.
The skeleton must match the shape and layout of the real content it replaces.
Use the shared `AppSkeleton` widget in `/lib/shared/widgets/app_skeleton.dart`.

---

## Rule 13: Real-Time Listeners Only Where Needed

Firestore real-time listeners (`snapshots()`) are expensive.
Only use them for:
- Incoming job requests / calls (mechanic side)
- Job status changes (both sides, during active job)
- Mechanic location during navigation

Use one-time fetches (`get()`) for everything else.
Dispose all stream subscriptions when the screen is disposed.

---

## Rule 14: Comment Rules

Comments explain **why**, not **what**. The code shows what it does. The comment explains why it does it.

Good comment:
```dart
// Cache the mechanic list here because users navigate back to this screen
// frequently during a session and we don't want repeated Firestore reads.
```

Bad comment:
```dart
// Set the list of mechanics
final mechanics = await _fetchMechanics();
```

Every file starts with a one-line doc comment:
```dart
/// Displays the list of nearby mechanics on a full-screen map with incoming call handling.
```

Every public class and public method has a doc comment.
No comments on obvious code. No `// increment i` or `// return the value`.

---

## Rule 15: Design System Constants

Never hardcode a color, font size, spacing value, or border radius.
Always use the constants defined in `/lib/core/constants/`:

```dart
// Colors
AppColors.background      // #0A0A0A
AppColors.surface         // #141414
AppColors.primary         // #E8281E
AppColors.primaryDark     // #C41F16
AppColors.textPrimary     // #FFFFFF
AppColors.textSecondary   // rgba(255,255,255,0.4)
AppColors.textMuted       // rgba(255,255,255,0.25)
AppColors.success         // #4CAF50
AppColors.warning         // #FFC107
AppColors.border          // rgba(255,255,255,0.07)

// Typography — all Inter font
AppTypography.heading1    // 26px, weight 900
AppTypography.heading2    // 20px, weight 800
AppTypography.heading3    // 16px, weight 800
AppTypography.body        // 13px, weight 500
AppTypography.caption     // 10px, weight 500
AppTypography.label       // 9px, weight 600

// Spacing
AppSpacing.xs   // 4
AppSpacing.sm   // 8
AppSpacing.md   // 12
AppSpacing.lg   // 18
AppSpacing.xl   // 24
AppSpacing.xxl  // 32

// Border Radius
AppRadius.sm    // 10
AppRadius.md    // 14
AppRadius.lg    // 20
AppRadius.xl    // 28
AppRadius.full  // 99
```

---

## Note: system_ui_style.dart

`/lib/shared/widgets/system_ui_style.dart` controls the **appearance** of the phone's system status bar.
It does NOT draw a status bar widget. The phone's OS handles the actual status bar.
This file uses `SystemChrome.setSystemUIOverlayStyle()` to:
- Keep status bar icons white (light) on all dark screens
- Make the status bar background transparent so app content shows behind it
- Hide the status bar on splash screens if needed

Never build a widget that tries to replicate or recreate the system status bar.
The phone already has one. We only style it.

---

## Rule 16: Navigation

Navigation uses GoRouter. All route names are defined in `/lib/core/navigation/route_names.dart`.
Never use hardcoded route strings in screen files.
Never call `Navigator.push` directly — always use the router.

---

## Rule 17: State Management

Riverpod is the only state management solution in this app.
No `setState` except inside widgets that have genuinely local-only UI state (e.g. a password visibility toggle that has no effect outside that widget).
All business logic lives in providers, not in screen widgets.
Screen widgets are for layout and user interaction only.

---

## Rule 18: Firebase Security

Never expose Firebase configuration values in code.
They belong in `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) only.
Both files are in `.gitignore` and never committed to the repository.

---

## Rule 19: Before Building Any Screen

Before writing a single line of code for any screen:
1. Open the corresponding HTML file in `/design/`.
2. Identify every visual element: colors, fonts, sizes, spacing, icons, images.
3. Identify every interactive element: buttons, inputs, toggles, navigation.
4. Identify what data the screen needs and where it comes from.
5. Write a brief summary of what you are about to build.
6. Wait for developer confirmation.
7. Then build it.

---

## Rule 20: Confirm Before Proceeding Past Any Uncertainty

If at any point you are not 100% certain about something, stop and ask.
One question at a time.
Never batch multiple questions into one message — ask the most important one first.
Never proceed based on an assumption.

The cost of asking is one message.
The cost of assuming wrong is broken code across multiple files.

---

## What The Agent Must Never Do

- Never use `setState` for business logic
- Never hardcode colors, sizes, or strings
- Never duplicate code that already exists
- Never create a file whose name is not in `README.md`
- Never show raw error messages to users
- Never reference an image that does not exist in `/assets/`
- Never substitute a custom SVG icon with a Material icon
- Never write code without reading its dependencies first
- Never assume a business rule — ask
- Never proceed past an unclear requirement — ask
- Never use `print()` for logging — use Crashlytics or the defined logger
- Never commit Firebase config files
- Never skip skeleton loading on a data-dependent screen
- Never use an unbounded widget
- Never put a `Text` in a `Row` without `Expanded` or `Flexible`
- Never build a widget that recreates the phone system status bar

---

## Agent Workflow Summary

```
1. Read CLAUDE.md (this file) — done at the start of every session
2. Read ARCHITECTURE.md — understand data flow
3. Read DESIGN.md — understand visual system
4. For each screen to build:
   a. Open HTML reference file in /design/
   b. Identify all elements and data requirements
   c. State what you are about to build
   d. Wait for confirmation
   e. Check /assets/ for required images
   f. Check /lib/shared/ for reusable widgets
   g. Build the screen
   h. Cross-check against HTML reference
   i. Confirm it matches before moving on
5. For any error correction:
   a. Read the full file with the error
   b. Read all files that depend on it
   c. Identify root cause
   d. Fix root cause
   e. Verify no other file is broken
```
# Legacy inventory for the fresh rebuild

This is a working audit, not an approval to preserve the legacy implementation. Update it as code references and real Firebase data are verified.

## Decision rules

- **Reuse** only code that is independently verified to work and fits the agreed product.
- **Rewrite** user-facing screens, old theme/state/navigation systems, and feature logic that is unfinished or tightly coupled to the legacy app.
- **Retain as a data contract** only persisted fields/collections or integration contracts needed for the new product or existing customer data.
- **Remove** abandoned screens, duplicate implementations, dead providers, unused assets, tests for removed behavior, and dependencies no longer required after references are removed.

## Data and integration contracts to verify before deletion

| Contract | Evidence in legacy source | Decision |
| --- | --- | --- |
| Firebase app initialization | `lib/main.dart` initializes Firebase with generated platform options | Retain initialization; generated options remain environment-specific |
| `users` collection | Auth/profile providers query user documents | Audit fields and auth/profile lifecycle before retaining a minimal user contract |
| `mechanics` collection | Mechanic provider and FCM token service access mechanic documents | Audit provider identity, service area, visibility and notification fields |
| `vehicles` collection | Profile provider creates and deletes vehicle documents | Audit vehicle ownership and existing customer data |
| `jobs` collection | Job provider writes repair/job documents | Audit current job lifecycle, status values, quotes and relationships |
| `scans` collection | Scan provider creates scan IDs and stores scan data | Do not assume OBD scanning remains in scope; verify product decision and persisted data before removal |
| `pending_purchases` collection | Firestore rules reference pending purchase records | Audit against Cloud Functions/payment code before changing rules or schema |
| Cloud Functions | Existing functions include purchase/credit-related operations | Audit deployed callers and stored transaction records before removing backend functions |
| Local Firebase configuration | `firebase_options.dart`, platform service files and `.env` may be generated/ignored | Preserve setup expectations; never commit secrets |

## App shell replacement started

- `lib/main.dart`: startup now initializes Firebase and launches the new root.
- `lib/app.dart`: replaced the old root that coupled routing, settings-provider theme state, offline banner, and a manual global theme rebuild workaround.
- `lib/app/theme/app_theme.dart`: new central Material 3 light/dark theme.
- `lib/app/foundation/entry_screen.dart`: temporary role-entry shell. This is not the final Home screen and does not claim authentication is implemented.

## Known legacy areas still requiring cleanup

- `lib/core/theme/` and `lib/core/constants/app_colors.dart`, `app_radius.dart`, `app_typography.dart`: legacy theme/token system still exists and has references from old screens. Remove after the new foundation replaces or deletes those screens; do not leave two theme systems in the finished app.
- `lib/core/navigation/`: old GoRouter and route names still exist, but are no longer connected to the new root. Replace with the agreed clean navigation/auth flow, then remove the old router and route constants.
- `lib/features/` and `lib/shared/`: legacy feature implementations remain. Each must be classified against the agreed screen families and verified data contracts. Existence in source is not proof of functionality.
- `test/`: tests tied to deleted legacy behavior must be removed or rewritten to cover the new product. Keep meaningful tests for retained data contracts and new flows.
- `pubspec.yaml` and platform generated plugin registrants: prune dependencies only after their replacement/removal references are gone, then regenerate lockfiles and platform plugin registrations with Flutter tooling.

## Validation blockers

- Flutter format, analyze, tests and builds have not been run in this remote editing environment.
- Generated Firebase options and local platform configuration are not all tracked; a developer/CI environment must supply them.
- Do not describe the repository as fully cleaned until obsolete files and dependencies are actually removed and a clean build is verified.

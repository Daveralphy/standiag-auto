# Contributing

Standiag Auto is being rebuilt from a clean application foundation. Keep contributions focused on the agreed product rather than extending legacy features by default.

## Before changing code

1. Confirm the change belongs to an approved customer or mechanic workflow.
2. Check existing Firestore usage, security rules, and Cloud Functions before changing persisted fields or backend contracts.
3. Search for references before removing a file, provider, route, dependency, asset, or test.
4. Prefer a small, coherent change over compatibility layers for abandoned code.

## Architecture

- Keep the app entry point and global Material theme in the new `lib/app/` foundation.
- Use Material 3 and shared theme tokens. Do not introduce a second theme system or mutable global color state.
- Keep UI, domain logic, and Firebase access separated as features are introduced.
- Add dependencies only when a real, implemented use case requires them.
- Keep credentials and generated Firebase configuration out of source control.

## UI and accessibility

- Build light and dark modes together.
- Use responsive layouts, semantic controls, and readable contrast.
- Avoid speculative screens and placeholder features unless they are explicitly part of the current task.
- Shared patterns should use reusable components instead of page-specific copies.

## Data safety

- Treat the current Firestore database as potentially containing real user data.
- Verify collections, field names, security rules, deployed functions, and migration needs before modifying a data contract.
- Never delete production data or weaken security rules as part of routine UI work.
- Do not assume an old feature is required just because its schema exists.

## Verification

Run the relevant commands when the local environment is configured:

```sh
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

Report which checks were run and their actual outcomes. If Firebase configuration or another environment dependency blocks verification, state that clearly.

## Git workflow

- Create a focused feature branch.
- Never push directly to `main`.
- Use clear commit messages.
- Open a pull request with a concise summary, verification results, and any data-contract risks.
- Do not merge while required checks or review are outstanding.

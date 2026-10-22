# AI coding instructions

Standiag Auto is undergoing a fresh rebuild. Treat the existing app implementation as legacy reference material, not as architecture to preserve.

## Rules

- Read `README.md` and `CONTRIBUTING.md` first.
- Work only on the current feature branch; never push directly to `main`.
- Implement only agreed customer/mechanic workflows. Do not revive old screens or features without an explicit product decision.
- Prefer removing dead code over building compatibility layers, but search references before deleting files or dependencies.
- Preserve Firebase initialization and verify Firestore collections, security rules, deployed Cloud Functions, and existing data dependencies before changing contracts.
- Never commit secrets, generated credentials, or production configuration.
- Keep a single Material 3 theme system. Support light and dark mode from the start; widgets should use `Theme.of(context)`.
- Add packages only for implemented, necessary capabilities.
- Update or remove tests alongside replaced behavior; add tests for new logic.
- Run formatter, analyzer, tests, and a debug build when possible. Never claim checks passed unless they were run.
- Summarize changed files, removed legacy code, validation results, and unresolved risks at the end.

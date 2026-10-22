# Standiag Auto redesign foundation

## Product direction

Standiag Auto is an on-demand car-repair marketplace. Customers describe a repair need; the platform recommends an eligible mechanic or workshop; the customer confirms; the platform coordinates the repair through completion.

The interface must not imply live vehicle telemetry or automatic diagnosis unless a supported device or real data source provides it. Avoid asking customers to repeatedly enter information the app already knows.

## Approved screen families

### Customer

1. Home — primary repair request, problem/service entry points, mechanic/workshop discovery, active repair summary when one exists.
2. Explore — search and discover eligible mechanics, workshops, and services.
3. My Repairs — requests, bookings, active jobs, history, quotations and status.
4. Profile — account, vehicles, preferences, support and legal settings.

Customer bottom navigation: Home, Explore, My Repairs, Profile.

### Mechanic / workshop provider

1. Home — online/availability status, service area, request summary, incoming requests, active jobs and useful shortcuts.
2. Jobs — new requests, active work, upcoming bookings and completed jobs.
3. Earnings — completed work, transaction history, payout status and payout settings, backed by verified transaction records.
4. Profile — business details, service types, service area, availability, pricing, verification, preferences and support.

Mechanic bottom navigation: Home, Jobs, Earnings, Profile.

## Communication and marketplace integrity

Do not add a general-purpose customer/mechanic inbox to the main navigation. Communication should be scoped to a valid repair request or confirmed booking, subject to the existing product's supported capabilities. Quotations, approvals, cancellations, payment and job-state transitions must be explicit structured actions, not inferred from chat messages. Do not expose personal contact details by default.

## Visual design system

- Brand: deep burgundy `#7A0E14`, action red `#DC2626`, restrained gold `#F59E0B`.
- Use adaptive surfaces: light surfaces in light theme and high-contrast dark surfaces in dark theme.
- Keep a single token source in `lib/core/constants/app_colors.dart`; do not scatter raw brand hex values through screens.
- Keep typography, spacing, radii, buttons, status badges, cards, and navigation reusable.
- Match layouts across corresponding customer and mechanic screens. Use realistic responsive spacing; do not copy phone-frame dimensions into actual Flutter widgets.
- Status colours must communicate state consistently and remain distinguishable in both themes.
- Screen designs are approved individually before implementation. Do not implement speculative screen content without agreement.

## Fresh-start implementation and cleanup rules

Treat the current application code as a legacy reference, not as the architecture we must preserve. A feature that exists in the repository is not automatically a required feature, and a provider/model is not automatically worth keeping just because it is referenced by unfinished code.

- Start with a clean application structure around the approved product and main screens. Reuse existing code only when it is understood, working, and genuinely accelerates the new implementation.
- Retain schemas and fields only when they are required by an agreed product capability, existing persisted customer data that must remain compatible, or a verified external integration. Record the reason each retained schema is needed.
- Identify unfinished, duplicated, dead, and broken features; remove them from the new architecture rather than building more screens on top of them.
- Before deleting schemas or data contracts, check actual Firestore collections, persisted Hive data, Cloud Functions, payment integrations, and migration requirements. If a schema is not required, retire it deliberately instead of keeping it merely for backward compatibility.
- Replace legacy navigation and providers where they obstruct a clean design. Do not preserve a flawed architecture just to avoid rewriting it.
- Keep presentation, business rules, and data access separated in the new implementation. Use shared design tokens and components for consistent light/dark mode.
- Do not invent live data or claim a feature works unless it is implemented and verified.
- Work on a feature branch and review via pull request. Do not push redesign changes directly to `main`.

## Implementation sequence

1. Confirm the approved product scope and main screen families.
2. Inventory existing files into **reuse**, **rewrite**, **retain as data contract**, and **remove**. Flag any schema whose real-world use cannot yet be confirmed.
3. Establish the new app shell, routing, theme system, typography, spacing, reusable controls, and light/dark surfaces.
4. Rebuild customer Home, Explore, My Repairs, and Profile; then mechanic Home, Jobs, Earnings, and Profile.
5. Reintroduce only the required domain models and backend integrations as each approved flow needs them.
6. Remove the legacy code that is no longer referenced by the new implementation, then check dependencies and assets for unused items.
7. Run formatting, static analysis, tests, and builds. Clearly report checks that could not be executed.

## Current known constraints

- Firebase configuration files and `.env` are intentionally untracked and must be supplied locally/through CI secrets.
- The app uses Flutter, Riverpod, GoRouter, Firebase, and Hive. Do not replace these without a concrete technical reason.
- Existing OBD, calling, credits, authentication, service-request, and provider workflows require dependency review before removal.
- A design mockup is not proof that a corresponding feature or data source already exists.

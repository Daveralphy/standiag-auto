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

## Architecture and cleanup rules

- Preserve schemas/models that are read or written by live features, Firestore, Cloud Functions, local cache, or persisted user data.
- Before deleting a model, field, route, provider, dependency, asset, or Cloud Function, search for every reference and check serialized data, backend contracts, and deep links.
- Remove code only after confirming it is unused and not part of a persisted or external contract. Avoid broad destructive cleanup based on filenames alone.
- Keep business logic and data access out of presentation widgets. Reuse existing providers/services when their behavior is sound.
- Do not invent live data. Empty, loading, error, unavailable, and populated states must all be designed.
- Keep user and mechanic workflows role-specific, but share the same design tokens and reusable UI primitives.
- Keep changes on a feature branch and review via pull request. Do not push redesign changes directly to `main`.

## Implementation sequence

1. Establish brand tokens and verify light/dark theme behavior.
2. Audit existing routes, screen implementations, models, providers, services, Firestore rules, Cloud Functions and tests.
3. Map existing features to the approved screen families; identify keep/refactor/retire candidates with reference checks.
4. Build shared UI primitives and role-specific navigation without breaking existing routes or schema contracts.
5. Implement one approved screen at a time, beginning with customer Home, then Explore, My Repairs, Profile, followed by mechanic Home, Jobs, Earnings and Profile.
6. Run formatting, static analysis, tests, and build checks; document any environment-dependent checks that cannot run.

## Current known constraints

- Firebase configuration files and `.env` are intentionally untracked and must be supplied locally/through CI secrets.
- The app uses Flutter, Riverpod, GoRouter, Firebase, and Hive. Do not replace these without a concrete technical reason.
- Existing OBD, calling, credits, authentication, service-request, and provider workflows require dependency review before removal.
- A design mockup is not proof that a corresponding feature or data source already exists.

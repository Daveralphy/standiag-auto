# Standiag Auto — Complete Screen Blueprint

Working branch: `refactor/redesign-foundation`

**Purpose:** define the complete screen inventory, visual system, navigation, states, and data/action contracts before building the remaining screens and wiring the app end-to-end.

**Release guardrails:** do not merge to `main`; do not deploy while this redesign is in progress. Keep server-managed approval, identity, payments, credits, and job decisions behind their existing trusted backend contracts. Do not label demo or unconnected data as live.

## 1. Design direction

### Product character
A confident, practical automotive-care product: clear, trustworthy, calm, and efficient. Avoid generic dashboard clutter, invented live metrics, excessive gradients, or large decorative cards that push important actions below the fold.

### Shared visual system
- Use the existing Material 3 theme and Inter typography.
- Keep the current brand seed colours; use semantic success, warning, and error colours consistently.
- Use a consistent spacing rhythm (8 / 12 / 16 / 24 / 32), rounded cards, readable field labels, clear section headings, and predictable action placement.
- Primary action: one visually dominant action per screen or form. Destructive actions require confirmation.
- Use responsive max-width constraints on large displays and scrollable forms on short/narrow displays.
- Use the existing logo assets where appropriate. Do not add image dependencies before confirming each screen's final dimensions.
- Empty states should explain why the list is empty and provide a relevant next step when one exists.
- Every async screen must define loading, empty, failure/retry, permission-denied, and signed-out behaviour where applicable.

## 2. Screen inventory and visual specification

### A. Entry, identity and onboarding

| ID | Screen | Main content and actions | States / notes |
|---|---|---|---|
| A01 | Welcome / Sign in | Brand mark, concise value proposition, email, password, show/hide password, sign in, create account, forgot password | Invalid input, wrong credentials, disabled submit, progress, auth failure |
| A02 | Create account | Email, password, confirm password if supported by current auth contract, terms acknowledgement if policy is adopted, create account | Validation, duplicate email, weak password, network failure |
| A03 | Verify email | Clear instruction, masked/current email, resend, refresh/check verification, sign out/change account | Cooldown/feedback, expired session, verified transition |
| A04 | Password reset | Email, send reset link, return to sign in | Neutral confirmation that avoids account enumeration; failure/retry |
| A05 | Account loading/router | Loading state while resolving user and mechanic records | One cached load per identity; retry in place on failure |
| A06 | Choose account journey | Customer setup or mechanic/workshop application; application status lookup | Clear difference between customer access and mechanic approval |
| A07 | Customer profile setup | First name, last name, phone; save | Field validation, submit progress, backend errors |
| A08 | Mechanic application | Independent/workshop choice, applicant name, phone, service area, experience, expertise, workshop name when relevant | Validation, submit state, pending confirmation; never self-approve |
| A09 | Application status | Pending, approved, rejected, more-information-required; review note where provided | Refresh/check again; next action only if supported by backend |

### B. Customer experience

| ID | Screen | Main content and actions | States / notes |
|---|---|---|---|
| C01 | Customer home | Greeting, primary “Find a mechanic” action, garage summary, active repair summary, useful shortcuts | Use real account data only; no fabricated counts |
| C02 | Mechanic discovery | Search by expertise, workshop and service area; mechanic cards; request action | Loading, no mechanics, no results, permission/network error |
| C03 | Mechanic profile/details | Workshop/independent identity, service area, expertise, experience, rating only if verified, request CTA | Do not expose private applicant data |
| C04 | Request repair | Explicit vehicle selector, issue description, selected mechanic or broadcast option only if backend supports it, review/submit | Validation, submit lock, success and failure |
| C05 | My vehicles | Vehicle cards with make/model/year and relevant details; add, view, edit, remove | Empty garage, loading, error/retry |
| C06 | Add vehicle | Make, model, year, type, colour, plate, fuel type | Validation and save feedback |
| C07 | Vehicle details | Vehicle facts and linked repairs where the data model supports it; edit/remove | Missing vehicle, delete confirmation |
| C08 | Edit vehicle | Pre-filled editable vehicle form | Ownership/security errors, save state |
| C09 | My repairs | Customer's requests ordered newest first; readable status; open detail | Empty, loading, failure/retry |
| C10 | Repair request details | Issue, vehicle, mechanic/quote response, timestamps, status timeline | Only show fields confirmed in data contract; no invented timeline |
| C11 | Quote comparison/details | Quote amount, description, mechanic, validity/status; accept/decline only if backend rules support it | No quotes, accepted/declined/expired, clear confirmation |
| C12 | Active repair/job detail | Agreed work, current status, updates and permitted customer actions | Status-driven UI; cancellation only if contract permits |
| C13 | Repair history/completed work | Completed/cancelled requests with date and final state | Empty and retry states |
| C14 | Customer profile | Profile details, account type, shortcuts to edit/settings/support | No fake avatar or unsupported stats |
| C15 | Edit customer profile | Name, phone, ordinary editable fields supported by rules | Validate; never allow role/credits/admin fields |
| C16 | Customer settings/security | Email, password-reset flow, session/sign out, legal and account controls | State which controls are available; deletion must be an explicit supported flow |

### C. Mechanic / workshop experience

| ID | Screen | Main content and actions | States / notes |
|---|---|---|---|
| M01 | Mechanic home | Work status, incoming request summary and next relevant action | Metrics only from real records |
| M02 | Incoming requests | Requests available to the approved mechanic; issue, distance only if real, vehicle summary | Approval gate, no requests, loading/error |
| M03 | Request detail | Customer issue, vehicle, service area, request timestamp, quote/respond action | Respect privacy and read permissions |
| M04 | Create/edit quote | Work description, amount/currency, estimate/terms only if contract supports them | Validation, submit progress, no duplicate submissions |
| M05 | My jobs | Jobs assigned to mechanic grouped by actionable status | Loading, empty, failure; avoid conflating requests with accepted jobs |
| M06 | Job details | Customer request, agreed quote/work, current lifecycle, permitted status actions | Only valid transitions; server/backend authorization required |
| M07 | Job progress/update | Mark work started/in progress/completed only when backend contract permits | Confirmation and server errors |
| M08 | Completed jobs | Completed jobs with actual records and dates | Honest empty state |
| M09 | Earnings | Actual completed-job totals and payment status only when payment records exist | If no verified source exists, show “not available yet,” not sample money |
| M10 | Payout details/history | Payout account/history only when a verified payment contract exists | Do not collect/store sensitive payout data without defined secure backend |
| M11 | Mechanic profile | Public profile fields and workshop identity | Separate public fields from private application details |
| M12 | Edit mechanic/workshop profile | Fields permitted by server rules; service area, expertise, workshop details if supported | If the backend contract does not permit edits, design disabled/awaiting-review state rather than bypassing it |
| M13 | Application status/review | Pending/approved/rejected/more information; review note | Application status is not equivalent to public mechanic approval |

### D. Shared destinations

| ID | Screen | Main content and actions | States / notes |
|---|---|---|---|
| S01 | Notifications | User-owned notifications, read/unread, open destination, mark read | Empty/loading/error; backend-created notifications only |
| S02 | Account settings | Current email and role, password reset, sign out, legal links | Only actions that really work |
| S03 | Help & support | FAQs and configured contact options | No invented support email/phone |
| S04 | Privacy policy | Plain-language policy screen sourced from approved policy text | Must be reviewed/approved before release |
| S05 | Terms of service | Approved terms text and version/date | Must be reviewed/approved before release |
| S06 | Account deletion | Explain impact, re-authenticate if required, explicit confirmation, invoke secure backend deletion | Do not delete only Auth while leaving user data; no UI-only fake deletion |
| S07 | Network/permission error states | Reusable retry and guidance patterns | Reuse across async screens |
| S08 | About / app version | Product name/version and useful legal links | Use actual package version |

### E. Conditional / future screens

These screens should be built only after the current app contracts confirm the feature is intended and supportable:
- Diagnostic scan creation/results and scan history.
- Credits balance, purchase history and Paystack checkout.
- Admin review queue and approval tools.
- Location/map tracking.
- Chat or real-time messaging.
- Ratings/reviews.
- Appointment scheduling.

Existing models or legacy collections alone do not prove these screens are production-ready. Confirm callable functions, security rules, status contracts and intended user journeys before wiring them into primary navigation.

## 3. Navigation map

- Signed out → A01.
- Create account → A02 → A03 → A05.
- Existing sign-in → A05; unverified user → A03; verified user without customer profile → A06.
- A06 → A07 for customer setup, or A08 → A09 for mechanic application/status.
- A05 → C01 for customer; A05 → M01 only when the trusted mechanic record meets approval and visibility requirements.
- Customer bottom navigation: Home (C01), Explore (C02), My repairs (C09), Profile (C14).
- Customer secondary routes: C02 → C03 → C04; C01/C14 → C05 → C06/C07/C08; C09 → C10 → C11/C12/C13 when supported by records.
- Mechanic bottom navigation: Home (M01), Jobs (M05), Earnings (M09), Profile (M11).
- Mechanic secondary routes: M05 → M03 → M04/M06 → M07/M08; M11 → M12; application route → M13.
- Shared notification entry from the app bar → S01. Profile/settings routes → S02/S03/S04/S05/S06 as contracts become available.
- Back navigation must return to the previous logical context and preserve form/list state where reasonable.

## 4. Shared components to build/reuse

- App scaffold and responsive content width.
- Section heading and helper copy.
- Primary/secondary/destructive action styles.
- Form field wrapper with label, hint, validation and keyboard configuration.
- Loading panel/skeleton, empty state, retry/error panel, permission-denied panel.
- Status chip with a canonical status-to-label/colour map.
- Vehicle card and mechanic card.
- Request/job summary card.
- Confirmation dialog for destructive or irreversible actions.
- SnackBar/inline feedback for mutations.
- Date/currency formatters only after data format and currency contracts are confirmed.

## 5. Data and connection rules

1. Inventory current Firestore rules, models, callable functions, status values and legacy screens before implementing each journey.
2. Reuse current collections and callable functions; do not invent a parallel schema just to make a UI work.
3. Treat Firestore field names and security rules as contracts. Validate writes against them.
4. Server-owned roles, mechanic approval, payments, credits, admin decisions and account deletion must remain server-controlled.
5. Never show demo counts, fake ratings, sample earnings, fake notifications or fabricated job status as live data.
6. Do not assume the customer can cancel a request, accept any quote, or edit any mechanic field until backend rules and transition logic support it.
7. A button must navigate, execute a validated action, or be disabled with an explanation.
8. Use retryable, user-friendly errors; do not silently swallow failures.
9. Dispose controllers, avoid duplicate requests on rebuild, and prevent duplicate submits.
10. Add tests for screen rendering, validation, navigation, loading/error/empty states and permitted status transitions.

## 6. Implementation order after design sign-off

### Phase 1 — Foundation and design system
- Shared components, theme/accessibility/responsive rules.
- Route map and screen inventory.
- Standard loading, empty, error and status components.

### Phase 2 — Complete all screen shells
- Finish customer and mechanic screens with realistic layouts and empty/loading states.
- Finish shared/legal/account screen shells.
- Add consistent navigation between every screen.
- Keep unsupported actions clearly unavailable rather than faking backend behaviour.

### Phase 3 — Wire verified data/actions
- Customer vehicles and repair requests.
- Mechanic request/quote/job lifecycle.
- Profile/settings and notifications.
- Security/legal/account deletion only after backend contracts are verified.

### Phase 4 — Quality pass
- Widget tests per screen and navigation route.
- Flutter analyze/test after each coherent batch.
- Manual Firebase-configured end-to-end journeys.
- Narrow phone, larger phone and tablet checks.
- Final button/route audit.

## 7. Implementation progress after the baseline

- [x] Added a customer repair-request details screen with saved request facts, quote responses, loading/error/empty states, and a clear explanation that quote acceptance is not yet wired to a trusted transaction.
- [x] Connected customer repair cards to their detail screen.
- [x] Added mechanic assigned-job list and read-only job details with a saved-status timeline.
- [x] Added an earnings view based on actual completed-job records; monetary totals remain unavailable until a verified payment/payout contract exists.
- [x] Added a direct incoming-request list and details for requests targeted to the signed-in mechanic; broadcast request eligibility and response actions remain unimplemented.
- [x] Added customer profile editing through the existing server callable.
- [x] Removed placeholder mechanic metrics that implied live zero values.
- [ ] Add widget tests for the new detail/list screens and validate all changes locally.

## 8. Shared screens implementation progress

- [x] Notifications screen reads the signed-in user’s notification records, distinguishes unread items, supports marking records read, and opens linked repair/job details where a supported reference exists.
- [x] Cloud Functions now persist in-app notification records alongside existing mechanic push notifications for direct service requests, nearby requests and direct calls. This source change is not deployed.
- [x] Account settings includes a password reset email action and navigation to privacy, terms and about screens.
- [x] Added clearly marked preliminary privacy/terms copy so draft legal text is not misrepresented as approved policy.
- [x] Added widget coverage for the legal information screens and updated support page expectations for Firebase-unconfigured mode.
- [ ] Validate Dart tests and TypeScript build locally before proceeding; notification persistence requires a future approved Functions deployment to be live.

## 9. Current implementation checkpoint

At commit `66bcb947f937d1bd3ecb0044ca7bce99fba5e00f`, the user confirmed:
- `flutter analyze`: no issues.
- `flutter test`: all 23 tests passed.

This is the baseline. New changes must be validated again locally. This blueprint is a design and implementation plan, not a claim that all listed screens are already implemented or connected.

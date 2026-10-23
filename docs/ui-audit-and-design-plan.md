# Standiag Auto UI audit and redesign plan

Working branch: `refactor/redesign-foundation`

Do not merge this work into `main` or deploy until the local Flutter checks and end-to-end journeys have been reviewed.

## Product journeys

### 1. Access and onboarding
- [x] Sign in / create account screen exists
- [x] Email verification instructions, resend, and recheck flow exist
- [x] Password reset request exists
- [x] Verified-account router and missing-profile onboarding exist
- [ ] Add dedicated widget tests for sign-in, sign-up, verification, and router states
- [ ] Review visual hierarchy, keyboard handling, accessibility, and small-screen behaviour
- [ ] Test auth flows against Firebase Auth in a configured local environment

### 2. Customer experience
- [x] Workspace shell and bottom navigation exist
- [x] Vehicle list and create form use Firestore
- [x] Mechanic discovery reads visible mechanic profiles
- [x] Repair requests can be started from mechanic discovery
- [x] Repair request list reads the customer's requests
- [ ] Add complete vehicle details, edit, and delete flows
- [ ] Add repair-request detail and status history screens
- [ ] Ensure vehicle selection is explicit when a customer has multiple vehicles
- [ ] Verify cancellation and repeat-request rules with the backend
- [ ] Replace any demo metrics or copy that implies data is live when it is not

### 3. Mechanic experience
- [x] Mechanic application and review status flow exists
- [x] Mechanic workspace shell exists
- [ ] Build a real incoming-requests list and request details
- [ ] Implement accept/decline and job lifecycle actions using verified backend rules
- [ ] Build completed jobs and earnings from real job/payment records
- [ ] Add mechanic profile editing and workshop details
- [ ] Confirm all job and payout states are permission-safe

### 4. Shared destinations
- [x] Notifications destination exists with an honest empty state
- [x] Account settings destination displays current account details
- [x] Help and support destination contains expandable FAQs
- [ ] Connect notifications to a defined notification data contract
- [ ] Add real account editing and password/security actions
- [ ] Configure official support contact details before adding a contact action
- [ ] Add privacy, terms, and account deletion flows where required

### 5. Quality and resilience
- [ ] Every visible action has a destination or an explicit disabled state with a reason
- [ ] Loading, empty, permission-denied, offline, and retry states are consistent
- [ ] Responsive checks cover narrow phones, larger phones, and tablets
- [ ] Add widget tests for each major screen and navigation edge
- [ ] Run `flutter analyze` and `flutter test` locally after each implementation batch
- [ ] Perform configured Firebase end-to-end tests before considering the product ready

## Visual asset policy

Use local assets only where they improve the interface. Until final images are generated, use robust icon/colour placeholders so missing assets never break a page.

Potential assets, only if a screen benefits from them:
- `assets/images/onboarding_vehicle.png`: wide editorial illustration of a modern everyday vehicle, clean light background, no words or logos.
- `assets/images/mechanic_workshop.png`: professional mechanic in a tidy workshop, realistic, welcoming, no visible brand logos.
- `assets/images/empty_garage.png`: simple minimal garage/vehicle illustration for a true empty state.

Do not generate or add these assets yet. First confirm the final screens and dimensions that need them, then add generated files and declare them in `pubspec.yaml`.

## Definition of done

A screen is not considered complete merely because it renders. Its actions, backend permissions, loading/error/empty states, responsive layout, and relevant tests must also be checked. An unfinished capability must be labelled honestly and must not be represented as a working action.

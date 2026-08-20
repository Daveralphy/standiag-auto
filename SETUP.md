# Running StanDiag Auto locally

This app needs several external services configured before it will run
without errors: Firebase (auth + Firestore), Cloudinary (photo storage),
Agora (in-app calls), and EmailJS (password-change OTP emails). None of
these are optional — skipping one produces a specific, predictable error,
listed in [Common errors](#common-errors) below.

## 1. Prerequisites

- Flutter 3.32+ (`flutter --version` to check)
- A Firebase project (console.firebase.google.com) — Authentication and
  Firestore enabled. **Do not enable Firebase Storage** — it requires the
  paid Blaze plan just to turn on; this app uses Cloudinary instead (free).
- A Cloudinary account (cloudinary.com) — free, no card required
- An Agora account (console.agora.io) — free tier, needed only for in-app
  voice calls
- An EmailJS account (dashboard.emailjs.com) — free tier, needed only for
  password-change OTP emails
- The Firebase CLI (`npm install -g firebase-tools`) if you'll deploy
  Firestore rules or Cloud Functions

## 2. Install dependencies

```
flutter pub get
```

## 3. Set up `.env`

```
cp .env.example .env
```

Then fill in every value in `.env` — `.env.example` documents exactly where
each one comes from. Nothing in `.env` is committed to git; every developer
and every deployment keeps their own copy. In short, you need:

- **Firebase** (per platform — Web/Android/iOS/macOS/Windows): from Firebase
  console → Project settings → General → "Your apps"
- **Cloudinary**: `CLOUDINARY_CLOUD_NAME` from your Dashboard, plus two
  presets — `CLOUDINARY_PROFILE_UPLOAD_PRESET` and
  `CLOUDINARY_VEHICLE_UPLOAD_PRESET` — from Settings → Upload → Upload
  presets → Add upload preset. Each needs **Signing Mode: "Unsigned"** (a
  signed preset makes every upload fail with a 401) **and Folder set to a
  fixed value** (`profile_photos` / `vehicle_photos`) — the folder lock is
  the actual security boundary here, not optional. See `.env.example` for
  the full reasoning and two more free hardening steps.
- **Agora**: `AGORA_APP_ID` from Project Management → your project → App ID.
  Authentication Mechanism must be "App ID" (no certificate) — this app has
  no token server
- **EmailJS**: `EMAILJS_SERVICE_ID` / `EMAILJS_TEMPLATE_ID` /
  `EMAILJS_PUBLIC_KEY` — see `lib/core/config/emailjs_config.dart` for the
  full template setup

## 4. Android: `google-services.json`

This file is gitignored and not included — Gradle needs your own copy.

1. Firebase console → Project settings → your Android app (package
   `com.standiagauto.standiag_auto`)
2. Download `google-services.json`
3. Place it at `android/app/google-services.json`

iOS needs no equivalent file — this app configures Firebase on iOS purely
through `.env` → `lib/firebase_options.dart`, no `GoogleService-Info.plist`.

## 5. Deploy Firestore rules

```
firebase deploy --only firestore:rules --project <your-project-id>
```

Without this, every Firestore read/write fails with a
`permission-denied` error the moment the console's test-mode rules expire
(they always do, 30 days after project creation).

## 6. Deploy Cloud Functions (optional, but needed for automatic photo cleanup)

The app works fully without this step — profile/vehicle photo uploads don't
need it at all. What it adds: automatically deleting a user's *old* photo
the instant they upload a new one (and deleting a vehicle's photo when the
vehicle itself is removed), instead of it sitting orphaned in Cloudinary
until someone manually deletes it from the dashboard.

This needs your Firebase project on the **Blaze (pay-as-you-go) plan** —
Cloud Functions that make outbound network calls (this one calls
Cloudinary's API) aren't available on the free Spark plan. Functions'
own free quota (2M invocations/month) covers this app's usage with $0
charged in practice, but Blaze does require a payment method on file as a
fallback.

1. Upgrade to Blaze: Firebase console → your project → the plan badge in
   the bottom-left → Upgrade.
2. Get your Cloudinary **API Key** and **API Secret** from the Cloudinary
   dashboard → Settings → API Keys (this is the one Cloudinary credential
   that must *never* go in the app's own `.env` — see `.env.example`'s
   note on it).
3. Store them as Cloud Functions secrets (encrypted, never committed):
   ```
   firebase functions:secrets:set CLOUDINARY_API_KEY --project <your-project-id>
   firebase functions:secrets:set CLOUDINARY_API_SECRET --project <your-project-id>
   ```
4. Create `functions/.env` (gitignored, not the same file as the app's
   root `.env`) with your non-secret cloud name:
   ```
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   ```
5. Deploy:
   ```
   cd functions && npm install && npm run build
   firebase deploy --only functions --project <your-project-id>
   ```

This also deploys `notifyNearbyMechanics` (push notifications to nearby
mechanics), already written but inert until this step runs.
(`sendSignupOtp`/`verifySignupOtp` are dead code, not deployed by this
step or any other — signup email verification uses the same client-side
EmailJS flow as password changes instead, needing no Cloud Function.)

## 7. Social sign-in (optional)

The Google/Apple buttons on the login screen work without this section —
they show a clear "not set up yet" toast instead of failing confusingly
until you complete it.

**Google** — free, no card required:
1. Firebase console → Authentication → Sign-in method → enable Google.
2. Project settings → General → "Your apps" → copy the Web app's client ID
   into `GOOGLE_WEB_CLIENT_ID` (`.env`) and the iOS app's into
   `GOOGLE_IOS_CLIENT_ID`.
3. Android needs a SHA-1 fingerprint registered too: `cd android &&
   ./gradlew signingReport`, then add it in Firebase console → your Android
   app → Add fingerprint.
4. iOS needs its reversed client ID added as a URL scheme — the only
   social sign-in credential that can't come from `.env`, since URL
   schemes are static. `ios/Runner/Info.plist` already has a placeholder
   with exact replacement instructions.

**Apple** — needs an active Apple Developer Program membership
($99/year) to configure at all; nothing here works without one, the same
way Blaze blocks Cloud Functions.
1. Native iOS/macOS sign-in needs no `.env` values — just add the "Sign
   in with Apple" capability in Xcode's Signing & Capabilities tab (this
   uses `ios/Runner/Runner.entitlements`, already prepared).
2. Android/web go through a web flow instead: create a Services ID under
   Apple Developer → Certificates, Identifiers & Profiles → Identifiers,
   enable Sign in with Apple on it, and set its Return URL to a page you
   host that redirects to `standiagauto://oauthredirect` (the scheme
   `android/app/src/main/AndroidManifest.xml` already listens for) — see
   the `sign_in_with_apple` package's own docs for a ready-made redirect
   page template. The Services ID goes in `APPLE_SIGNIN_SERVICE_ID`, the
   hosted page's URL in `APPLE_SIGNIN_REDIRECT_URI`.

## 8. Credits & payments (optional)

The app works fully without this step. Contacting a mechanic and running an
OBD-II scan already charge real credits the moment you deploy Cloud
Functions (step 6) — `chargeForAction`/`refundCredits` handle those
server-side once deployed, and fall back to a client-enforced charge if
they're not. What this step adds specifically is **real purchases**: buying
more credits with actual money via Paystack. Until it's done, tapping a
bundle on the Buy Credits screen shows a clear "payments aren't set up yet"
message instead of charging a card it can't actually credit for.

This needs the same **Blaze plan** as step 6 (`initializePaystackTransaction`
and `paystackWebhook` both make outbound network calls), and a Paystack
account.

1. Sign up at [paystack.com](https://paystack.com) (a free Business account
   is enough to start in Test mode; switch to Live once you're ready to
   accept real payments).
2. Dashboard → Settings → API Keys & Webhooks → copy the **Secret Key**
   (Test or Live, matching whichever mode you're accepting payments in).
3. Store it as a Cloud Functions secret — never the app's own `.env`, the
   same reasoning as Cloudinary's API secret in step 6:
   ```
   firebase functions:secrets:set PAYSTACK_SECRET_KEY --project <your-project-id>
   ```
4. Deploy (or redeploy) functions:
   ```
   cd functions && npm install && npm run build
   firebase deploy --only functions --project <your-project-id>
   ```
5. Copy the deployed `paystackWebhook` URL from the deploy output (or
   Firebase console → Functions), then in the Paystack dashboard → Settings
   → API Keys & Webhooks, paste it into the **Webhook URL** field. This is
   what lets Paystack actually notify your app when a payment succeeds —
   without it, a buyer's money would go through but their credits would
   never arrive, since `paystackWebhook` is the only thing that ever grants
   them.
6. Once Blaze is live and this step is done, deploy the tightened Firestore
   rules noted in `firestore.rules`' "NOT YET TIGHTENED" comment near
   `credits_history` — locking the credits ledger and balance to
   server-only writes. Skip this until then; deploying it early would break
   the client-enforced fallback charge the pilot currently depends on.

## 9. Run

```
flutter run
```

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| `StateError: Missing "FIREBASE_..." in .env` at startup | `.env` doesn't exist or is missing a key | Copy `.env.example` to `.env` and fill in every Firebase key |
| Gradle build fails looking for `google-services.json` | File not placed | Step 4 above |
| Firestore calls fail with `permission-denied` | Rules not deployed, or test-mode rules expired | Step 5 above |
| "Could not upload the image" on profile/vehicle photo | Cloudinary env vars empty, or a preset isn't set to "Unsigned" | Recheck `CLOUDINARY_CLOUD_NAME` / `CLOUDINARY_PROFILE_UPLOAD_PRESET` / `CLOUDINARY_VEHICLE_UPLOAD_PRESET` in `.env`, and each preset's Signing Mode in the Cloudinary dashboard |
| "That image is too large" | File is over 5MB | Pick a smaller image — this is a client-side check in `CloudinaryService`, not a Cloudinary error |
| Old photos never disappear from Cloudinary | Cloud Functions (step 6) not deployed | Expected if you skipped that step — the app still works, cleanup is just manual via the Cloudinary dashboard until then |
| Camera closes the app instantly on iOS | Missing `NSCameraUsageDescription` | Already fixed in `ios/Runner/Info.plist` — only resurfaces if that file is reverted |
| In-app calls fail immediately | `AGORA_APP_ID` empty or Authentication Mechanism isn't "App ID" | Recheck Agora project settings |
| Password-change OTP email never arrives | EmailJS vars empty or template misconfigured | See `lib/core/config/emailjs_config.dart` |
| Signup email verification code never arrives | Same EmailJS vars empty/misconfigured — signup verification reuses that flow | See `lib/core/config/emailjs_config.dart` |
| "Google/Apple sign-in isn't set up yet" toast | Relevant `.env` values empty | Step 7 above |
| Google sign-in works on Android but not iOS | Missing/wrong URL scheme in `Info.plist` | Step 7 above — the one credential that needs a manual (not `.env`) edit |
| Apple sign-in fails no matter what's in `.env` | No Apple Developer Program membership | Expected — nothing works here without one, same as Blaze blocking Cloud Functions |
| "Payments aren't set up yet" on Buy Credits | `PAYSTACK_SECRET_KEY` secret not set, or functions (step 6) not deployed | Step 8 above |
| Paystack payment succeeds but credits never appear | Webhook URL not registered in the Paystack dashboard | Step 8.5 above — `paystackWebhook` is the only thing that ever grants purchased credits |
| Contacting a mechanic / scanning charges credits even with no Cloud Functions deployed | Expected — `CreditsGateway` falls back to a real, client-enforced charge when `chargeForAction` isn't deployed yet | Deploy step 6 for the server-verified version; the pilot still works correctly either way |

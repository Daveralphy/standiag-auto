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

This also deploys `sendSignupOtp` / `verifySignupOtp` (signup email
verification) and `notifyNearbyMechanics` (push notifications to nearby
mechanics) — both already written, just inert until this step runs.

## 7. Run

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

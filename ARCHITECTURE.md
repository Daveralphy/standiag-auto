# ARCHITECTURE.md — StanDiag Auto

How the app is structured, how data flows, and who owns what.

---

## Overview

StanDiag Auto is a Flutter app with a feature-based architecture.
State is managed with Riverpod.
Data is stored in Firebase Firestore with local caching via Hive.
Real-time features use Firestore streams.
Voice calls use Agora SDK over mobile data.

---

## User Types

```
AppUser
├── type: CarOwner
│   └── has: vehicles, service history, scan history, credits
└── type: Mechanic
    └── has: expertise, workshop, job history, rating, credits
```

Both types authenticate with Firebase Auth.
After login, the app reads the user's type from Firestore and routes accordingly.

---

## Firebase Firestore Structure

```
firestore/
│
├── users/
│   └── {userId}/
│       ├── uid: string
│       ├── type: 'car_owner' | 'mechanic'
│       ├── firstName: string
│       ├── lastName: string
│       ├── username: string
│       ├── email: string
│       ├── phone: string
│       ├── address: string
│       ├── profilePhoto: string (Storage URL)
│       ├── credits: number
│       ├── createdAt: timestamp
│       └── isFirstTime: boolean
│
├── mechanics/
│   └── {userId}/
│       ├── uid: string
│       ├── workshopAddress: string
│       ├── expertise: string[]
│       ├── yearsOfExperience: number
│       ├── rating: number
│       ├── totalJobs: number
│       ├── credits: number
│       ├── isVisible: boolean
│       └── location: geopoint (updated in real time during active session)
│
├── vehicles/
│   └── {vehicleId}/
│       ├── ownerId: string
│       ├── make: string
│       ├── model: string
│       ├── year: string
│       ├── type: string
│       ├── colour: string
│       ├── plateNumber: string
│       └── fuelType: string
│
├── jobs/
│   └── {jobId}/
│       ├── carOwnerId: string
│       ├── mechanicId: string
│       ├── vehicleId: string
│       ├── issue: string
│       ├── status: 'pending' | 'accepted' | 'en_route' | 'arrived' | 'in_progress' | 'completed' | 'rejected'
│       ├── carOwnerLocation: geopoint
│       ├── mechanicLocation: geopoint
│       ├── createdAt: timestamp
│       ├── acceptedAt: timestamp
│       ├── completedAt: timestamp
│       ├── rating: number (null until rated)
│       └── ratingComment: string (null until rated)
│
├── scans/
│   └── {scanId}/
│       ├── ownerId: string
│       ├── vehicleId: string
│       ├── healthScore: number
│       ├── rawData: map
│       └── createdAt: timestamp
│
├── credits_history/
│   └── {transactionId}/
│       ├── userId: string
│       ├── type: 'debit' | 'credit'
│       ├── amount: number
│       ├── reason: string
│       ├── relatedJobId: string (optional)
│       └── createdAt: timestamp
│
└── calls/
    └── {callId}/
        ├── carOwnerId: string
        ├── mechanicId: string
        ├── agoraChannelId: string
        ├── status: 'ringing' | 'active' | 'ended' | 'declined'
        ├── startedAt: timestamp
        └── endedAt: timestamp
```

---

## Data Flow

### App Start
```
main.dart
  → app.dart initializes Firebase and Hive
  → GoRouter checks auth state (Firebase Auth)
  → if authenticated: route to home (user or mechanic)
  → if not: route to onboarding/login
```

### Authentication
```
LoginScreen / SignupScreen
  → AuthProvider (Riverpod)
  → Firebase Auth (email/password or phone OTP)
  → on success: write user doc to Firestore users/{uid}
  → Hive caches user data locally
  → GoRouter navigates to home
```

### Home Screen Data
```
UserHomeScreen / MechanicHomeScreen
  → HomeProvider (Riverpod)
  → first load: fetch from Firestore, cache in Hive
  → subsequent loads: read from Hive (no Firestore call)
  → pull to refresh: refetch from Firestore, update Hive
```

### Mechanics Search (User side)
```
UserMechanicsScreen
  → MechanicsProvider
  → Firestore query: mechanics collection where isVisible == true, ordered by distance
  → results cached in Riverpod memory for session duration
  → tapping a mechanic: deduct credits → initiate Agora call
```

### Job Flow
```
Call initiated
  → Firestore: create jobs/{jobId} with status 'pending'
  → Agora: create channel, send call notification to mechanic
  → Mechanic receives call: Firestore stream on jobs/{jobId}
  → Mechanic accepts: update status to 'accepted'
  → Both sides: real-time Firestore stream on jobs/{jobId} drives UI state
  → Status progression:
      pending → accepted → en_route → arrived → in_progress → completed
```

### Credits
```
User contacts mechanic: deduct 5 credits from user
User runs OBD scan: deduct 10 credits from user
Mechanic accepts confirmed job: deduct credits from mechanic
All deductions: Firestore transaction (atomic write to user doc + credits_history doc)
Buy credits: payment processed → Firestore transaction adds credits
```

---

## Provider Ownership

Each feature owns its data through its provider.
No screen directly calls Firebase.
All Firebase interactions go through providers.

```
AuthProvider         → Firebase Auth, user session
HomeProvider         → home screen data, vehicle info
MechanicsProvider    → mechanic search results, call initiation
JobProvider          → active job state, real-time job updates
ScanProvider         → OBD scan results, scan history
CreditsProvider      → balance, transactions, purchase flow
ProfileProvider      → user/mechanic profile data, edit state
SettingsProvider     → app preferences, language, appearance
```

---

## Caching Strategy

| Data | Cache Type | TTL | Invalidation |
|---|---|---|---|
| User profile | Hive (persistent) | Until logout | On profile update |
| Mechanics list | Riverpod (memory) | Session | Pull to refresh |
| Job state | Firestore stream | Real-time | Auto (stream) |
| Scan history | Hive (persistent) | 24 hours | On new scan |
| Credits balance | Hive (persistent) | Until next transaction | On any debit/credit |
| Settings | Hive (persistent) | Until changed | On settings update |
| Transaction history | Hive (persistent) | 1 hour | On new transaction |

---

## Real-Time Listeners

Only these use Firestore `snapshots()` streams:

1. **Incoming calls** — mechanic listens to `calls/{callId}` while on users screen
2. **Job status** — both sides listen to `jobs/{jobId}` during active job
3. **Mechanic location** — user listens to `mechanics/{mechanicId}.location` while tracking

All other data uses one-time `get()` fetches.
All stream subscriptions are disposed in the provider's `dispose()` method.

---

## Navigation Structure

```
GoRouter
├── /splash-one                    → SplashOneScreen
├── /splash-two                    → SplashTwoScreen
├── /onboarding                    → OnboardingScreen
├── /profile-type-picker           → ProfileTypePickerScreen
├── /login                         → LoginScreen
├── /otp-phone                     → OtpPhoneScreen
├── /otp-email                     → OtpEmailScreen
├── /signup/user/step-one          → UserSignupStepOneScreen
├── /signup/user/step-two          → UserSignupStepTwoScreen
├── /signup/user/step-three        → UserSignupStepThreeScreen
├── /signup/mechanic/step-one      → MechanicSignupStepOneScreen
├── /signup/mechanic/step-two      → MechanicSignupStepTwoScreen
├── /signup/mechanic/step-three    → MechanicSignupStepThreeScreen
│
├── /user/
│   ├── home                       → UserHomeScreen
│   ├── scan                       → UserScanScreen
│   ├── mechanics                  → UserMechanicsScreen
│   ├── mechanic-card              → MechanicCardScreen
│   ├── mechanic-profile           → MechanicProfileScreen
│   ├── in-app-call                → InAppCallScreen
│   ├── mechanic-accepted          → UserMechanicAcceptedScreen
│   ├── tracking                   → UserTrackingScreen
│   ├── mechanic-arrived           → UserMechanicArrivedScreen
│   ├── job-in-progress            → UserJobInProgressScreen
│   ├── job-completed              → UserJobCompletedScreen
│   ├── rate-mechanic              → UserRateMechanicScreen
│   ├── profile                    → UserProfileScreen
│   ├── vehicles                   → MyVehiclesScreen
│   ├── add-vehicle                → AddVehicleScreen
│   ├── service-history            → ServiceHistoryScreen
│   ├── scan-history               → ScanHistoryScreen
│   ├── credits                    → CreditsOverviewScreen
│   ├── buy-credits                → BuyCreditsScreen
│   ├── credits-history            → CreditsHistoryScreen
│   └── settings                   → SettingsScreen (+ sub-routes)
│
└── /mechanic/
    ├── home                       → MechanicHomeScreen
    ├── scan                       → MechanicScanScreen
    ├── users                      → MechanicUsersScreen
    ├── incoming-call              → MechanicIncomingCallScreen
    ├── active-call                → MechanicActiveCallScreen
    ├── post-call                  → MechanicPostCallScreen
    ├── en-route                   → MechanicEnRouteScreen
    ├── job-in-progress            → MechanicJobInProgressScreen
    ├── job-completed              → MechanicJobCompletedScreen
    ├── profile                    → MechanicProfileScreen
    ├── profile-edit               → MechanicProfileEditScreen
    ├── job-history                → JobHistoryScreen
    ├── my-jobs                    → MyJobsScreen
    ├── credits                    → CreditsOverviewScreen
    ├── buy-credits                → BuyCreditsScreen
    ├── credits-history            → CreditsHistoryScreen
    └── settings                   → SettingsScreen (+ sub-routes)
```

---

## Error Flow

```
Any exception anywhere in the app
    ↓
error_handler.dart.handle(exception)
    ↓
Maps to AppError (code + user message)
    ↓
Provider exposes error state
    ↓
Screen listens to error state
    ↓
app_error_toast.dart shows floating toast
    ↓
Crashlytics.recordError(exception, stack)
    ↓
Toast auto-dismisses after 3 seconds
```

The UI never changes. The toast floats above everything.

---

## Agora Call Flow

```
User taps "Call" on mechanic card
    → CreditsProvider deducts 5 credits (atomic Firestore transaction)
    → JobProvider creates call document in Firestore
    → Agora: generate token server-side (Firebase Cloud Function)
    → User joins Agora channel
    → Push notification sent to mechanic
    → Mechanic receives incoming call screen
    → Mechanic accepts → joins same Agora channel
    → Both on active call
    → Either party hangs up → Agora channel closed
    → Call document updated with endedAt
    → Post-call screen shown to mechanic
```

---

## OBD Flow

```
MechanicScanScreen / UserScanScreen
    → ScanProvider
    → Flutter Bluetooth Plugin scans for BLE devices
    → User connects to OBD adapter
    → Send OBD-II query commands
    → Parse response → calculate health score (0–10)
    → Deduct 10 credits (atomic Firestore transaction)
    → Save scan result to Firestore scans/{scanId}
    → Update scan history in Hive cache
    → Display result on screen
```

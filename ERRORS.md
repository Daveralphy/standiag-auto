# ERRORS.md — StanDiag Auto Error Reference

Every error that can occur in the app, what the user sees, and what gets logged.

---

## Error Handling Philosophy

1. Users never see raw error messages, stack traces, or technical codes.
2. Every error maps to exactly one user-friendly message from this file.
3. The full technical error is logged to Firebase Crashlytics for developers.
4. Error messages appear as floating toasts — they never affect the UI layout.
5. Toasts auto-dismiss after 3 seconds.

---

## Error Categories

### Authentication Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `auth/wrong-password` | Invalid credentials. Please try again. | Firebase: wrong-password |
| `auth/user-not-found` | Invalid credentials. Please try again. | Firebase: user-not-found |
| `auth/invalid-email` | Please enter a valid email address. | Firebase: invalid-email |
| `auth/email-already-in-use` | An account with this email already exists. | Firebase: email-already-in-use |
| `auth/weak-password` | Password must be at least 6 characters. | Firebase: weak-password |
| `auth/too-many-requests` | Too many attempts. Please try again in a few minutes. | Firebase: too-many-requests |
| `auth/network-request-failed` | Check your internet connection and try again. | Firebase: network-request-failed |
| `auth/invalid-verification-code` | Incorrect code. Please check and try again. | Firebase: invalid-verification-code |
| `auth/code-expired` | This code has expired. Please request a new one. | Firebase: code-expired |
| `auth/session-expired` | Your session has expired. Please log in again. | Firebase: session-expired |
| `auth/unknown` | Something went wrong. Please try again. | Raw exception logged |

---

### Network Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `network/no-connection` | No internet connection. Please check your network. | SocketException or similar |
| `network/timeout` | Request timed out. Please try again. | TimeoutException |
| `network/server-error` | Service unavailable. Please contact support. | HTTP 5xx or Firestore unavailable |

---

### Firestore / Data Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `firestore/permission-denied` | You do not have permission to do that. | Firestore: permission-denied |
| `firestore/not-found` | The requested data could not be found. | Firestore: not-found |
| `firestore/unavailable` | Service unavailable. Please contact support. | Firestore: unavailable |
| `firestore/unknown` | Something went wrong. Please try again. | Raw Firestore exception |

---

### Credits Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `credits/insufficient` | You do not have enough credits for this action. | Balance at time of error logged |
| `credits/transaction-failed` | Credit transaction failed. Please try again. | Firestore transaction exception |
| `credits/purchase-failed` | Purchase could not be completed. Please try again. | Payment provider exception |

---

### Job Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `job/creation-failed` | Could not create the job. Please try again. | Firestore write exception |
| `job/update-failed` | Could not update the job status. Please try again. | Firestore update exception |
| `job/not-found` | This job no longer exists. | Firestore not-found on job doc |
| `job/already-accepted` | This job has already been accepted by another mechanic. | Status conflict |

---

### Call Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `call/failed-to-join` | Could not connect the call. Please try again. | Agora join exception |
| `call/connection-lost` | Call connection was lost. | Agora disconnect event |
| `call/token-failed` | Could not initiate call. Please try again. | Cloud Function token generation failed |
| `call/microphone-denied` | Microphone access is required for calls. Please enable it in settings. | Permission denied |

---

### OBD / Bluetooth Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `obd/bluetooth-disabled` | Please enable Bluetooth to connect the OBD adapter. | Bluetooth state: off |
| `obd/device-not-found` | OBD adapter not found. Make sure it is plugged in and powered on. | No device found in scan |
| `obd/connection-failed` | Could not connect to the OBD adapter. Please try again. | Bluetooth connection exception |
| `obd/scan-failed` | Scan could not be completed. Please try again. | OBD command error |
| `obd/permission-denied` | Bluetooth permission is required. Please enable it in settings. | Permission denied |

---

### Profile / Upload Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `upload/failed` | Could not upload the image. Please try again. | Firebase Storage exception |
| `upload/too-large` | Image is too large. Please choose a smaller image. | File size exceeded |
| `profile/update-failed` | Could not save your changes. Please try again. | Firestore update exception |

---

### General Errors

| Error Code | User Message | Log Details |
|---|---|---|
| `general/unknown` | Something went wrong. Please try again. | Full exception and stack trace |
| `general/maintenance` | Service unavailable. Please contact support. | Maintenance flag in Firestore |

---

## How Errors Are Displayed

Errors appear as a floating dark toast at the bottom of the screen (above the nav bar if present).

```
┌─────────────────────────────────────┐
│  ⚠  Invalid credentials. Please    │
│     try again.                      │
└─────────────────────────────────────┘
```

- Background: `#1A1A1A`
- Border: `rgba(255,255,255,0.08)`
- Icon: warning triangle in `#E8281E`
- Text: white, 12px
- Border radius: 14px
- Auto-dismiss: 3 seconds
- Animation: slide up from bottom, fade out on dismiss
- Position: fixed, 16px from bottom of safe area
- Never overlaps navigation bar — appears above it

---

## What Gets Logged to Crashlytics

For every error:
```
Crashlytics.recordError(
  exception,       // the raw exception object
  stackTrace,      // the full stack trace
  reason: 'error_code',   // the internal error code from this file
  information: [
    'userId: ${userId}',
    'userType: ${userType}',
    'screen: ${currentScreen}',
    'timestamp: ${DateTime.now().toIso8601String()}',
  ],
)
```

The user ID, user type, and current screen are always included so developers can reproduce issues.

---

## Contact Support

When a user receives "Service unavailable. Please contact support." they should email:
**support@standiagauto.com**

This address must be kept up to date in `AppStrings.supportEmail`.

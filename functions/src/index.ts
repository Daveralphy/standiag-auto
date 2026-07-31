// Cloud Functions for StanDiag Auto.
//
// sendSignupOtp / verifySignupOtp — the signup email-OTP flow. Two
// callables: generate + email a 6-digit code, and check it. The code
// itself is never stored in plain text — only its SHA-256 hash — so a
// Firestore read can't leak it. Email delivery goes through the Firebase
// "Trigger Email" extension: writing a document to the `mail` collection
// is enough to send it, once the extension is installed and configured
// with an SMTP provider.
//
// notifyNearbyMechanics — fires when a car owner broadcasts an open
// service request (serviceRequests/{requestId}). Finds every visible
// mechanic with a registered device token within the request's radius and
// sends them a push notification so they can open the app and send a
// quote.
//
// NOT YET DEPLOYED. To deploy:
//   cd functions && npm install && npm run build
//   firebase deploy --only functions
// Requires the Firebase project to be on the Blaze (pay-as-you-go) plan —
// Cloud Functions that make outbound network calls (sending FCM messages
// is one) aren't available on the free Spark plan.

import * as crypto from "crypto";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, GeoPoint, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

initializeApp();
const db = getFirestore();

// ─── Signup email OTP ───────────────────────────────────────────────────

const OTP_TTL_MINUTES = 10;
const MAX_ATTEMPTS = 5;
const OTP_COLLECTION = "email_otps";
const MAIL_COLLECTION = "mail";

function hashCode(code: string): string {
  return crypto.createHash("sha256").update(code).digest("hex");
}

function generateSixDigitCode(): string {
  return crypto.randomInt(0, 1_000_000).toString().padStart(6, "0");
}

/**
 * Generates a 6-digit verification code for the signed-in user's account
 * email, stores its hash with a 10-minute expiry, and queues the email via
 * the Trigger Email extension. Call this immediately after creating the
 * Firebase Auth account during signup, and again for "Resend".
 */
export const sendSignupOtp = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "You must be signed in to request a code.");
  }

  const email = request.auth?.token.email as string | undefined;
  if (!email) {
    throw new HttpsError(
      "failed-precondition",
      "No email address is associated with this account."
    );
  }

  const code = generateSixDigitCode();
  const expiresAt = Timestamp.fromMillis(Date.now() + OTP_TTL_MINUTES * 60_000);

  await db.collection(OTP_COLLECTION).doc(uid).set({
    email,
    codeHash: hashCode(code),
    expiresAt,
    attempts: 0,
    createdAt: Timestamp.now(),
  });

  await db.collection(MAIL_COLLECTION).add({
    to: [email],
    message: {
      subject: "Your StanDiag Auto verification code",
      text: `Your verification code is ${code}. It expires in ${OTP_TTL_MINUTES} minutes.`,
      html:
        `<p>Your verification code is <strong>${code}</strong>.</p>` +
        `<p>It expires in ${OTP_TTL_MINUTES} minutes.</p>`,
    },
  });

  return { success: true };
});

/**
 * Verifies a 6-digit code against the hash stored by sendSignupOtp.
 * On success, marks users/{uid}.emailVerified = true and deletes the
 * OTP document. Locks out further attempts after 5 wrong guesses,
 * matching the app's `AppErrorType.tooManyRequests` messaging.
 */
export const verifySignupOtp = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "You must be signed in to verify a code.");
  }

  const code = request.data?.code;
  if (typeof code !== "string" || !/^\d{6}$/.test(code)) {
    throw new HttpsError(
      "invalid-argument",
      "invalid-verification-code: Enter the 6-digit code."
    );
  }

  const ref = db.collection(OTP_COLLECTION).doc(uid);
  const snap = await ref.get();

  if (!snap.exists) {
    throw new HttpsError(
      "not-found",
      "invalid-verification-code: No code was requested for this account."
    );
  }

  const data = snap.data() as {
    codeHash: string;
    expiresAt: Timestamp;
    attempts: number;
  };

  if (Date.now() > data.expiresAt.toMillis()) {
    await ref.delete();
    throw new HttpsError("deadline-exceeded", "code-expired: This code has expired.");
  }

  if ((data.attempts ?? 0) >= MAX_ATTEMPTS) {
    await ref.delete();
    throw new HttpsError(
      "resource-exhausted",
      "too-many-requests: Too many incorrect attempts. Please request a new code."
    );
  }

  if (data.codeHash !== hashCode(code)) {
    await ref.update({ attempts: (data.attempts ?? 0) + 1 });
    throw new HttpsError(
      "invalid-argument",
      "invalid-verification-code: The code you entered is incorrect."
    );
  }

  await ref.delete();
  await db.collection("users").doc(uid).set({ emailVerified: true }, { merge: true });

  return { success: true };
});

// ─── Nearby-mechanic push notifications ─────────────────────────────────

const EARTH_RADIUS_KM = 6371;

function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

/** Haversine distance in kilometres between two Firestore GeoPoints. */
function distanceKm(a: GeoPoint, b: GeoPoint): number {
  const dLat = toRad(b.latitude - a.latitude);
  const dLon = toRad(b.longitude - a.longitude);
  const lat1 = toRad(a.latitude);
  const lat2 = toRad(b.latitude);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return EARTH_RADIUS_KM * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
}

interface ServiceRequestData {
  status: string;
  issue?: string;
  radiusKm?: number;
  carOwnerLocation?: GeoPoint;
}

interface MechanicData {
  isVisible?: boolean;
  fcmToken?: string;
  location?: GeoPoint;
}

/**
 * Fires when a car owner broadcasts a new open service request. Alerts
 * every visible mechanic with a registered device token whose stored
 * location falls within the request's radius.
 */
export const notifyNearbyMechanics = onDocumentCreated(
  "serviceRequests/{requestId}",
  async (event) => {
    const request = event.data?.data() as ServiceRequestData | undefined;
    if (!request || request.status !== "open") return;

    const carOwnerLocation = request.carOwnerLocation;
    const radiusKm = request.radiusKm ?? 15;

    const mechanicsSnap = await db
      .collection("mechanics")
      .where("isVisible", "==", true)
      .get();

    const tokens: string[] = [];
    for (const doc of mechanicsSnap.docs) {
      const mechanic = doc.data() as MechanicData;
      if (!mechanic.fcmToken) continue;
      if (carOwnerLocation && mechanic.location) {
        const km = distanceKm(carOwnerLocation, mechanic.location);
        if (km > radiusKm) continue;
      }
      tokens.push(mechanic.fcmToken);
    }

    if (tokens.length === 0) return;

    const message = {
      notification: {
        title: "New service request nearby",
        body: request.issue
          ? `A car owner needs help: ${request.issue}`
          : "A car owner near you needs a mechanic.",
      },
      data: {
        requestId: event.params.requestId,
        type: "service_request",
      },
    };

    // FCM's multicast send caps at 500 tokens per call.
    const chunkSize = 500;
    const messaging = getMessaging();
    for (let i = 0; i < tokens.length; i += chunkSize) {
      const chunk = tokens.slice(i, i + chunkSize);
      await messaging.sendEachForMulticast({ ...message, tokens: chunk });
    }
  }
);

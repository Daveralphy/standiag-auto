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
// deleteCloudinaryImage — called by the app immediately after a profile or
// vehicle photo is replaced (or a vehicle removed entirely), to delete the
// old Cloudinary asset. Cloudinary deletion needs a signed request with its
// API secret — the one credential in this whole app that can never live in
// the client — so this is the only piece that has to run server-side.
//
// chargeForAction / refundCredits / initializePaystackTransaction /
// paystackWebhook — the secure half of the credits economy. The client
// (lib/features/credits/services/credits_gateway.dart) tries these first
// for every gated action and every purchase, falling back to a
// client-enforced (real, but not server-verified) charge only for
// chargeForAction/refundCredits when these functions aren't deployed —
// never for purchases, which have no insecure fallback at all. See
// credits_gateway.dart's own comment for the full reasoning.
//
// NOT YET DEPLOYED. To deploy:
//   cd functions && npm install && npm run build
//   firebase deploy --only functions
// Requires the Firebase project to be on the Blaze (pay-as-you-go) plan —
// Cloud Functions that make outbound network calls (sending FCM messages,
// calling Cloudinary, calling Paystack, all are) aren't available on the
// free Spark plan. Also needs, once per environment (never committed):
//   firebase functions:secrets:set CLOUDINARY_API_KEY
//   firebase functions:secrets:set CLOUDINARY_API_SECRET
//   firebase functions:secrets:set PAYSTACK_SECRET_KEY
// plus a plain (non-secret) functions/.env with CLOUDINARY_CLOUD_NAME=...
// See SETUP.md's "Credits & payments" section for the full Paystack setup,
// including registering the webhook URL after first deploy.

import * as crypto from "crypto";
import { GeoPoint, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";
import { db } from "./shared";

export {
  saveCustomerProfile,
  submitMechanicApplication,
  getMyMechanicApplication,
  listMechanicApplications,
  reviewMechanicApplication,
} from "./onboarding";


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

async function persistNotification(input: {
  userId: string;
  title: string;
  body: string;
  type: string;
  requestId?: string;
  jobId?: string;
}): Promise<void> {
  await db.collection("notifications").add({
    ...input,
    isRead: false,
    createdAt: Timestamp.now(),
  });
}

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
  targetMechanicId?: string;
}

interface MechanicData {
  isVisible?: boolean;
  fcmToken?: string;
  location?: GeoPoint;
}

/**
 * Fires when a car owner broadcasts a new open service request. Alerts
 * every visible mechanic with a registered device token whose stored
 * location falls within the request's radius — or, if the request names a
 * specific `targetMechanicId` (the "Schedule Repair by ID" path), alerts
 * only that one mechanic, regardless of distance or visibility.
 */
export const notifyNearbyMechanics = onDocumentCreated(
  "serviceRequests/{requestId}",
  async (event) => {
    const request = event.data?.data() as ServiceRequestData | undefined;
    if (!request || request.status !== "open") return;

    if (request.targetMechanicId) {
      const targetDoc = await db
        .collection("mechanics")
        .doc(request.targetMechanicId)
        .get();
      const target = targetDoc.data() as MechanicData | undefined;
      if (!target) return;

      await persistNotification({
        userId: request.targetMechanicId,
        title: "You've been requested directly",
        body: request.issue
          ? `A car owner needs help: ${request.issue}`
          : "A car owner has requested you directly.",
        type: "service_request",
        requestId: event.params.requestId,
      });

      if (!target.fcmToken) return;
      await getMessaging().send({
        token: target.fcmToken,
        notification: {
          title: "You've been requested directly",
          body: request.issue
            ? `A car owner needs help: ${request.issue}`
            : "A car owner has requested you directly.",
        },
        data: {
          requestId: event.params.requestId,
          type: "service_request",
        },
      });
      return;
    }

    const carOwnerLocation = request.carOwnerLocation;
    const radiusKm = request.radiusKm ?? 15;

    const mechanicsSnap = await db
      .collection("mechanics")
      .where("isVisible", "==", true)
      .get();

    const tokens: string[] = [];
    for (const doc of mechanicsSnap.docs) {
      const mechanic = doc.data() as MechanicData;
      if (carOwnerLocation && mechanic.location) {
        const km = distanceKm(carOwnerLocation, mechanic.location);
        if (km > radiusKm) continue;
      }
      await persistNotification({
        userId: doc.id,
        title: "New service request nearby",
        body: request.issue
          ? `A car owner needs help: ${request.issue}`
          : "A car owner near you needs a mechanic.",
        type: "service_request",
        requestId: event.params.requestId,
      });
      if (mechanic.fcmToken) tokens.push(mechanic.fcmToken);
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

// ─── Direct-call push notifications ─────────────────────────────────────

/**
 * Alerts the addressed mechanic when a car owner starts a direct call.
 * Unlike the nearby-request trigger above, this watches jobs because a direct
 * call creates a pending job rather than a broadcast service request.
 */
export const notifyMechanicOfDirectCall = onDocumentCreated(
  "jobs/{jobId}",
  async (event) => {
    const job = event.data?.data() as {
      status?: string;
      mechanicId?: string;
      issue?: string;
    } | undefined;
    if (!job || job.status !== "pending" || !job.mechanicId) return;

    const mechanicDoc = await db
      .collection("mechanics")
      .doc(job.mechanicId)
      .get();
    const mechanic = mechanicDoc.data() as MechanicData | undefined;
    if (!mechanic) return;

    await persistNotification({
      userId: job.mechanicId,
      title: "Incoming call",
      body: job.issue
        ? `A car owner needs help: ${job.issue}`
        : "A car owner is calling you.",
      type: "direct_call",
      jobId: event.params.jobId,
    });

    if (!mechanic.fcmToken) return;
    await getMessaging().send({
      token: mechanic.fcmToken,
      notification: {
        title: "Incoming call",
        body: job.issue
          ? `A car owner needs help: ${job.issue}`
          : "A car owner is calling you.",
      },
      data: {
        jobId: event.params.jobId,
        type: "direct_call",
      },
    });
  }
);

// ─── Cloudinary photo cleanup ────────────────────────────────────────────

const cloudinaryApiKey = defineSecret("CLOUDINARY_API_KEY");
const cloudinaryApiSecret = defineSecret("CLOUDINARY_API_SECRET");

/**
 * Deletes one Cloudinary image by its public_id. Every public_id this app
 * ever creates is "{uid}_{timestamp}" (see CloudinaryService in the Flutter
 * app) — checking that prefix here is what lets a caller only ever delete
 * their own photos, the same ownership boundary storage.rules used to
 * enforce for Firebase Storage, just checked server-side now since
 * Cloudinary's delete endpoint needs a signed request the client can never
 * safely hold the signing key for.
 */
export const deleteCloudinaryImage = onCall(
  { secrets: [cloudinaryApiKey, cloudinaryApiSecret] },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }

    const publicId = request.data?.publicId;
    if (typeof publicId !== "string" || publicId.length === 0) {
      throw new HttpsError("invalid-argument", "publicId is required.");
    }
    if (!publicId.startsWith(`${uid}_`)) {
      throw new HttpsError(
        "permission-denied",
        "You can only delete your own photos."
      );
    }

    const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
    if (!cloudName) {
      throw new HttpsError(
        "failed-precondition",
        "Cloudinary isn't configured on the server."
      );
    }

    const timestamp = Math.floor(Date.now() / 1000).toString();
    const paramsToSign =
      `public_id=${publicId}&timestamp=${timestamp}${cloudinaryApiSecret.value()}`;
    const signature = crypto.createHash("sha1").update(paramsToSign).digest("hex");

    const body = new URLSearchParams({
      public_id: publicId,
      timestamp,
      api_key: cloudinaryApiKey.value(),
      signature,
    });

    const response = await fetch(
      `https://api.cloudinary.com/v1_1/${cloudName}/image/destroy`,
      {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body,
      }
    );
    const result = (await response.json()) as { result?: string };

    // Cloudinary returns "not found" (not an error) if it's already gone —
    // a fine outcome for a cleanup call, not something to surface as a
    // failure to the app.
    if (result.result !== "ok" && result.result !== "not found") {
      throw new HttpsError("internal", "Failed to delete the old image.");
    }

    return { result: result.result };
  }
);

// ─── Credits: gated actions ──────────────────────────────────────────────

// Mirrors lib/core/constants/credits_pricing.dart — keep the two in sync;
// this table (not anything the client sends) is the only source of truth
// for what an action actually costs.
const ACTION_PRICING: Record<string, { amount: number; reason: string }> = {
  contact_mechanic: { amount: 5, reason: "Contacted a mechanic" },
  obd_scan: { amount: 10, reason: "Ran an OBD-II scan" },
};

/**
 * Charges the signed-in user for a gated action. The balance check and the
 * ledger write happen inside the same Firestore transaction as the debit
 * itself, so "charged twice" or "charged but balance never actually moved"
 * are structurally impossible here, unlike the client-side fallback this
 * is meant to replace (credits_provider.dart's deduct()).
 */
export const chargeForAction = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const action = request.data?.action;
  const pricing = typeof action === "string" ? ACTION_PRICING[action] : undefined;
  if (!pricing) {
    throw new HttpsError("invalid-argument", "Unknown action.");
  }
  const relatedEntityId = request.data?.relatedEntityId as string | undefined;

  const userRef = db.collection("users").doc(uid);
  await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(userRef);
    const balance = (snap.data()?.credits as number | undefined) ?? 0;
    if (balance < pricing.amount) {
      throw new HttpsError("resource-exhausted", "Not enough credits.");
    }

    transaction.update(userRef, { credits: balance - pricing.amount });
    const historyRef = db.collection("credits_history").doc();
    transaction.set(historyRef, {
      userId: uid,
      type: "debit",
      amount: pricing.amount,
      reason: pricing.reason,
      ...(relatedEntityId ? { relatedEntityId } : {}),
      createdAt: Timestamp.now(),
    });
  });

  return { charged: pricing.amount };
});

/**
 * Refunds a charge for a system-caused failure (e.g. a scan whose adapter
 * disconnected mid-read) — never for a user-caused one. Requires proof a
 * matching, not-yet-refunded debit for this exact relatedEntityId really
 * happened, so a client can't call this to just grant itself free credits
 * under the guise of a "refund"; that's the exact hole this whole rewrite
 * exists to close.
 */
export const refundCredits = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const relatedEntityId = request.data?.relatedEntityId;
  if (typeof relatedEntityId !== "string" || relatedEntityId.length === 0) {
    throw new HttpsError("invalid-argument", "relatedEntityId is required.");
  }

  // A single equality filter — relatedEntityId is a Firestore-generated
  // id (a scanId, a contact-request id), so at most one debit anywhere
  // in the collection should ever match it. Deliberately not adding
  // userId/type as extra where() clauses (which would need a composite
  // index); ownership and type are checked below instead, in code.
  const matches = await db
    .collection("credits_history")
    .where("relatedEntityId", "==", relatedEntityId)
    .limit(5)
    .get();
  const chargeDoc = matches.docs.find(
    (doc) =>
      doc.data().userId === uid &&
      doc.data().type === "debit" &&
      doc.data().refunded !== true
  );
  if (!chargeDoc) {
    throw new HttpsError(
      "not-found",
      "No matching, un-refunded charge found for this."
    );
  }
  const amount = chargeDoc.data().amount as number;

  const userRef = db.collection("users").doc(uid);
  await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(userRef);
    const balance = (snap.data()?.credits as number | undefined) ?? 0;
    transaction.update(userRef, { credits: balance + amount });
    transaction.update(chargeDoc.ref, { refunded: true });

    const historyRef = db.collection("credits_history").doc();
    transaction.set(historyRef, {
      userId: uid,
      type: "credit",
      amount,
      reason: `Refund: ${
        typeof request.data?.reason === "string"
          ? request.data.reason
          : "action did not complete"
      }`,
      relatedEntityId,
      createdAt: Timestamp.now(),
    });
  });

  return { refunded: amount };
});

// ─── Credits: Paystack purchases ─────────────────────────────────────────

const paystackSecretKey = defineSecret("PAYSTACK_SECRET_KEY");

// Mirrors lib/features/credits/screens/buy_credits_screen.dart's own
// bundle list. Kept here too, and never trusted from the client — a caller
// only ever picks an index into this fixed table, never an amount.
const CREDIT_BUNDLES: { credits: number; priceNaira: number }[] = [
  { credits: 100, priceNaira: 2000 },
  { credits: 250, priceNaira: 4500 },
  { credits: 500, priceNaira: 8500 },
  { credits: 1000, priceNaira: 15000 },
];

/**
 * Starts a Paystack transaction and returns its checkout URL. This never
 * grants credits itself — that only ever happens in paystackWebhook, once
 * Paystack confirms the payment actually succeeded. All this does is
 * record what the eventual webhook call should credit, keyed by the
 * transaction reference it mints here.
 */
export const initializePaystackTransaction = onCall(
  { secrets: [paystackSecretKey] },
  async (request) => {
    const uid = request.auth?.uid;
    const email = request.auth?.token.email as string | undefined;
    if (!uid || !email) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }

    const bundleIndex = request.data?.bundleIndex;
    const bundle =
      typeof bundleIndex === "number" ? CREDIT_BUNDLES[bundleIndex] : undefined;
    if (!bundle) {
      throw new HttpsError("invalid-argument", "Unknown bundle.");
    }

    const reference = `sda_${uid.slice(0, 8)}_${Timestamp.now().toMillis()}`;
    const response = await fetch(
      "https://api.paystack.co/transaction/initialize",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${paystackSecretKey.value()}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          amount: bundle.priceNaira * 100, // Paystack wants kobo.
          reference,
          currency: "NGN",
        }),
      }
    );
    const body = (await response.json()) as {
      status?: boolean;
      data?: { authorization_url?: string };
      message?: string;
    };
    if (!response.ok || !body.status || !body.data?.authorization_url) {
      throw new HttpsError(
        "internal",
        body.message ?? "Could not start the payment."
      );
    }

    // Only paystackWebhook ever reads this — it's how it knows who and how
    // much to credit once Paystack confirms the charge succeeded.
    await db.collection("pending_purchases").doc(reference).set({
      uid,
      credits: bundle.credits,
      amountKobo: bundle.priceNaira * 100,
      status: "pending",
      createdAt: Timestamp.now(),
    });

    return { authorizationUrl: body.data.authorization_url, reference };
  }
);

/**
 * Paystack's server-to-server confirmation that a payment actually went
 * through — the only place a purchase's credits are ever granted. Verifies
 * the x-paystack-signature header (HMAC-SHA512 of the raw request body,
 * using the same secret key) before trusting anything in the payload; an
 * unsigned or mis-signed request is rejected outright, never processed.
 */
export const paystackWebhook = onRequest(
  { secrets: [paystackSecretKey] },
  async (req, res) => {
    const signature = req.headers["x-paystack-signature"];
    const expectedSignature = crypto
      .createHmac("sha512", paystackSecretKey.value())
      .update(req.rawBody)
      .digest("hex");
    if (signature !== expectedSignature) {
      res.status(401).send("Invalid signature");
      return;
    }

    const event = req.body as {
      event?: string;
      data?: { reference?: string };
    };
    if (event.event !== "charge.success" || !event.data?.reference) {
      res.status(200).send("Ignored");
      return;
    }
    const reference = event.data.reference;
    const pendingRef = db.collection("pending_purchases").doc(reference);

    await db.runTransaction(async (transaction) => {
      const pendingSnap = await transaction.get(pendingRef);
      if (!pendingSnap.exists) return; // Unknown reference — nothing to credit.
      const pending = pendingSnap.data() as {
        uid: string;
        credits: number;
        status: string;
      };
      if (pending.status === "completed") return; // Already credited.

      const userRef = db.collection("users").doc(pending.uid);
      const userSnap = await transaction.get(userRef);
      const balance = (userSnap.data()?.credits as number | undefined) ?? 0;
      transaction.update(userRef, { credits: balance + pending.credits });
      transaction.update(pendingRef, { status: "completed" });

      const historyRef = db.collection("credits_history").doc();
      transaction.set(historyRef, {
        userId: pending.uid,
        type: "credit",
        amount: pending.credits,
        reason: "Purchased credits",
        relatedEntityId: reference,
        createdAt: Timestamp.now(),
      });
    });

    res.status(200).send("OK");
  }
);

// ─── Atomic quote acceptance ─────────────────────────────────────────────

/**
 * Accepts exactly one quote for an open service request and creates its job
 * in the same transaction. Repeated calls return the already-created job,
 * while competing quote acceptances are rejected by the request status check.
 */
export const acceptServiceQuote = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const requestId = request.data?.requestId;
  const mechanicId = request.data?.mechanicId;
  if (typeof requestId !== "string" || !requestId.trim() ||
      typeof mechanicId !== "string" || !mechanicId.trim()) {
    throw new HttpsError("invalid-argument", "Request and quote references are required.");
  }

  const requestRef = db.collection("serviceRequests").doc(requestId);
  const quoteRef = requestRef.collection("quotes").doc(mechanicId);
  const jobRef = db.collection("jobs").doc();

  let resultJobId = "";
  let alreadyAccepted = false;
  await db.runTransaction(async (transaction) => {
    const requestSnap = await transaction.get(requestRef);
    if (!requestSnap.exists) {
      throw new HttpsError("not-found", "This repair request could not be found.");
    }
    const serviceRequest = requestSnap.data() as {
      carOwnerId?: string;
      issue?: string;
      vehicleId?: string;
      carOwnerLocation?: GeoPoint;
      status?: string;
      jobId?: string;
    };

    if (serviceRequest.carOwnerId !== uid) {
      throw new HttpsError("permission-denied", "Only the customer who created this request can accept a quote.");
    }

    // Idempotency: if the request already points to a job, never create a
    // second one, even if the client retries after a network timeout.
    if (serviceRequest.jobId) {
      resultJobId = serviceRequest.jobId;
      alreadyAccepted = true;
      return;
    }
    if (!["open", "pending"].includes(serviceRequest.status ?? "open")) {
      throw new HttpsError("failed-precondition", "This request is no longer open for quote acceptance.");
    }

    const quoteSnap = await transaction.get(quoteRef);
    if (!quoteSnap.exists) {
      throw new HttpsError("not-found", "This mechanic's quote could not be found.");
    }
    const quote = quoteSnap.data() as { status?: string; price?: number; note?: string };
    if (quote.status && !["pending", "submitted", "open"].includes(quote.status)) {
      throw new HttpsError("failed-precondition", "This quote is no longer available.");
    }
    if (typeof quote.price !== "number" || !Number.isFinite(quote.price) || quote.price < 0) {
      throw new HttpsError("failed-precondition", "This quote does not have a valid price.");
    }

    const quotesQuery = requestRef.collection("quotes");
    const quotesSnap = await transaction.get(quotesQuery);
    if (quotesSnap.docs.some((doc) => doc.id !== mechanicId && doc.data().status === "accepted")) {
      throw new HttpsError("failed-precondition", "Another quote has already been accepted.");
    }

    const now = Timestamp.now();
    transaction.create(jobRef, {
      carOwnerId: uid,
      mechanicId,
      vehicleId: serviceRequest.vehicleId ?? "",
      issue: serviceRequest.issue ?? "Repair request",
      status: "pending",
      ...(serviceRequest.carOwnerLocation ? { carOwnerLocation: serviceRequest.carOwnerLocation } : {}),
      acceptedQuotePrice: quote.price,
      acceptedQuoteNote: typeof quote.note === "string" ? quote.note : "",
      serviceRequestId: requestId,
      createdAt: now,
      updatedAt: now,
    });
    transaction.update(requestRef, {
      status: "matched",
      jobId: jobRef.id,
      acceptedMechanicId: mechanicId,
      updatedAt: now,
    });
    for (const doc of quotesSnap.docs) {
      transaction.update(doc.ref, {
        status: doc.id === mechanicId ? "accepted" : "declined",
        updatedAt: now,
      });
    }
    resultJobId = jobRef.id;
  });

  if (!alreadyAccepted) {
    try {
      await persistNotification({
        userId: mechanicId,
        title: "Your quote was accepted",
        body: "The customer accepted your repair quote. Open Standiag Auto to review the job.",
        type: "quote_accepted",
        requestId,
        jobId: resultJobId,
      });
    } catch (error) {
      console.error("Quote accepted but mechanic notification could not be saved.", error);
    }
  }

  return { success: true, jobId: resultJobId, alreadyAccepted };
});

// ─── Trusted mechanic job lifecycle ─────────────────────────────────────

const JOB_TRANSITIONS: Record<string, { next: string; timestamp?: string }> = {
  accept: { next: "accepted", timestamp: "acceptedAt" },
  reject: { next: "rejected", timestamp: "rejectedAt" },
  start_travel: { next: "en_route", timestamp: "enRouteAt" },
  arrive: { next: "arrived", timestamp: "arrivedAt" },
  start_work: { next: "in_progress", timestamp: "startedAt" },
  complete: { next: "completed", timestamp: "completedAt" },
};

const ALLOWED_JOB_ACTIONS: Record<string, string[]> = {
  pending: ["accept", "reject"],
  accepted: ["start_travel"],
  en_route: ["arrive"],
  arrived: ["start_work"],
  in_progress: ["complete"],
};

/**
 * Applies one legal job transition after verifying the caller is the assigned
 * mechanic. The transaction checks the current status and writes the status,
 * timestamp and audit fields atomically; clients cannot choose their own
 * next status or timestamps.
 */
export const transitionMechanicJob = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const jobId = request.data?.jobId;
  const action = request.data?.action;
  if (typeof jobId !== "string" || !jobId.trim()) {
    throw new HttpsError("invalid-argument", "jobId is required.");
  }
  if (typeof action !== "string" || !JOB_TRANSITIONS[action]) {
    throw new HttpsError("invalid-argument", "Unknown job action.");
  }

  const jobRef = db.collection("jobs").doc(jobId);
  let nextStatus = "";
  await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(jobRef);
    if (!snap.exists) {
      throw new HttpsError("not-found", "This job could not be found.");
    }
    const job = snap.data() as {
      mechanicId?: string;
      status?: string;
      carOwnerId?: string;
      issue?: string;
    };
    if (job.mechanicId !== uid) {
      throw new HttpsError("permission-denied", "Only the assigned mechanic can update this job.");
    }
    const currentStatus = job.status ?? "pending";
    if (!(ALLOWED_JOB_ACTIONS[currentStatus] ?? []).includes(action)) {
      throw new HttpsError("failed-precondition", "This action is not available for the current job status.");
    }

    const transition = JOB_TRANSITIONS[action];
    nextStatus = transition.next;
    const update: Record<string, string | Timestamp> = {
      status: transition.next,
      updatedAt: Timestamp.now(),
      lastUpdatedBy: uid,
    };
    if (transition.timestamp) update[transition.timestamp] = Timestamp.now();
    transaction.update(jobRef, update);
  });

  // Notifications are secondary: a notification write failure must not make
  // a successfully committed job transition appear to have failed to the app.
  try {
    const jobSnap = await jobRef.get();
    const job = jobSnap.data() as { carOwnerId?: string; issue?: string } | undefined;
    if (job?.carOwnerId) {
      await persistNotification({
        userId: job.carOwnerId,
        title: nextStatus === "rejected" ? "Mechanic declined the job" : "Job status updated",
        body: job.issue
          ? `Your repair job "${job.issue}" is now ${nextStatus.replace(/_/g, " ")}.`
          : `Your repair job is now ${nextStatus.replace(/_/g, " ")}.`,
        type: "job_status",
        jobId,
      });
    }
  } catch (error) {
    console.error("Job transitioned but customer notification could not be saved.", error);
  }

  return { success: true, status: nextStatus };
});


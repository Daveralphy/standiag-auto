import { getAuth } from "firebase-admin/auth";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "./shared";

// All privileged changes live here, not in the Flutter or admin web clients.
// Admins receive the custom claim through a trusted operator workflow.
function requireVerifiedUser(request: Parameters<Parameters<typeof onCall>[0]>[0]): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in to continue.");
  }
  if (request.auth?.token.email_verified !== true) {
    throw new HttpsError("failed-precondition", "Verify your email before continuing.");
  }
  return uid;
}

function requireAdmin(request: Parameters<Parameters<typeof onCall>[0]>[0]): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in to continue.");
  if (request.auth?.token.admin !== true) {
    throw new HttpsError("permission-denied", "Administrator access is required.");
  }
  return uid;
}

function requiredText(value: unknown, field: string, maxLength = 160): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  const cleaned = value.trim();
  if (!cleaned || cleaned.length > maxLength) {
    throw new HttpsError("invalid-argument", `${field} is invalid.`);
  }
  return cleaned;
}

/**
 * Creates or completes the customer profile without overwriting protected
 * fields, account roles, credits, or an existing mechanic profile.
 */
export const saveCustomerProfile = onCall(async (request) => {
  const uid = requireVerifiedUser(request);
  const firstName = requiredText(request.data?.firstName, "First name", 80);
  const lastName = requiredText(request.data?.lastName, "Last name", 80);
  const phone = requiredText(request.data?.phone, "Phone number", 40);
  const email = request.auth?.token.email as string | undefined;
  if (!email) throw new HttpsError("failed-precondition", "The account has no email address.");

  const userRef = db.collection("users").doc(uid);
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(userRef);
    const existing = snapshot.data() ?? {};
    transaction.set(userRef, {
      uid,
      email,
      firstName,
      lastName,
      phone,
      type: existing.type ?? "car_owner",
      roles: Array.isArray(existing.roles) ? existing.roles : ["customer"],
      createdAt: existing.createdAt ?? Timestamp.now(),
      isFirstTime: false,
      updatedAt: Timestamp.now(),
    }, { merge: true });
  });

  return { success: true };
});

/**
 * Submits or updates a mechanic/workshop application. The applicant can
 * edit their own pending/revision-requested application only; approval
 * decisions are made exclusively by requireAdmin-protected operations.
 */
export const submitMechanicApplication = onCall(async (request) => {
  const uid = requireVerifiedUser(request);
  const applicantName = requiredText(request.data?.applicantName, "Applicant name", 160);
  const phone = requiredText(request.data?.phone, "Phone number", 40);
  const serviceArea = requiredText(request.data?.serviceArea, "Service area", 300);
  const expertiseInput = request.data?.expertise;
  if (!Array.isArray(expertiseInput) || expertiseInput.length < 1 || expertiseInput.length > 20) {
    throw new HttpsError("invalid-argument", "Choose between 1 and 20 areas of expertise.");
  }
  const expertise = expertiseInput.map((item: unknown) => requiredText(item, "Expertise", 80));
  const yearsOfExperience = request.data?.yearsOfExperience;
  if (!Number.isInteger(yearsOfExperience) || yearsOfExperience < 0 || yearsOfExperience > 80) {
    throw new HttpsError("invalid-argument", "Years of experience must be between 0 and 80.");
  }
  const applicantType = request.data?.applicantType;
  if (applicantType !== "independent" && applicantType !== "workshop") {
    throw new HttpsError("invalid-argument", "Choose independent mechanic or workshop.");
  }
  const workshopName = applicantType === "workshop"
    ? requiredText(request.data?.workshopName, "Workshop name", 160)
    : null;
  const email = request.auth?.token.email as string | undefined;

  const applicationRef = db.collection("mechanicApplications").doc(uid);
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(applicationRef);
    const existing = snapshot.data();
    if (existing?.status === "approved") {
      throw new HttpsError("failed-precondition", "This mechanic application is already approved.");
    }
    if (existing?.status === "pending") {
      throw new HttpsError("failed-precondition", "Your application is already awaiting review.");
    }
    transaction.set(applicationRef, {
      applicantId: uid,
      applicantName,
      email: email ?? "",
      phone,
      applicantType,
      ...(workshopName ? { workshopName } : {}),
      serviceArea,
      expertise,
      yearsOfExperience,
      status: "pending",
      submittedAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      decisionReason: FieldValue.delete(),
      decidedAt: FieldValue.delete(),
      decidedBy: FieldValue.delete(),
    }, { merge: true });
  });

  return { success: true, status: "pending" };
});

/** Admin-only queue; the browser never gets direct access to private applications. */
export const listMechanicApplications = onCall(async (request) => {
  requireAdmin(request);
  const status = request.data?.status ?? "pending";
  if (!["pending", "approved", "rejected", "more_information"].includes(status)) {
    throw new HttpsError("invalid-argument", "Unknown application status.");
  }
  const snapshot = await db.collection("mechanicApplications")
    .where("status", "==", status)
    .orderBy("submittedAt", "asc")
    .limit(100)
    .get();
  return {
    applications: snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
  };
});

/** Admin-only decision endpoint. No client-supplied role or visibility is trusted. */
export const reviewMechanicApplication = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const applicantId = requiredText(request.data?.applicantId, "Applicant ID", 128);
  const decision = request.data?.decision;
  if (!["approved", "rejected", "more_information"].includes(decision)) {
    throw new HttpsError("invalid-argument", "Choose an allowed review decision.");
  }
  const reason = requiredText(request.data?.reason, "Decision reason", 1000);
  const applicationRef = db.collection("mechanicApplications").doc(applicantId);
  const mechanicRef = db.collection("mechanics").doc(applicantId);
  const userRef = db.collection("users").doc(applicantId);

  await db.runTransaction(async (transaction) => {
    const applicationSnapshot = await transaction.get(applicationRef);
    if (!applicationSnapshot.exists) {
      throw new HttpsError("not-found", "Mechanic application not found.");
    }
    const application = applicationSnapshot.data()!;
    if (!["pending", "more_information", "rejected"].includes(application.status)) {
      throw new HttpsError("failed-precondition", "This application cannot be reviewed in its current state.");
    }
    transaction.update(applicationRef, {
      status: decision,
      decisionReason: reason,
      decidedAt: Timestamp.now(),
      decidedBy: adminUid,
      updatedAt: Timestamp.now(),
    });
    if (decision === "approved") {
      transaction.set(mechanicRef, {
        uid: applicantId,
        workshopAddress: application.serviceArea,
        expertise: application.expertise,
        yearsOfExperience: application.yearsOfExperience,
        rating: 0,
        totalJobs: 0,
        credits: 0,
        isVisible: true,
        applicantType: application.applicantType,
        ...(application.workshopName ? { workshopName: application.workshopName } : {}),
        approvedAt: Timestamp.now(),
        approvedBy: adminUid,
      }, { merge: true });
      transaction.set(userRef, {
        uid: applicantId,
        email: application.email,
        roles: FieldValue.arrayUnion("mechanic"),
        updatedAt: Timestamp.now(),
      }, { merge: true });
    } else if (decision === "rejected") {
      // If a previously rejected application is reviewed again, ensure no
      // public mechanic profile remains visible until a new approval.
      transaction.set(mechanicRef, { isVisible: false }, { merge: true });
    }
  });

  return { success: true, status: decision };
});

/**
 * Trusted operator bootstrap helper. Intentionally not callable by app users:
 * assign custom claims with a secured Admin SDK script/console workflow.
 */
export async function setAdminClaimForTrustedOperator(uid: string): Promise<void> {
  const user = await getAuth().getUser(uid);
  await getAuth().setCustomUserClaims(uid, { ...(user.customClaims ?? {}), admin: true });
}

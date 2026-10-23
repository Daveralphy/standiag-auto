import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// Imported modules are evaluated before index.ts executes its top-level code.
// Initialise the Admin SDK here so callable modules can safely obtain Firestore.
if (getApps().length === 0) {
  initializeApp();
}

export const db = getFirestore();

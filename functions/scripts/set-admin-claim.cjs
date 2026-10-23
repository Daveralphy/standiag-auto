#!/usr/bin/env node
'use strict';

// Run only from a trusted operator workstation with Application Default
// Credentials for the intended Firebase project. Never expose this as an HTTP
// endpoint and never commit service-account credentials.
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

async function main() {
  const uid = process.argv[2];
  const projectId = process.env.GCLOUD_PROJECT || process.env.FIREBASE_PROJECT_ID;

  if (!uid || !projectId) {
    console.error(
      'Usage: GCLOUD_PROJECT=<firebase-project-id> node scripts/set-admin-claim.cjs <firebase-auth-uid>',
    );
    process.exitCode = 2;
    return;
  }

  initializeApp({
    credential: applicationDefault(),
    projectId,
  });

  const auth = getAuth();
  const user = await auth.getUser(uid);
  const currentClaims = user.customClaims || {};
  if (currentClaims.admin === true) {
    console.log(`User ${uid} already has the admin claim in project ${projectId}.`);
    return;
  }

  await auth.setCustomUserClaims(uid, {
    ...currentClaims,
    admin: true,
  });

  console.log(
    `Granted the admin claim to ${uid} in project ${projectId}. The user must refresh their ID token before the claim is present in the session.`,
  );
}

main().catch((error) => {
  console.error('Could not assign the admin claim:', error.message || error);
  process.exitCode = 1;
});

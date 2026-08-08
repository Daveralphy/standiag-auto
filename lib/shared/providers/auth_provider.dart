// Shared auth state provider for StanDiag Auto.
// Exposes the Firebase Auth stream so any widget or provider
// can reactively respond to login and logout events.
// The GoRouter watches this to redirect users automatically.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/models/mechanic_model.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/providers/signup_draft_provider.dart';

// Streams the current Firebase Auth user.
// Emits null when logged out, a User object when logged in.
// GoRouter's redirect logic watches this to gate protected routes.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Synchronous snapshot of the current user.
// Use this when you need the user object without listening to the stream.
// Returns null if not authenticated.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Whether the current user is authenticated.
// Convenience provider derived from authStateProvider.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// The current user's UID.
// Returns null if not authenticated.
// Used for Firestore queries and Crashlytics logging.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

// Exposes AuthController — the single place sign-in/sign-up/sign-out
// business logic lives, so screens never call FirebaseAuth directly.
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

/// Owns every Firebase Auth mutation in the app (sign in, sign up, sign out,
/// OTP verification). Screens call these methods instead of touching
/// FirebaseAuth directly, and handle the resulting errors through
/// core/errors/error_handler.dart like any other action.
class AuthController {
  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  /// Resolves a login identifier that may be a username or an email to the
  /// account's email, then signs in. Throws a [StateError] if no account
  /// matches the given username so the caller can show a field-level error.
  ///
  /// The username lookup reads usernames/{username} — a doc deliberately
  /// separate from users/{uid} and readable pre-auth — rather than querying
  /// the users/ collection directly, since that collection requires being
  /// signed in already (a chicken-and-egg problem for username login).
  Future<void> signInWithIdentifier(String identifier, String password) async {
    final trimmed = identifier.trim();
    String email = trimmed;
    if (!trimmed.contains('@')) {
      final doc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(trimmed)
          .get()
          .timeout(const Duration(seconds: 5));
      if (!doc.exists) {
        throw StateError('username-not-found');
      }
      email = doc.data()?['email'] as String? ?? trimmed;
    }
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(const Duration(seconds: 15));
    await _backfillUsernameLookup();
  }

  /// Self-healing backfill for accounts created before usernames/{username}
  /// existed: on every successful sign-in, make sure this account's lookup
  /// doc exists, creating it from their own users/{uid} doc if not. Cheap,
  /// idempotent, and needs no admin/migration access — every existing user
  /// fixes their own entry the next time they sign in with their email.
  Future<void> _backfillUsernameLookup() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final username = userDoc.data()?['username'] as String?;
      final email = userDoc.data()?['email'] as String?;
      if (username == null || username.isEmpty || email == null) return;

      final lookupRef = FirebaseFirestore.instance
          .collection('usernames')
          .doc(username);
      final lookupDoc = await lookupRef.get();
      if (lookupDoc.exists) return;
      await lookupRef.set({'uid': user.uid, 'email': email});
    } catch (_) {
      // Best-effort — a failed backfill just means this account tries again
      // on its next sign-in, not a reason to fail the sign-in itself.
    }
  }

  /// Resolves [uid]'s real profile type with a single one-time fetch.
  /// Used right after sign-in/signup so the app can navigate straight to
  /// the correct home screen instead of guessing and letting the router's
  /// redirect correct it a moment later (which reads as a visible flash of
  /// the wrong home screen). Falls back to carOwner if the doc can't be
  /// read in time — same fallback the router's type guard already assumes.
  Future<UserType> fetchUserType(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 5));
      final type = doc.data()?['type'] as String?;
      return type == 'mechanic' ? UserType.mechanic : UserType.carOwner;
    } catch (_) {
      return UserType.carOwner;
    }
  }

  /// Creates the Firebase Auth account and the matching Firestore profile
  /// document(s) for the given signup draft. Mechanics also get a
  /// `mechanics/{uid}` document alongside their `users/{uid}` document.
  Future<void> signUp(SignupDraft draft) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: draft.email,
          password: draft.password,
        );
    final user = credential.user!;
    final fullName = '${draft.firstName} ${draft.lastName}'.trim();
    if (fullName.isNotEmpty) {
      await user.updateDisplayName(fullName);
    }

    final userModel = UserModel(
      uid: user.uid,
      type: draft.type,
      firstName: draft.firstName,
      lastName: draft.lastName,
      username: draft.username,
      email: draft.email,
      phone: draft.phone,
      address: draft.type == UserType.mechanic
          ? draft.workshopAddress
          : draft.address,
      credits: 0,
      createdAt: DateTime.now(),
      isFirstTime: true,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());

    if (draft.username.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(draft.username)
          .set({'uid': user.uid, 'email': draft.email});
    }

    if (draft.type == UserType.mechanic) {
      final mechanicModel = MechanicModel(
        uid: user.uid,
        workshopAddress: draft.workshopAddress,
        expertise: draft.expertise,
        yearsOfExperience: draft.yearsOfExperience,
        rating: 0,
        totalJobs: 0,
        credits: 0,
        isVisible: true,
      );
      await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(user.uid)
          .set(mechanicModel.toFirestore());
    }
  }

  /// Sends (or resends) the verification link to the signed-in user's email.
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified) return;
    await user.sendEmailVerification();
  }

  /// Reloads the signed-in user from Firebase and reports whether their
  /// email has been verified (i.e. they clicked the link).
  Future<bool> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    await user.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  /// Starts phone number verification. [onCodeSent] receives the
  /// verification ID needed by [verifyPhoneOtp]; [onVerificationFailed]
  /// receives any error Firebase reports (invalid number, quota, etc).
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
  }) {
    return FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) => _linkOrSignIn(credential),
      verificationFailed: onVerificationFailed,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Confirms the 6-digit SMS code against the verification ID from
  /// [sendPhoneOtp], linking the phone number to the current account.
  Future<void> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _linkOrSignIn(credential);
  }

  /// Re-authenticates with the current password, then sets the new one.
  /// Throws FirebaseAuthException('wrong-password') if [currentPassword]
  /// doesn't match — callers surface that as a field-level error.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw StateError('Not signed in');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Looks up [email] in Firestore first so the caller can show a clear
  /// "no account with that email" error; only calls Firebase's real password
  /// reset email send if an account actually exists. Throws a [StateError]
  /// when no account matches, same pattern as [signInWithIdentifier].
  Future<void> sendPasswordReset(String email) async {
    final trimmed = email.trim();
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: trimmed)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 5));
    if (snap.docs.isEmpty) {
      throw StateError('email-not-found');
    }
    await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmed);
  }

  Future<void> _linkOrSignIn(PhoneAuthCredential credential) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInWithCredential(credential);
      return;
    }
    try {
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // The phone is already verified/linked on this account — not an error.
      if (e.code != 'credential-already-in-use' &&
          e.code != 'provider-already-linked') {
        rethrow;
      }
    }
  }
}

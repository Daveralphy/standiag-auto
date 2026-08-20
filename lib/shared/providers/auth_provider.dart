// Shared auth state provider for StanDiag Auto.
// Exposes the Firebase Auth stream so any widget or provider
// can reactively respond to login and logout events.
// The GoRouter watches this to redirect users automatically.

import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/config/social_signin_config.dart';
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

  /// Signs in (or up — Google's account picker handles both identically)
  /// with Google, exchanging its credential for a Firebase one. Callers
  /// check `userCredential.additionalUserInfo?.isNewUser` (or
  /// [hasProfile]) to know whether this account still needs a StanDiag
  /// profile — type + username — created for it, same as a brand-new
  /// email signup would.
  Future<UserCredential> signInWithGoogle() async {
    if (!SocialSignInConfig.isGoogleConfigured) {
      throw StateError('google-signin-not-configured');
    }
    final googleSignIn = GoogleSignIn(
      serverClientId: SocialSignInConfig.googleWebClientId,
      clientId: !kIsWeb && Platform.isIOS
          ? SocialSignInConfig.googleIosClientId
          : null,
    );
    final account = await googleSignIn.signIn();
    if (account == null) {
      // The user closed the account picker — not a real error.
      throw StateError('google-signin-cancelled');
    }
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Signs in (or up) with Apple. Native on iOS/macOS (just the Xcode
  /// "Sign in with Apple" capability, already in
  /// ios/Runner/Runner.entitlements) — everywhere else goes through the
  /// Services ID + hosted redirect page configured in .env.
  Future<UserCredential> signInWithApple() async {
    final needsWebFlow = kIsWeb || (!Platform.isIOS && !Platform.isMacOS);
    if (needsWebFlow && !SocialSignInConfig.isAppleConfiguredForAndroid) {
      throw StateError('apple-signin-not-configured');
    }

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
      webAuthenticationOptions: needsWebFlow
          ? WebAuthenticationOptions(
              clientId: SocialSignInConfig.appleServiceId,
              redirectUri: Uri.parse(SocialSignInConfig.appleRedirectUri),
            )
          : null,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    // Apple only ever hands back the person's name on the *first*
    // authorization ever — never again after that, even on a fresh
    // install — so this is the one moment it's available to save at all.
    final name = [appleCredential.givenName, appleCredential.familyName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    if (name.isNotEmpty && (userCredential.user?.displayName ?? '').isEmpty) {
      await userCredential.user?.updateDisplayName(name);
    }
    return userCredential;
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  /// Whether [uid] already has a StanDiag profile (a users/{uid} doc) —
  /// true for a returning social sign-in, false for one whose Firebase
  /// Auth account just got created via Google/Apple and still needs the
  /// type + username completion step every other signup path collects.
  Future<bool> hasProfile(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists;
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

  /// Sends a password reset email. Deliberately doesn't pre-check whether an
  /// account exists for [email] — an earlier version queried `users/` first
  /// (the same pre-auth-query bug that broke username login, since that
  /// collection's rules require being signed in already), and confirming or
  /// denying an email's existence here is an account-enumeration leak
  /// anyway. Firebase's own email-enumeration protection already no-ops
  /// silently for unknown addresses; the catch below covers projects where
  /// that protection is off and it throws `user-not-found` instead, so this
  /// method behaves the same either way — always succeeds, never reveals
  /// whether the address is registered.
  Future<void> sendPasswordReset(String email) async {
    final trimmed = email.trim();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmed);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') rethrow;
    }
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

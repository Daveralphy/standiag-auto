// Shared auth state provider for StanDiag Auto.
// Exposes the Firebase Auth stream so any widget or provider
// can reactively respond to login and logout events.
// The GoRouter watches this to redirect users automatically.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
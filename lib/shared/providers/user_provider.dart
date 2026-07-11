// User provider — fetches the current user's profile from Firestore
// and exposes it reactively to all screens.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/models/user_model.dart';
import 'auth_provider.dart';

// Stream the current user's Firestore document in real time.
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }

        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser == null) {
          return null;
        }

        return UserModel.fromFirebaseUser(authUser);
      });
});

// The current user's profile type (CarOwner or Mechanic), derived from
// their Firestore document. Defaults to carOwner while the profile is
// still loading, matching the fallback already used at login/splash.
// The router and every type-aware screen (settings, credits) read this.
final currentUserTypeProvider = Provider<UserType>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.type ?? UserType.carOwner;
});
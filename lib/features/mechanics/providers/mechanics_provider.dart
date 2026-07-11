import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/models/mechanic_model.dart';

// Fetch all visible mechanics once from Firestore mechanics/ collection.
final mechanicsProvider = FutureProvider<List<MechanicModel>>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection('mechanics')
      .where('isVisible', isEqualTo: true)
      .get();
  return snap.docs.map((doc) => MechanicModel.fromFirestore(doc)).toList();
});

// One-time fetch of a single mechanic by UID from mechanics/ collection.
// Not real-time (Rule 13): a profile lookup while browsing isn't one of the
// allowed live-query cases.
final mechanicByIdProvider =
    FutureProvider.family<MechanicModel?, String>((ref, uid) async {
  final doc =
      await FirebaseFirestore.instance.collection('mechanics').doc(uid).get();
  return doc.exists ? MechanicModel.fromFirestore(doc) : null;
});

// One-time fetch of a mechanic's (or car owner's) name and photo from the
// users/ collection. Not real-time — see mechanicByIdProvider above.
final mechanicUserProvider =
    FutureProvider.family<MechanicUser?, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!doc.exists) return null;
  final data = doc.data()!;
  return MechanicUser(
    firstName: data['firstName'] as String? ?? '',
    lastName: data['lastName'] as String? ?? '',
    profilePhoto: data['profilePhoto'] as String?,
  );
});

class MechanicUser {
  final String firstName;
  final String lastName;
  final String? profilePhoto;

  const MechanicUser({
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
  });
}
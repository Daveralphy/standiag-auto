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

// Stream a single mechanic by UID from mechanics/ collection.
final mechanicByIdProvider =
    StreamProvider.family<MechanicModel?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('mechanics')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? MechanicModel.fromFirestore(doc) : null);
});

// Stream a mechanic's name and photo from the users/ collection.
final mechanicUserProvider =
    StreamProvider.family<MechanicUser?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return MechanicUser(
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      profilePhoto: data['profilePhoto'] as String?,
    );
  });
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
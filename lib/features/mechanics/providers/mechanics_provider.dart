import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../features/auth/models/mechanic_model.dart';

// Fetch all visible mechanics once from Firestore mechanics/ collection.
final mechanicsProvider = FutureProvider<List<MechanicModel>>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection('mechanics')
      .where('isVisible', isEqualTo: true)
      .get();
  return snap.docs.map((doc) => MechanicModel.fromFirestore(doc)).toList();
});

/// A mechanic paired with its real distance from the device's current
/// location, in kilometres — null when location isn't available or the
/// mechanic has no stored location, so callers can show "— km" honestly
/// instead of a fabricated number.
class NearbyMechanic {
  final MechanicModel mechanic;
  final double? distanceKm;
  const NearbyMechanic({required this.mechanic, this.distanceKm});
}

/// Same visible-mechanics list as [mechanicsProvider], but sorted
/// nearest-first using the device's real location, with each entry's real
/// distance attached. Used wherever mechanics are shown as a personalized
/// "nearby" list (Home preview, Mechanics tab) rather than a neutral
/// directory. Falls back to the unsorted list (with null distances) if
/// location permission isn't granted — never fabricates a position.
final nearbyMechanicsProvider =
    FutureProvider<List<NearbyMechanic>>((ref) async {
  final mechanics = await ref.watch(mechanicsProvider.future);

  double? originLat;
  double? originLng;
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      final position = await Geolocator.getCurrentPosition();
      originLat = position.latitude;
      originLng = position.longitude;
    }
  } catch (_) {
    // Location unavailable — return the unsorted list below.
  }

  if (originLat == null || originLng == null) {
    return mechanics
        .map((m) => NearbyMechanic(mechanic: m))
        .toList(growable: false);
  }

  final withDistance = mechanics.map((m) {
    final distanceKm = m.location == null
        ? null
        : Geolocator.distanceBetween(
                originLat!, originLng!, m.location!.latitude, m.location!.longitude) /
            1000;
    return NearbyMechanic(mechanic: m, distanceKm: distanceKm);
  }).toList()
    ..sort((a, b) {
      if (a.distanceKm == null && b.distanceKm == null) return 0;
      if (a.distanceKm == null) return 1;
      if (b.distanceKm == null) return -1;
      return a.distanceKm!.compareTo(b.distanceKm!);
    });

  return withDistance;
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
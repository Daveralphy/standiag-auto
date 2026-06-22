// Shared user profile provider for StanDiag Auto.
// Fetches and caches the authenticated user's full profile from Firestore.
// Every screen that needs user data watches this provider.
// Hive cache prevents redundant Firestore reads on navigation.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/cache_keys.dart';
import '../../core/cache/cache_manager.dart';
import '../../core/errors/error_handler.dart';
import 'auth_provider.dart';

// Represents the two user types in the app.
enum UserType { carOwner, mechanic }

// The full profile of the authenticated user.
// Shared across both CarOwner and Mechanic flows.
class UserProfile {
  final String uid;
  final UserType type;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String address;
  final String? profilePhotoUrl;
  final int credits;
  final bool isFirstTime;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.type,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    this.profilePhotoUrl,
    required this.credits,
    required this.isFirstTime,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      type: map['type'] == 'mechanic' ? UserType.mechanic : UserType.carOwner,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      profilePhotoUrl: map['profilePhoto'] as String?,
      credits: (map['credits'] as num?)?.toInt() ?? 0,
      isFirstTime: map['isFirstTime'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'type': type == UserType.mechanic ? 'mechanic' : 'car_owner',
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'profilePhoto': profilePhotoUrl,
      'credits': credits,
      'isFirstTime': isFirstTime,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Fetches the current user's profile.
// Checks Hive cache first. If cache is valid, returns immediately without
// hitting Firestore — this is why navigating between screens feels instant.
// Re-fetches when the cache TTL expires or the user explicitly refreshes.
final userProfileProvider =
    FutureProvider.autoDispose<UserProfile?>((ref) async {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;

  final CacheManager cache = CacheManager.instance;

  // Return cached profile if it is still fresh
  if (!cache.isExpired(
    box: CacheKeys.userBox,
    key: CacheKeys.currentUser,
    ttl: CacheTTL.currentUser,
  )) {
    final UserProfile? cached = cache.read<UserProfile>(
      box: CacheKeys.userBox,
      key: CacheKeys.currentUser,
      fromJson: (json) =>
          UserProfile.fromMap(Map<String, dynamic>.from(json as Map)),
    );
    if (cached != null) return cached;
  }

  // Cache is stale or empty — fetch fresh from Firestore
  try {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    final UserProfile profile =
        UserProfile.fromMap(doc.data() as Map<String, dynamic>);

    // Write to cache so next navigation is instant
    await cache.write(
      box: CacheKeys.userBox,
      key: CacheKeys.currentUser,
      value: profile.toMap(),
    );

    return profile;
  } catch (e, stack) {
    // Log the error — provider returns null so UI handles gracefully
    ErrorHandler.handle(e, stack, userId: uid, screen: 'userProfileProvider');
    return null;
  }
});

// The current user's type.
// Derived from userProfileProvider — no extra Firestore call needed.
final userTypeProvider = Provider.autoDispose<UserType?>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.type;
});

// Whether the current user is a mechanic.
final isMechanicProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(userTypeProvider) == UserType.mechanic;
});

// The current user's credit balance.
// Derived from userProfileProvider for instant reads.
final creditsBalanceProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.credits ?? 0;
});
// User model — represents both CarOwner and Mechanic base data from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { carOwner, mechanic }

class UserModel {
  final String uid;
  final UserType type;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String address;
  final String? profilePhoto;
  final int credits;
  final DateTime createdAt;
  final bool isFirstTime;

  const UserModel({
    required this.uid,
    required this.type,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    this.profilePhoto,
    required this.credits,
    required this.createdAt,
    required this.isFirstTime,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      type: data['type'] == 'mechanic' ? UserType.mechanic : UserType.carOwner,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      profilePhoto: data['profilePhoto'],
      credits: data['credits'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFirstTime: data['isFirstTime'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'type': type == UserType.mechanic ? 'mechanic' : 'car_owner',
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
      'credits': credits,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFirstTime': isFirstTime,
    };
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? address,
    String? profilePhoto,
    int? credits,
    bool? isFirstTime,
  }) {
    return UserModel(
      uid: uid,
      type: type,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      credits: credits ?? this.credits,
      createdAt: createdAt,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}
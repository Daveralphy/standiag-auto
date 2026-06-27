// Mechanic model — extra Firestore data for mechanics beyond the base UserModel.

import 'package:cloud_firestore/cloud_firestore.dart';

class MechanicModel {
  final String uid;
  final String workshopAddress;
  final List<String> expertise;
  final int yearsOfExperience;
  final double rating;
  final int totalJobs;
  final int credits;
  final bool isVisible;
  final GeoPoint? location;

  const MechanicModel({
    required this.uid,
    required this.workshopAddress,
    required this.expertise,
    required this.yearsOfExperience,
    required this.rating,
    required this.totalJobs,
    required this.credits,
    required this.isVisible,
    this.location,
  });

  factory MechanicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MechanicModel(
      uid: doc.id,
      workshopAddress: data['workshopAddress'] ?? '',
      expertise: List<String>.from(data['expertise'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalJobs: data['totalJobs'] ?? 0,
      credits: data['credits'] ?? 0,
      isVisible: data['isVisible'] ?? false,
      location: data['location'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'workshopAddress': workshopAddress,
      'expertise': expertise,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'totalJobs': totalJobs,
      'credits': credits,
      'isVisible': isVisible,
      if (location != null) 'location': location,
    };
  }

  MechanicModel copyWith({
    String? workshopAddress,
    List<String>? expertise,
    int? yearsOfExperience,
    double? rating,
    int? totalJobs,
    int? credits,
    bool? isVisible,
    GeoPoint? location,
  }) {
    return MechanicModel(
      uid: uid,
      workshopAddress: workshopAddress ?? this.workshopAddress,
      expertise: expertise ?? this.expertise,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      credits: credits ?? this.credits,
      isVisible: isVisible ?? this.isVisible,
      location: location ?? this.location,
    );
  }
}
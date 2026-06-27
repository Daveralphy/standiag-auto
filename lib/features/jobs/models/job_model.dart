// Job model — represents a service job between a car owner and a mechanic.

import 'package:cloud_firestore/cloud_firestore.dart';

enum JobStatus {
  pending,
  accepted,
  enRoute,
  arrived,
  inProgress,
  completed,
  rejected,
}

extension JobStatusExtension on JobStatus {
  String get value {
    switch (this) {
      case JobStatus.pending: return 'pending';
      case JobStatus.accepted: return 'accepted';
      case JobStatus.enRoute: return 'en_route';
      case JobStatus.arrived: return 'arrived';
      case JobStatus.inProgress: return 'in_progress';
      case JobStatus.completed: return 'completed';
      case JobStatus.rejected: return 'rejected';
    }
  }

  static JobStatus fromString(String value) {
    switch (value) {
      case 'accepted': return JobStatus.accepted;
      case 'en_route': return JobStatus.enRoute;
      case 'arrived': return JobStatus.arrived;
      case 'in_progress': return JobStatus.inProgress;
      case 'completed': return JobStatus.completed;
      case 'rejected': return JobStatus.rejected;
      default: return JobStatus.pending;
    }
  }
}

class JobModel {
  final String id;
  final String carOwnerId;
  final String mechanicId;
  final String vehicleId;
  final String issue;
  final JobStatus status;
  final GeoPoint? carOwnerLocation;
  final GeoPoint? mechanicLocation;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final double? rating;
  final String? ratingComment;

  const JobModel({
    required this.id,
    required this.carOwnerId,
    required this.mechanicId,
    required this.vehicleId,
    required this.issue,
    required this.status,
    this.carOwnerLocation,
    this.mechanicLocation,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.rating,
    this.ratingComment,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      carOwnerId: data['carOwnerId'] ?? '',
      mechanicId: data['mechanicId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      issue: data['issue'] ?? '',
      status: JobStatusExtension.fromString(data['status'] ?? 'pending'),
      carOwnerLocation: data['carOwnerLocation'] as GeoPoint?,
      mechanicLocation: data['mechanicLocation'] as GeoPoint?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      rating: (data['rating'] as num?)?.toDouble(),
      ratingComment: data['ratingComment'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'carOwnerId': carOwnerId,
      'mechanicId': mechanicId,
      'vehicleId': vehicleId,
      'issue': issue,
      'status': status.value,
      if (carOwnerLocation != null) 'carOwnerLocation': carOwnerLocation,
      if (mechanicLocation != null) 'mechanicLocation': mechanicLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      if (acceptedAt != null) 'acceptedAt': Timestamp.fromDate(acceptedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (rating != null) 'rating': rating,
      if (ratingComment != null) 'ratingComment': ratingComment,
    };
  }

  JobModel copyWith({JobStatus? status, double? rating, String? ratingComment,
      DateTime? acceptedAt, DateTime? completedAt, GeoPoint? mechanicLocation}) {
    return JobModel(
      id: id,
      carOwnerId: carOwnerId,
      mechanicId: mechanicId,
      vehicleId: vehicleId,
      issue: issue,
      status: status ?? this.status,
      carOwnerLocation: carOwnerLocation,
      mechanicLocation: mechanicLocation ?? this.mechanicLocation,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
    );
  }
}
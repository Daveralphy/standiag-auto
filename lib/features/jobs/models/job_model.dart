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
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? rating;
  final String? ratingComment;

  /// When the mechanic tapped Accept on the incoming-call screen — distinct
  /// from [acceptedAt], which marks the JOB being accepted (a separate,
  /// later decision made on the post-call screen). The car owner's outgoing
  /// call screen watches this to know when to stop ringing and join the
  /// actual voice channel.
  final DateTime? callAnsweredAt;

  /// When the car owner acknowledged this job's completion — by rating the
  /// mechanic or explicitly skipping. Distinct from [completedAt] (set by
  /// the *mechanic* marking the work done): without this, a completed job
  /// would stay flagged as this owner's "active job" forever, since nothing
  /// else ever moves it out of the completed status.
  final DateTime? reviewedAt;

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
    this.startedAt,
    this.completedAt,
    this.rating,
    this.ratingComment,
    this.callAnsweredAt,
    this.reviewedAt,
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
      carOwnerLocation:
          data['carOwnerLocation'] is GeoPoint ? data['carOwnerLocation'] : null,
      mechanicLocation:
          data['mechanicLocation'] is GeoPoint ? data['mechanicLocation'] : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      acceptedAt: data['acceptedAt'] is Timestamp
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
          startedAt: data['startedAt'] is Timestamp
            ? (data['startedAt'] as Timestamp).toDate()
            : null,
      completedAt: data['completedAt'] is Timestamp
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      rating: (data['rating'] as num?)?.toDouble(),
      ratingComment: data['ratingComment'],
      callAnsweredAt: data['callAnsweredAt'] is Timestamp
          ? (data['callAnsweredAt'] as Timestamp).toDate()
          : null,
      reviewedAt: data['reviewedAt'] is Timestamp
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
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
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (rating != null) 'rating': rating,
      if (ratingComment != null) 'ratingComment': ratingComment,
      if (callAnsweredAt != null)
        'callAnsweredAt': Timestamp.fromDate(callAnsweredAt!),
      if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
    };
  }

  JobModel copyWith({JobStatus? status, double? rating, String? ratingComment,
      DateTime? acceptedAt, DateTime? startedAt, DateTime? completedAt,
      GeoPoint? mechanicLocation,
      DateTime? callAnsweredAt, DateTime? reviewedAt}) {
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
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
      callAnsweredAt: callAnsweredAt ?? this.callAnsweredAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
// Service Request model — a car owner's open "find a mechanic" broadcast.
// Created once when they tap Find Nearby Mechanics; any number of nearby
// mechanics can then respond to it with a quote (see quote_model.dart).

import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceRequestStatus { open, matched, cancelled }

extension ServiceRequestStatusExtension on ServiceRequestStatus {
  String get value {
    switch (this) {
      case ServiceRequestStatus.open:
        return 'open';
      case ServiceRequestStatus.matched:
        return 'matched';
      case ServiceRequestStatus.cancelled:
        return 'cancelled';
    }
  }

  static ServiceRequestStatus fromString(String value) {
    switch (value) {
      case 'matched':
        return ServiceRequestStatus.matched;
      case 'cancelled':
        return ServiceRequestStatus.cancelled;
      default:
        return ServiceRequestStatus.open;
    }
  }
}

class ServiceRequestModel {
  final String id;
  final String carOwnerId;
  final GeoPoint? carOwnerLocation;
  final String issue;
  final String vehicleId;

  /// The radius nearby mechanics are alerted within — set once when the
  /// request is created, not user-adjustable afterward.
  final double radiusKm;

  final ServiceRequestStatus status;

  /// Set once a quote is accepted and the real job is created.
  final String? jobId;

  final DateTime createdAt;

  const ServiceRequestModel({
    required this.id,
    required this.carOwnerId,
    this.carOwnerLocation,
    required this.issue,
    required this.vehicleId,
    required this.radiusKm,
    required this.status,
    this.jobId,
    required this.createdAt,
  });

  factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceRequestModel(
      id: doc.id,
      carOwnerId: data['carOwnerId'] ?? '',
      carOwnerLocation:
          data['carOwnerLocation'] is GeoPoint ? data['carOwnerLocation'] : null,
      issue: data['issue'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      radiusKm: (data['radiusKm'] as num?)?.toDouble() ?? 15.0,
      status:
          ServiceRequestStatusExtension.fromString(data['status'] ?? 'open'),
      jobId: data['jobId'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'carOwnerId': carOwnerId,
      if (carOwnerLocation != null) 'carOwnerLocation': carOwnerLocation,
      'issue': issue,
      'vehicleId': vehicleId,
      'radiusKm': radiusKm,
      'status': status.value,
      if (jobId != null) 'jobId': jobId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

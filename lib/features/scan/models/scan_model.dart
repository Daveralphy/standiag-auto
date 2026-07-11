// Scan model — an OBD diagnostic scan result.

import 'package:cloud_firestore/cloud_firestore.dart';

class ScanModel {
  final String id;
  final String ownerId;
  final String vehicleId;
  final int healthScore;
  final Map<String, dynamic> rawData;
  final DateTime createdAt;

  const ScanModel({
    required this.id,
    required this.ownerId,
    required this.vehicleId,
    required this.healthScore,
    required this.rawData,
    required this.createdAt,
  });

  String get healthLabel {
    if (healthScore >= 8) return 'Excellent';
    if (healthScore >= 5) return 'Fair';
    return 'Poor';
  }

  factory ScanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScanModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      healthScore: data['healthScore'] ?? 0,
      rawData: Map<String, dynamic>.from(data['rawData'] ?? {}),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'vehicleId': vehicleId,
      'healthScore': healthScore,
      'rawData': rawData,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
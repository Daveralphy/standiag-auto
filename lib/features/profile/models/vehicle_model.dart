// Vehicle model — a car registered by a CarOwner.

import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String ownerId;
  final String make;
  final String model;
  final String year;
  final String type;
  final String colour;
  final String plateNumber;
  final String fuelType;

  const VehicleModel({
    required this.id,
    required this.ownerId,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.colour,
    required this.plateNumber,
    required this.fuelType,
  });

  String get displayName => '$year $make $model';

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? '',
      type: data['type'] ?? '',
      colour: data['colour'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      fuelType: data['fuelType'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'make': make,
      'model': model,
      'year': year,
      'type': type,
      'colour': colour,
      'plateNumber': plateNumber,
      'fuelType': fuelType,
    };
  }
}
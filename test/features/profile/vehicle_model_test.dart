import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/features/profile/models/vehicle_model.dart';

void main() {
  test('VehicleModel exposes displayName and Firestore payload', () {
    const vehicle = VehicleModel(
      id: 'vehicle-1',
      ownerId: 'owner-1',
      make: 'Toyota',
      model: 'Corolla',
      year: '2019',
      type: 'Sedan',
      colour: 'Black',
      plateNumber: 'ABC-123-XY',
      fuelType: 'Petrol',
    );

    expect(vehicle.displayName, '2019 Toyota Corolla');
    expect(vehicle.toFirestore(), containsPair('ownerId', 'owner-1'));
    expect(vehicle.toFirestore(), containsPair('plateNumber', 'ABC-123-XY'));
  });
}

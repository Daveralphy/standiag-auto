import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:standiag_auto/shared/widget/app_map.dart';

void main() {
  test('latLngFromGeoPoint passes through LatLng values', () {
    const location = LatLng(6.5, 3.3);

    expect(latLngFromGeoPoint(location), location);
  });

  test('latLngFromGeoPoint converts coordinate maps', () {
    final location = latLngFromGeoPoint({
      'latitude': 6.5,
      'longitude': 3.3,
    });

    expect(location.latitude, 6.5);
    expect(location.longitude, 3.3);
  });
}

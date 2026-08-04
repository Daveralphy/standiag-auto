// Reference data for the "describe the problem" field on a service request.
// A static list of common car complaints, same role as VehicleReferenceData
// for make/model — a suggestion source, not a fixed vocabulary. The field
// stays freely typeable either way.

class CommonIssuesData {
  CommonIssuesData._();

  static const List<String> issues = [
    "Car won't start",
    'Battery is dead',
    'Engine overheating',
    'Check engine light is on',
    'Strange noise when braking',
    'Strange noise from engine',
    'Grinding noise when turning',
    'Flat tire',
    'Slow leak in tire',
    'AC not cooling',
    'Oil leak',
    'Coolant leak',
    "Won't shift gears",
    'Transmission slipping',
    'Battery light on dashboard',
    'Car shaking while driving',
    'Car pulling to one side',
    'Brake pads worn',
    'Brakes feel soft',
    'Exhaust smoke',
    'Fuel smell',
    'Headlight not working',
    'Windshield wiper not working',
    'Car won\'t hold charge',
    'Steering feels stiff',
    'Vibration at high speed',
    'Rattling noise underneath',
    'Warning light on dashboard',
  ];

  /// Case-insensitive, contains-match search over the known issue phrases.
  /// Empty query returns every known issue.
  static List<String> filter(String query) {
    if (query.trim().isEmpty) return issues;
    final q = query.trim().toLowerCase();
    return issues.where((issue) => issue.toLowerCase().contains(q)).toList();
  }
}

// Reference data for the Add/Edit Vehicle make & model suggestions.
// This is a static lookup table of real car brands/models (like a country or
// currency list), not fabricated user-facing content — the user can still
// type any value freely; suggestions are just an assist for common cases.

class VehicleReferenceData {
  VehicleReferenceData._();

  static const Map<String, List<String>> makesAndModels = {
    'Toyota': ['Corolla', 'Camry', 'RAV4', 'Hilux', 'Land Cruiser', 'Yaris',
        'Highlander', 'Prius', 'Avensis', 'Fortuner'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'HR-V', 'Fit', 'City'],
    'Ford': ['Focus', 'Fiesta', 'Escape', 'Explorer', 'F-150', 'Mustang',
        'EcoSport', 'Edge'],
    'Chevrolet': ['Cruze', 'Malibu', 'Equinox', 'Tahoe', 'Spark', 'Camaro'],
    'Nissan': ['Altima', 'Sentra', 'Rogue', 'X-Trail', 'Micra', 'Patrol',
        'Navara', 'Qashqai'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Accent', 'i10',
        'Creta', 'i20'],
    'Kia': ['Rio', 'Optima', 'Sportage', 'Sorento', 'Picanto', 'Cerato',
        'Seltos'],
    'Volkswagen': ['Golf', 'Passat', 'Jetta', 'Tiguan', 'Polo', 'Touareg'],
    'BMW': ['3 Series', '5 Series', 'X1', 'X3', 'X5', '7 Series'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLA', 'GLC', 'GLE'],
    'Audi': ['A3', 'A4', 'A6', 'Q3', 'Q5', 'Q7'],
    'Mazda': ['Mazda3', 'Mazda6', 'CX-5', 'CX-3', 'CX-9'],
    'Lexus': ['ES', 'IS', 'RX', 'NX', 'GX'],
    'Peugeot': ['208', '308', '3008', '5008', '2008'],
    'Renault': ['Duster', 'Clio', 'Megane', 'Sandero', 'Logan'],
    'Mitsubishi': ['Lancer', 'Outlander', 'Pajero', 'ASX', 'L200'],
    'Suzuki': ['Swift', 'Vitara', 'Baleno', 'Jimny', 'Alto'],
    'Jeep': ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass'],
    'Land Rover': ['Range Rover', 'Discovery', 'Defender', 'Evoque'],
    'Volvo': ['XC40', 'XC60', 'XC90', 'S60', 'S90'],
    'Subaru': ['Impreza', 'Forester', 'Outback', 'XV'],
    'Mini': ['Cooper', 'Countryman', 'Clubman'],
    'Fiat': ['500', 'Panda', 'Tipo'],
    'Skoda': ['Octavia', 'Fabia', 'Superb', 'Kodiaq'],
    'Infiniti': ['Q50', 'QX60', 'QX80'],
    'Isuzu': ['D-Max', 'MU-X'],
    'Mercedes': ['Sprinter', 'Vito'],
  };

  /// Case-insensitive, contains-match search over the known make names.
  /// Empty query returns every known make.
  static List<String> makes(String query) {
    final all = makesAndModels.keys.toList();
    if (query.trim().isEmpty) return all;
    final q = query.trim().toLowerCase();
    return all.where((m) => m.toLowerCase().contains(q)).toList();
  }

  /// Case-insensitive, contains-match search over the models known for
  /// [make]. Returns an empty list for an unrecognised make — the field
  /// stays freely editable either way, this is only a suggestion source.
  static List<String> modelsFor(String make, String query) {
    final key = makesAndModels.keys.firstWhere(
      (k) => k.toLowerCase() == make.trim().toLowerCase(),
      orElse: () => '',
    );
    final models = makesAndModels[key] ?? const <String>[];
    if (query.trim().isEmpty) return models;
    final q = query.trim().toLowerCase();
    return models.where((m) => m.toLowerCase().contains(q)).toList();
  }
}

class MechanicModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final List<String> specialisations;
  final int experienceYears;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final double? distanceKm;

  const MechanicModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.specialisations,
    required this.experienceYears,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
    this.distanceKm,
  });

  factory MechanicModel.fromMap(Map<String, dynamic> m) => MechanicModel(
        id: m['id'] as String,
        firstName: m['profiles']?['first_name'] as String? ?? '',
        lastName: m['profiles']?['last_name'] as String? ?? '',
        avatarUrl: m['profiles']?['avatar_url'] as String?,
        specialisations: List<String>.from(m['specialisations'] ?? []),
        experienceYears: m['experience_years'] as int? ?? 0,
        address: m['address'] as String?,
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        phone: m['phone'] as String?,
        isVerified: m['is_verified'] as bool? ?? false,
        rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: m['review_count'] as int? ?? 0,
        distanceKm: (m['distance_km'] as num?)?.toDouble(),
      );

  String get fullName => '$firstName $lastName'.trim();
  String get specsPreview => specialisations.take(2).join(' · ');
}
// Mechanic Search model — combines UserModel + MechanicModel + distance
// for display in the mechanics search results list and map.

class MechanicSearchModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? profilePhoto;
  final String workshopAddress;
  final List<String> expertise;
  final double rating;
  final int totalJobs;
  final int yearsOfExperience;
  final bool isVisible;
  final double? distanceKm;

  const MechanicSearchModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
    required this.workshopAddress,
    required this.expertise,
    required this.rating,
    required this.totalJobs,
    required this.yearsOfExperience,
    required this.isVisible,
    this.distanceKm,
  });

  String get fullName => '$firstName $lastName';

  String get distanceLabel {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }
}
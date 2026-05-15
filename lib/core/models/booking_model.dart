class BookingModel {
  final String id;
  final String userId;
  final String mechanicId;
  final String? vehicleId;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  // Joined fields
  final String? userName;
  final String? userAvatarUrl;
  final String? vehicleSummary;
  final String? mechanicName;
  final double? distanceKm;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.mechanicId,
    this.vehicleId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.userName,
    this.userAvatarUrl,
    this.vehicleSummary,
    this.mechanicName,
    this.distanceKm,
  });

  factory BookingModel.fromMap(Map<String, dynamic> m) => BookingModel(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        mechanicId: m['mechanic_id'] as String,
        vehicleId: m['vehicle_id'] as String?,
        status: m['status'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        acceptedAt: m['accepted_at'] != null
            ? DateTime.parse(m['accepted_at'] as String)
            : null,
        completedAt: m['completed_at'] != null
            ? DateTime.parse(m['completed_at'] as String)
            : null,
        userName: m['user']?['first_name'] != null
            ? '${m['user']['first_name']} ${m['user']['last_name']}'
            : null,
        userAvatarUrl: m['user']?['avatar_url'] as String?,
        vehicleSummary: m['vehicle'] != null
            ? '${m['vehicle']['make']} ${m['vehicle']['model']} ${m['vehicle']['year']}'
            : null,
        mechanicName: m['mechanic']?['first_name'] != null
            ? '${m['mechanic']['first_name']} ${m['mechanic']['last_name']}'
            : null,
      );

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
}
class VehicleModel {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String engineType;
  final String? nickname;
  final bool isActive;
  final DateTime createdAt;

  const VehicleModel({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.engineType,
    this.nickname,
    required this.isActive,
    required this.createdAt,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> m) => VehicleModel(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        make: m['make'] as String,
        model: m['model'] as String,
        year: m['year'] as int,
        engineType: m['engine_type'] as String,
        nickname: m['nickname'] as String?,
        isActive: m['is_active'] as bool,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  String get displayName =>
      nickname?.isNotEmpty == true ? nickname! : '$make $model';
}
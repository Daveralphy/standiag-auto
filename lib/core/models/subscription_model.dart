class SubscriptionModel {
  final String id;
  final String mechanicId;
  final String planType;
  final int? slotsLimit;
  final int slotsUsed;
  final int amount;
  final String status;
  final DateTime startedAt;
  final DateTime expiresAt;

  const SubscriptionModel({
    required this.id,
    required this.mechanicId,
    required this.planType,
    this.slotsLimit,
    required this.slotsUsed,
    required this.amount,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> m) =>
      SubscriptionModel(
        id: m['id'] as String,
        mechanicId: m['mechanic_id'] as String,
        planType: m['plan_type'] as String,
        slotsLimit: m['slots_limit'] as int?,
        slotsUsed: m['slots_used'] as int? ?? 0,
        amount: m['amount'] as int? ?? 0,
        status: m['status'] as String,
        startedAt: DateTime.parse(m['started_at'] as String),
        expiresAt: DateTime.parse(m['expires_at'] as String),
      );

  bool get isActive => status == 'active';
  bool get isUnlimited => slotsLimit == null;
  int get slotsRemaining =>
      isUnlimited ? 999 : (slotsLimit! - slotsUsed).clamp(0, slotsLimit!);
  double get usagePercent =>
      isUnlimited ? 0 : slotsUsed / (slotsLimit ?? 1);

  String get planName {
    switch (planType) {
      case 'standard': return 'Standard';
      case 'pro': return 'Pro';
      case 'unlimited': return 'Unlimited';
      default: return planType;
    }
  }

  String get planAmount {
    switch (planType) {
      case 'standard': return '₦5,000';
      case 'pro': return '₦15,000';
      case 'unlimited': return '₦30,000';
      default: return '';
    }
  }
}
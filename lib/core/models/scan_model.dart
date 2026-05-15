class ScanModel {
  final String id;
  final String userId;
  final String? vehicleId;
  final List<String> dtcCodes;
  final String? aiSummary;
  final String severity;
  final DateTime scannedAt;

  const ScanModel({
    required this.id,
    required this.userId,
    this.vehicleId,
    required this.dtcCodes,
    this.aiSummary,
    required this.severity,
    required this.scannedAt,
  });

  factory ScanModel.fromMap(Map<String, dynamic> m) => ScanModel(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        vehicleId: m['vehicle_id'] as String?,
        dtcCodes: List<String>.from(m['dtc_codes'] ?? []),
        aiSummary: m['ai_summary'] as String?,
        severity: m['severity'] as String? ?? 'clear',
        scannedAt: DateTime.parse(m['scanned_at'] as String),
      );

  bool get isClear => severity == 'clear';
  bool get isWarning => severity == 'warning';
  bool get isCritical => severity == 'critical';
}
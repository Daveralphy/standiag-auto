// Settings model — local app preferences stored in Hive.

class SettingsModel {
  final String language;
  final String theme;
  final double textSize;
  final bool notifyJobUpdates;
  final bool notifyPromotions;
  final bool notifyNewMechanics;
  final bool shareLocation;
  final bool shareAnalytics;

  const SettingsModel({
    this.language = 'English',
    this.theme = 'Dark',
    this.textSize = 2.0,
    this.notifyJobUpdates = true,
    this.notifyPromotions = false,
    this.notifyNewMechanics = true,
    this.shareLocation = true,
    this.shareAnalytics = false,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      language: map['language'] ?? 'English',
      theme: map['theme'] ?? 'Dark',
      textSize: (map['textSize'] ?? 2.0).toDouble(),
      notifyJobUpdates: map['notifyJobUpdates'] ?? true,
      notifyPromotions: map['notifyPromotions'] ?? false,
      notifyNewMechanics: map['notifyNewMechanics'] ?? true,
      shareLocation: map['shareLocation'] ?? true,
      shareAnalytics: map['shareAnalytics'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'theme': theme,
      'textSize': textSize,
      'notifyJobUpdates': notifyJobUpdates,
      'notifyPromotions': notifyPromotions,
      'notifyNewMechanics': notifyNewMechanics,
      'shareLocation': shareLocation,
      'shareAnalytics': shareAnalytics,
    };
  }

  SettingsModel copyWith({
    String? language,
    String? theme,
    double? textSize,
    bool? notifyJobUpdates,
    bool? notifyPromotions,
    bool? notifyNewMechanics,
    bool? shareLocation,
    bool? shareAnalytics,
  }) {
    return SettingsModel(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      textSize: textSize ?? this.textSize,
      notifyJobUpdates: notifyJobUpdates ?? this.notifyJobUpdates,
      notifyPromotions: notifyPromotions ?? this.notifyPromotions,
      notifyNewMechanics: notifyNewMechanics ?? this.notifyNewMechanics,
      shareLocation: shareLocation ?? this.shareLocation,
      shareAnalytics: shareAnalytics ?? this.shareAnalytics,
    );
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/features/settings/models/settings_model.dart';

void main() {
  test('SettingsModel round-trips through map storage', () {
    const model = SettingsModel(
      language: 'French',
      theme: 'Light',
      textSize: 4,
      notifyJobUpdates: false,
      notifyPromotions: true,
      notifyNewMechanics: false,
      shareLocation: false,
      shareAnalytics: true,
    );

    final roundTripped = SettingsModel.fromMap(model.toMap());

    expect(roundTripped.language, model.language);
    expect(roundTripped.theme, model.theme);
    expect(roundTripped.textSize, model.textSize);
    expect(roundTripped.notifyJobUpdates, model.notifyJobUpdates);
    expect(roundTripped.notifyPromotions, model.notifyPromotions);
    expect(roundTripped.notifyNewMechanics, model.notifyNewMechanics);
    expect(roundTripped.shareLocation, model.shareLocation);
    expect(roundTripped.shareAnalytics, model.shareAnalytics);
  });
}

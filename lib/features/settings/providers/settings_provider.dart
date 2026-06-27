// Settings provider — owns app preferences stored persistently in Hive.
// Changes take effect immediately and persist across app restarts.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../models/settings_model.dart';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(const SettingsModel()) {
    _load();
  }

  Future<void> _load() async {
    final raw = CacheManager.instance.read<Map<String, dynamic>>(
      box: CacheKeys.settingsBox,
      key: CacheKeys.settings,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (raw != null) {
      state = SettingsModel.fromMap(raw);
    }
  }

  Future<void> _save() async {
    await CacheManager.instance.write(
      box: CacheKeys.settingsBox,
      key: CacheKeys.settings,
      value: state.toMap());
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    await _save();
  }

  Future<void> setTheme(String theme) async {
    state = state.copyWith(theme: theme);
    await _save();
  }

  Future<void> setTextSize(double size) async {
    state = state.copyWith(textSize: size);
    await _save();
  }

  Future<void> setNotifyJobUpdates(bool val) async {
    state = state.copyWith(notifyJobUpdates: val);
    await _save();
  }

  Future<void> setNotifyPromotions(bool val) async {
    state = state.copyWith(notifyPromotions: val);
    await _save();
  }

  Future<void> setNotifyNewMechanics(bool val) async {
    state = state.copyWith(notifyNewMechanics: val);
    await _save();
  }

  Future<void> setShareLocation(bool val) async {
    state = state.copyWith(shareLocation: val);
    await _save();
  }

  Future<void> setShareAnalytics(bool val) async {
    state = state.copyWith(shareAnalytics: val);
    await _save();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>(
        (ref) => SettingsNotifier());
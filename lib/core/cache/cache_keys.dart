// Defines every Hive cache key and TTL (time-to-live) used in StanDiag Auto.
// All local persistent cache reads and writes use these keys.
// Never write a cache key string anywhere else in the codebase.

class CacheKeys {
  // Private constructor — this class is never instantiated.
  CacheKeys._();

  // ─── Hive Box Names ────────────────────────────────────────────────────────
  // Each box groups related cached data. Open only the boxes you need.

  /// Box for user profile and session data.
  static const String userBox = 'user_box';

  /// Box for mechanic profile data.
  static const String mechanicBox = 'mechanic_box';

  /// Box for vehicle list data.
  static const String vehiclesBox = 'vehicles_box';

  /// Box for scan history data.
  static const String scansBox = 'scans_box';

  /// Box for credits balance and transaction history.
  static const String creditsBox = 'credits_box';

  /// Box for app settings and preferences.
  static const String settingsBox = 'settings_box';

  // ─── Cache Keys ────────────────────────────────────────────────────────────

  /// The authenticated user's full profile document.
  static const String currentUser = 'current_user';

  /// The authenticated user's type: 'car_owner' or 'mechanic'.
  static const String userType = 'user_type';

  /// The authenticated user's UID.
  static const String userId = 'user_id';

  /// The mechanic profile document (mechanic users only).
  static const String mechanicProfile = 'mechanic_profile';

  /// The list of vehicles belonging to the current car owner.
  static const String vehicles = 'vehicles';

  /// The list of past OBD scan results for the current user.
  static const String scanHistory = 'scan_history';

  /// The current user's credit balance.
  static const String creditsBalance = 'credits_balance';

  /// The list of recent credit transactions.
  static const String creditsHistory = 'credits_history';

  /// Whether the current user has claimed their welcome credits.
  static const String welcomeCreditsClaimed = 'welcome_credits_claimed';

  /// App language preference.
  static const String language = 'language';

  /// App appearance/theme preference ('dark' or 'light').
  static const String theme = 'theme';

  /// App text size preference (1–5 scale).
  static const String textSize = 'text_size';

  /// Notification preferences map.
  static const String notificationPreferences = 'notification_preferences';

  /// Privacy settings map.
  static const String privacySettings = 'privacy_settings';

  /// Timestamp of when each cache key was last populated.
  /// Used to check TTL without reading the full cached value.
  /// Pattern: '$cacheKey_timestamp' — e.g. 'scan_history_timestamp'.
  /// All settings as a single map (persists full SettingsModel).
  static const String settings = 'settings';

  /// Timestamp of the last home screen data fetch.
  static const String homeLastFetch = 'home_last_fetch';

  static String timestampKey(String key) => '${key}_timestamp';
}

// Defines the time-to-live for each cached data type.
// After a TTL expires, the next read triggers a fresh Firestore fetch.
class CacheTTL {
  // Private constructor — this class is never instantiated.
  CacheTTL._();

  /// User profile — long TTL because profile data rarely changes.
  static const Duration currentUser = Duration(hours: 24);

  /// Mechanic profile — same as user profile.
  static const Duration mechanicProfile = Duration(hours: 24);

  /// Vehicle list — medium TTL since users rarely add/remove vehicles.
  static const Duration vehicles = Duration(hours: 12);

  /// Scan history — refreshed after each new scan automatically.
  static const Duration scanHistory = Duration(hours: 24);

  /// Credits balance — short TTL because balance changes frequently.
  static const Duration creditsBalance = Duration(minutes: 30);

  /// Credits transaction history — refreshed after each transaction automatically.
  static const Duration creditsHistory = Duration(hours: 1);

  /// Settings — very long TTL since settings rarely change.
  static const Duration settings = Duration(days: 7);
}
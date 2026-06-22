// Handles all local persistent cache operations using Hive.
// Every read and write to the local cache goes through this class.
// Providers use this to avoid redundant Firestore calls on navigation.
//
// How it works:
// - Data is stored in Hive boxes as JSON strings.
// - Each entry has a companion timestamp key to track freshness.
// - isExpired() checks if a TTL has passed since the last write.
// - clear() is called on logout to wipe all user-specific data.

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'cache_keys.dart';

class CacheManager {
  // Private constructor — this class is never instantiated directly.
  // Use CacheManager.instance for all operations.
  CacheManager._();

  static final CacheManager instance = CacheManager._();

  // ─── Initialisation ────────────────────────────────────────────────────────

  /// Opens all Hive boxes. Must be called once in main.dart before runApp().
  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(CacheKeys.userBox),
      Hive.openBox(CacheKeys.mechanicBox),
      Hive.openBox(CacheKeys.vehiclesBox),
      Hive.openBox(CacheKeys.scansBox),
      Hive.openBox(CacheKeys.creditsBox),
      Hive.openBox(CacheKeys.settingsBox),
    ]);
  }

  // ─── Write ─────────────────────────────────────────────────────────────────

  /// Writes a value to the specified box under the given key.
  /// Automatically records a timestamp so TTL can be checked later.
  Future<void> write({
    required String box,
    required String key,
    required dynamic value,
  }) async {
    final Box b = Hive.box(box);
    // Store the value as a JSON string for type safety across restarts
    await b.put(key, jsonEncode(value));
    // Record when this was written so we can check TTL later
    await b.put(CacheKeys.timestampKey(key), DateTime.now().toIso8601String());
  }

  // ─── Read ──────────────────────────────────────────────────────────────────

  /// Reads a value from the specified box.
  /// Returns null if the key does not exist.
  T? read<T>({
    required String box,
    required String key,
    required T Function(dynamic json) fromJson,
  }) {
    final Box b = Hive.box(box);
    final dynamic raw = b.get(key);
    if (raw == null) return null;
    try {
      return fromJson(jsonDecode(raw as String));
    } catch (_) {
      // If decoding fails the cached data is corrupt — treat as missing
      return null;
    }
  }

  // ─── TTL Check ─────────────────────────────────────────────────────────────

  /// Returns true if the cached value for [key] in [box] is older than [ttl].
  /// Returns true (expired) if no timestamp exists — forces a fresh fetch.
  bool isExpired({
    required String box,
    required String key,
    required Duration ttl,
  }) {
    final Box b = Hive.box(box);
    final dynamic raw = b.get(CacheKeys.timestampKey(key));
    if (raw == null) return true; // No timestamp means never written — expired

    try {
      final DateTime written = DateTime.parse(raw as String);
      return DateTime.now().difference(written) > ttl;
    } catch (_) {
      return true; // Bad timestamp — treat as expired
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  /// Deletes a single key (and its timestamp) from the specified box.
  Future<void> delete({required String box, required String key}) async {
    final Box b = Hive.box(box);
    await b.delete(key);
    await b.delete(CacheKeys.timestampKey(key));
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────

  /// Clears all user-specific cached data.
  /// Must be called on logout so the next user starts with a clean slate.
  Future<void> clearUserData() async {
    await Future.wait([
      Hive.box(CacheKeys.userBox).clear(),
      Hive.box(CacheKeys.mechanicBox).clear(),
      Hive.box(CacheKeys.vehiclesBox).clear(),
      Hive.box(CacheKeys.scansBox).clear(),
      Hive.box(CacheKeys.creditsBox).clear(),
    ]);
    // Settings are intentionally kept — the user's theme/language should persist
  }

  /// Clears all cached data including settings. Used for full reset.
  Future<void> clearAll() async {
    await Future.wait([
      Hive.box(CacheKeys.userBox).clear(),
      Hive.box(CacheKeys.mechanicBox).clear(),
      Hive.box(CacheKeys.vehiclesBox).clear(),
      Hive.box(CacheKeys.scansBox).clear(),
      Hive.box(CacheKeys.creditsBox).clear(),
      Hive.box(CacheKeys.settingsBox).clear(),
    ]);
  }
}
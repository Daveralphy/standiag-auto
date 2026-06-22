// Dart extension methods used throughout StanDiag Auto.
// Extensions add convenience methods to existing types without subclassing.
// Import this file wherever these helpers are needed.

import 'package:flutter/material.dart';

// ─── String Extensions ─────────────────────────────────────────────────────

extension StringExtensions on String {
  /// Capitalises the first letter of the string.
  /// Example: 'kwame asante' → 'Kwame asante'
  String get capitalised {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalises the first letter of each word.
  /// Example: 'kwame asante' → 'Kwame Asante'
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalised).join(' ');
  }

  /// Returns true if the string is a valid email address.
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Returns true if the string contains only digits.
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// Trims and returns null if the result is empty.
  /// Useful for optional form fields.
  String? get trimmedOrNull {
    final String trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

// ─── BuildContext Extensions ───────────────────────────────────────────────

extension ContextExtensions on BuildContext {
  /// Screen width.
  double get width => MediaQuery.of(this).size.width;

  /// Screen height.
  double get height => MediaQuery.of(this).size.height;

  /// True when the keyboard is visible.
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  /// The current theme.
  ThemeData get theme => Theme.of(this);

  /// Safe area padding insets.
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Bottom safe area height (home indicator on iPhone etc).
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// Top safe area height (status bar).
  double get topPadding => MediaQuery.of(this).padding.top;

  /// Dismisses the keyboard programmatically.
  void dismissKeyboard() => FocusScope.of(this).unfocus();
}

// ─── DateTime Extensions ───────────────────────────────────────────────────

extension DateTimeExtensions on DateTime {
  /// Returns true if this DateTime is today.
  bool get isToday {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this DateTime was yesterday.
  bool get isYesterday {
    final DateTime yesterday =
        DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this DateTime is in the same month and year as [other].
  bool isSameMonthAs(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Returns the start of the day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);
}

// ─── List Extensions ───────────────────────────────────────────────────────

extension ListExtensions<T> on List<T> {
  /// Returns the element at [index] or null if the index is out of bounds.
  /// Avoids RangeError on empty or short lists.
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Returns the first element matching [test] or null if none found.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// ─── Duration Extensions ───────────────────────────────────────────────────

extension DurationExtensions on Duration {
  /// Returns the total number of minutes, rounded down.
  int get inWholeMinutes => inSeconds ~/ 60;
}

// ─── Num Extensions ────────────────────────────────────────────────────────

extension NumExtensions on num {
  /// Clamps this value between [min] and [max].
  num clampTo(num min, num max) => clamp(min, max);
}
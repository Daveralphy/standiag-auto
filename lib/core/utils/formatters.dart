// Utility functions for formatting values displayed in the UI.
// Used for dates, currency, distances, durations, and credit amounts.
// Never format values inline in widget files — always use this class.

import 'package:intl/intl.dart';

class Formatters {
  // Private constructor — this class is never instantiated.
  Formatters._();

  // ─── Currency ──────────────────────────────────────────────────────────────

  /// Formats a Naira amount with the ₦ symbol and comma separators.
  /// Example: 8500 → '₦8,500'
  static String naira(num amount) {
    final NumberFormat formatter = NumberFormat('#,###', 'en_NG');
    return '₦${formatter.format(amount)}';
  }

  // ─── Credits ───────────────────────────────────────────────────────────────

  /// Formats a credit amount with 'cr' suffix.
  /// Example: 100 → '100 cr'
  static String credits(int amount) => '$amount cr';

  /// Formats a credit transaction amount with sign prefix.
  /// Example: debit 5 → '-5 cr', credit 100 → '+100 cr'
  static String creditTransaction({required int amount, required bool isDebit}) {
    return isDebit ? '-$amount cr' : '+$amount cr';
  }

  // ─── Date & Time ───────────────────────────────────────────────────────────

  /// Formats a DateTime as a short date with time.
  /// Example: '29 May · 10:24 AM'
  static String dateWithTime(DateTime date) {
    final String day = DateFormat('d MMM').format(date);
    final String time = DateFormat('h:mm a').format(date);
    return '$day · $time';
  }

  /// Formats a DateTime as a month and year label for transaction grouping.
  /// Example: 'May 2026'
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Formats a DateTime as a short readable date.
  /// Example: '29 May 2026'
  static String shortDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Formats a DateTime as time only.
  /// Example: '10:24 AM'
  static String timeOnly(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Returns a relative time label for recent timestamps.
  /// Example: 'Today · 10:24 AM', 'Yesterday · 3:12 PM', '27 May · 2:05 PM'
  static String relativeDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime inputDay = DateTime(date.year, date.month, date.day);

    final String time = timeOnly(date);
    if (inputDay == today) return 'Today · $time';
    if (inputDay == yesterday) return 'Yesterday · $time';
    return dateWithTime(date);
  }

  // ─── Distance ──────────────────────────────────────────────────────────────

  /// Formats a distance in metres to a readable km string.
  /// Example: 1200 → '1.2 km', 800 → '800 m'
  static String distance(double metres) {
    if (metres >= 1000) {
      final double km = metres / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${metres.round()} m';
  }

  /// Formats a distance in kilometres.
  /// Example: 2.3 → '2.3 km away'
  static String kmAway(double km) => '${km.toStringAsFixed(1)} km away';

  // ─── Duration ──────────────────────────────────────────────────────────────

  /// Formats a duration as a readable ETA string.
  /// Example: 7 minutes → '7 min away', 65 minutes → '1 hr 5 min away'
  static String eta(int minutes) {
    if (minutes < 60) return '$minutes min away';
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    if (mins == 0) return '${hours}hr away';
    return '${hours}hr ${mins}min away';
  }

  /// Formats a call duration in seconds as mm:ss.
  /// Example: 125 → '2:05'
  static String callDuration(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  // ─── OTP Countdown ─────────────────────────────────────────────────────────

  /// Formats a countdown timer in seconds as mm:ss.
  /// Example: 45 → '00:45', 125 → '02:05'
  static String countdown(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ─── Name ──────────────────────────────────────────────────────────────────

  /// Returns a masked email for display — e.g. 'j***@email.com'
  static String maskedEmail(String email) {
    final List<String> parts = email.split('@');
    if (parts.length != 2) return email;
    final String name = parts[0];
    final String domain = parts[1];
    if (name.isEmpty) return email;
    return '${name[0]}***@$domain';
  }

  /// Returns initials from a full name — used for avatar fallbacks.
  /// Example: 'Kwame Asante' → 'KA'
  static String initials(String fullName) {
    final List<String> parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ─── Rating ────────────────────────────────────────────────────────────────

  /// Formats a rating to one decimal place.
  /// Example: 4.9 → '4.9', 5.0 → '5.0'
  static String rating(double value) => value.toStringAsFixed(1);
}
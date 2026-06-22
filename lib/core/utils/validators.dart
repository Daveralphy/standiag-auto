// Form validation functions used across all input fields in StanDiag Auto.
// Every validator returns null when valid, or an error string when invalid.
// These are passed directly to TextFormField's validator parameter.
// All error strings are user-friendly — no technical jargon.

class Validators {
  // Private constructor — this class is never instantiated.
  Validators._();

  // ─── Name ──────────────────────────────────────────────────────────────────

  /// Validates a first or last name field.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    if (value.trim().length < 2) return 'Must be at least 2 characters.';
    return null;
  }

  // ─── Username ──────────────────────────────────────────────────────────────

  /// Validates a username — alphanumeric and underscores only, 3–20 chars.
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required.';
    if (value.trim().length < 3) return 'Username must be at least 3 characters.';
    if (value.trim().length > 20) return 'Username must be 20 characters or less.';
    final RegExp valid = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!valid.hasMatch(value.trim())) {
      return 'Only letters, numbers, and underscores are allowed.';
    }
    return null;
  }

  // ─── Email ─────────────────────────────────────────────────────────────────

  /// Validates an email address format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email address is required.';
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // ─── Phone ─────────────────────────────────────────────────────────────────

  /// Validates a phone number — digits only, 7–15 characters.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Please enter a valid phone number.';
    if (digits.length > 15) return 'Phone number is too long.';
    return null;
  }

  // ─── Password ──────────────────────────────────────────────────────────────

  /// Validates a password — minimum 6 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  /// Validates that a confirm password field matches the original password.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  // ─── Address ───────────────────────────────────────────────────────────────

  /// Validates an address field — must not be empty.
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'Address is required.';
    if (value.trim().length < 5) return 'Please enter a valid address.';
    return null;
  }

  // ─── OTP Code ──────────────────────────────────────────────────────────────

  /// Validates a 6-digit OTP code.
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter the code.';
    if (value.trim().length != 6) return 'Code must be 6 digits.';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Code must contain digits only.';
    }
    return null;
  }

  // ─── Vehicle Fields ────────────────────────────────────────────────────────

  /// Validates a vehicle plate number — not empty, min 3 chars.
  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Plate number is required.';
    if (value.trim().length < 3) return 'Please enter a valid plate number.';
    return null;
  }

  // ─── Required Generic ──────────────────────────────────────────────────────

  /// Generic required field validator — use for simple required fields
  /// where no format validation is needed.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required.';
    return null;
  }

  // ─── Password Strength ─────────────────────────────────────────────────────

  /// Returns a score from 0–4 indicating password strength.
  /// Used to drive the strength indicator bar on the change password screen.
  /// 0 = too short, 1 = weak, 2 = fair, 3 = good, 4 = strong
  static int passwordStrength(String value) {
    if (value.length < 6) return 0;
    int score = 1;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) score++;
    return score.clamp(0, 4);
  }

  /// Returns a human-readable label for a password strength score.
  static String passwordStrengthLabel(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }
}
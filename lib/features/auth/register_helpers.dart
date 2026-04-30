import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

PreferredSizeWidget buildAppBar(
    BuildContext context, VoidCallback onBack) {
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    leading: Padding(
      padding: const EdgeInsets.only(left: 16),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: onBack,
        padding: EdgeInsets.zero,
      ),
    ),
    leadingWidth: 48,
  );
}

Widget buildProgress(double value) {
  return SizedBox(
    height: 4,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: const Color(0xFF2A2A2E),
        valueColor:
            const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    ),
  );
}

Widget buildHeading(String line1, String line2Colored) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
            text: '$line1\n',
            style: AppTextStyles.authHeading),
        TextSpan(
            text: line2Colored,
            style: AppTextStyles.authHeading
                .copyWith(color: AppColors.primary)),
      ],
    ),
  );
}

Widget errorBanner(String message) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.criticalBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.criticalBorder),
    ),
    child: Text(message,
        style: const TextStyle(
            fontSize: 13,
            color: AppColors.primaryLight,
            fontFamily: 'Inter')),
  );
}

Widget primaryButton(String label, VoidCallback onTap,
    {bool isLoading = false}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor:
            AppColors.primary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : Text(label, style: AppTextStyles.buttonLabel),
    ),
  );
}

/// Formats auth and API error messages to be professional and user-friendly
String formatErrorMessage(String errorMessage) {
  final msg = errorMessage.toLowerCase();

  // Email/Username already exists
  if (msg.contains('already registered') ||
      msg.contains('user already exists') ||
      msg.contains('email already exists') ||
      msg.contains('email already registered') ||
      msg.contains('duplicate key value') ||
      msg.contains('unique constraint')) {
    if (msg.contains('email') ||
        msg.contains('profiles_email')) {
      return 'This email is already registered. Please log in or use a different email.';
    } else if (msg.contains('username') ||
        msg.contains('profiles_username')) {
      return 'This username is already taken. Please choose a different username.';
    }
    return 'This account already exists. Please log in or use different credentials.';
  }

  // Invalid email format
  if (msg.contains('invalid email') || msg.contains('email format')) {
    return 'Please enter a valid email address.';
  }

  // Weak password
  if (msg.contains('weak password') || msg.contains('password')) {
    return 'Your password is too weak. Please use a stronger password with at least 8 characters.';
  }

  // Network errors
  if (msg.contains('socket') ||
      msg.contains('connection') ||
      msg.contains('timeout') ||
      msg.contains('failed host lookup') ||
      msg.contains('no address associated')) {
    return 'No internet connection. Please check your network and try again.';
  }

  // Invalid credentials
  if (msg.contains('invalid credentials') ||
      msg.contains('incorrect password') ||
      msg.contains('user not found')) {
    return 'Invalid email or password. Please try again.';
  }

  // Rate limiting
  if (msg.contains('rate limit') || msg.contains('too many attempts')) {
    return 'Too many login attempts. Please wait a few minutes and try again.';
  }

  // Generic fallback
  if (msg.isEmpty) {
    return 'Something went wrong. Please try again.';
  }

  // If it's already professional-looking, return as-is
  if (msg.contains('please') || msg.contains('must')) {
    return errorMessage;
  }

  // Default: capitalize first letter and make user-friendly
  return 'Unable to complete your request. Please try again or contact support.';
}

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

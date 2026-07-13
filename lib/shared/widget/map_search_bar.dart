// Expanding search bar used in place of the screen header when the search
// icon is tapped on the two mechanic-facing map screens (User Mechanics,
// Mechanic Users) — lets the user type a name to find, not a map/place
// search.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
          AppSpacing.md, AppSpacing.pageHorizontal, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xE1141414),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xE1141414),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      onChanged: onChanged,
                      style: AppTypography.input,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: AppTypography.inputLabel,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () {
                          controller.clear();
                          onChanged('');
                        },
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textMuted, size: 16),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

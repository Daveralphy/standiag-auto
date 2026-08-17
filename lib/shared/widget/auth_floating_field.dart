// Floating-label text field used across auth screens (login, forgot
// password, signup). Shows field-level errors in a reserved slot below the
// field so an error appearing/disappearing never shifts surrounding content.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AuthFloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const AuthFloatingField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 16,
            color: AppColors.textPrimary, fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(
              fontFamily: 'Inter', fontSize: 15,
              color: hasError
                  ? AppColors.primary.withValues(alpha: 0.8)
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            floatingLabelStyle: TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: hasError
                ? const Color(0x0DE8281E)
                : AppColors.borderSubtle,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 18),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix)
                : null,
            suffixIconConstraints: const BoxConstraints(
                minWidth: 40, minHeight: 48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.primary
                    : AppColors.borderActive,
                width: hasError ? 1.5 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.primary
                    : AppColors.borderActive,
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderSubtle),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
          cursorColor: AppColors.primary,
        ),
        // Reserved slot for the error message — always present at this
        // height so an error appearing/disappearing never shifts anything
        // else on screen; it's just blank when there's nothing to show.
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
          child: SizedBox(
            height: 16,
            child: hasError
                ? Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          errorText!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

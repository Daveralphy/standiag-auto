// Shared field row for profile view screens (User and Mechanic) — an
// uppercase micro-label over a value, with a thin bottom-border divider.
// Matches design/profile_screens.html's field-list style exactly. Both
// profile screens use this same widget so they can never visually drift
// apart from each other.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class ProfileFieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool dimmed;
  final VoidCallback? onTap;

  const ProfileFieldRow({
    super.key,
    required this.label,
    required this.value,
    this.dimmed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textDim,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : '—',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
    return onTap == null ? row : GestureDetector(onTap: onTap, child: row);
  }
}

/// Skeleton placeholder shaped exactly like [ProfileFieldRow], for loading
/// states on profile view screens.
class ProfileFieldRowSkeleton extends StatelessWidget {
  final double valueWidth;
  const ProfileFieldRowSkeleton({super.key, this.valueWidth = 160});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 9,
            decoration: BoxDecoration(
              color: const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: valueWidth,
            height: 13,
            decoration: BoxDecoration(
              color: const Color(0x0AFFFFFF),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
        ],
      ),
    );
  }
}

// The tappable photo box on Add/Edit Vehicle — shows a freshly picked
// local image, or the vehicle's existing photo, or an empty "add a photo"
// placeholder if there's neither.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class VehiclePhotoPicker extends StatelessWidget {
  /// A photo just picked this session, not yet uploaded — takes priority
  /// over [existingUrl] since it's what the user most recently chose.
  final XFile? pickedPhoto;

  /// The vehicle's current photo, if any (edit mode only).
  final String? existingUrl;

  final bool isUploading;
  final VoidCallback? onTap;

  const VehiclePhotoPicker({
    super.key,
    this.pickedPhoto,
    this.existingUrl,
    this.isUploading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.borderActive),
        ),
        child: isUploading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _content(),
      ),
    );
  }

  Widget _content() {
    final photo = pickedPhoto;
    if (photo != null) {
      return _withChangeBadge(Image.file(File(photo.path), fit: BoxFit.cover));
    }
    if (existingUrl != null && existingUrl!.isNotEmpty) {
      return _withChangeBadge(
        Image.network(
          existingUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _EmptyState(),
        ),
      );
    }
    return const _EmptyState();
  }

  Widget _withChangeBadge(Widget image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xE1141414),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Change',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_a_photo_outlined,
            color: AppColors.textMuted,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a Vehicle Photo',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

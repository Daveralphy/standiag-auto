// Reusable avatar widget for StanDiag Auto.
// Displays a user or mechanic profile photo from a network URL.
// Falls back to initials on a coloured background if no image is available.
// Never build avatar logic inline in a screen — always use AppAvatar.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import './app_skeleton.dart';

class AppAvatar extends StatelessWidget {
  /// The network URL of the profile photo.
  /// Pass null to show the initials fallback.
  final String? imageUrl;

  /// The full name used to generate initials when [imageUrl] is null.
  final String name;

  /// Diameter of the avatar in logical pixels.
  final double size;

  /// Optional colored ring drawn around the avatar.
  /// Defaults to the primary red with reduced opacity.
  final Color? borderColor;

  /// Width of the ring. Set to 0 for no border.
  final double borderWidth;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 36,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.primaryBorder,
                width: borderWidth,
              )
            : null,
        boxShadow: borderWidth > 0
            ? [
                BoxShadow(
                  color: (borderColor ?? AppColors.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? _NetworkImage(url: imageUrl!, size: size, name: name)
            : _InitialsFallback(name: name, size: size),
      ),
    );
  }
}

// ─── Network Image ─────────────────────────────────────────────────────────

class _NetworkImage extends StatelessWidget {
  final String url;
  final double size;
  final String name;

  const _NetworkImage({
    required this.url,
    required this.size,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      // Show shimmer skeleton while the image loads
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return AppSkeleton.circle(size: size);
      },
      // Fall back to initials if the image fails to load
      errorBuilder: (_, __, ___) => _InitialsFallback(name: name, size: size),
    );
  }
}

// ─── Initials Fallback ─────────────────────────────────────────────────────

class _InitialsFallback extends StatelessWidget {
  final String name;
  final double size;

  const _InitialsFallback({required this.name, required this.size});

  String get _initials {
    final List<String> parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surface,
      child: Center(
        child: Text(
          _initials,
          style: AppTypography.body.copyWith(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
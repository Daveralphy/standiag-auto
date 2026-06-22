// Reusable badge and tag widgets for StanDiag Auto.
// Used for expertise tags, online/offline status dots, "Best Value" labels,
// and notification dots on header icons.
// Never build badge or tag logic inline in a screen — always use these widgets.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

// ─── Expertise Tag ─────────────────────────────────────────────────────────

// Small pill tag used for mechanic expertise labels.
// Example: "Engine Repair", "Transmission", "Electrical"
class ExpertiseTag extends StatelessWidget {
  final String label;

  const ExpertiseTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF), // 5% white
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.micro,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

// ─── Status Dot ────────────────────────────────────────────────────────────

// Animated pulsing dot indicating online/offline status.
// Green when online, grey when offline.
class StatusDot extends StatefulWidget {
  final bool isOnline;

  /// Size of the dot in logical pixels. Defaults to 8.
  final double size;

  const StatusDot({
    super.key,
    required this.isOnline,
    this.size = 8,
  });

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Only animate when online — no animation when offline
    if (widget.isOnline) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StatusDot old) {
    super.didUpdateWidget(old);
    if (widget.isOnline && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOnline && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor =
        widget.isOnline ? AppColors.success : AppColors.textDisabled;

    if (!widget.isOnline) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: dotColor.withValues(alpha: _pulseAnimation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.4 * _pulseAnimation.value),
                blurRadius: widget.size,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Notification Dot ──────────────────────────────────────────────────────

// Small red dot overlaid on top of an icon to indicate unread notifications.
// Wrap the icon widget in a Stack and overlay this on top.
class NotificationDot extends StatelessWidget {
  const NotificationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x66E8281E),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

// ─── Best Value Badge ──────────────────────────────────────────────────────

// Small red "Best Value" badge used on the credits bundle cards.
class BestValueBadge extends StatelessWidget {
  const BestValueBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        'Best Value',
        style: AppTypography.microBold.copyWith(color: Colors.white),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

// ─── Rating Stars Row ──────────────────────────────────────────────────────

// A row of star icons for displaying a rating.
// Shows filled, half, and empty stars based on the [rating] value.
class RatingStars extends StatelessWidget {
  /// Rating value between 0.0 and 5.0.
  final double rating;

  /// Size of each star. Defaults to 14.
  final double starSize;

  /// Color of filled stars. Defaults to amber.
  final Color filledColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 14,
    this.filledColor = AppColors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final double value = rating - index;
        IconData icon;
        Color color;

        if (value >= 1) {
          icon = Icons.star_rounded;
          color = filledColor;
        } else if (value >= 0.5) {
          icon = Icons.star_half_rounded;
          color = filledColor;
        } else {
          icon = Icons.star_outline_rounded;
          color = AppColors.textDisabled;
        }

        return Icon(icon, size: starSize, color: color);
      }),
    );
  }
}
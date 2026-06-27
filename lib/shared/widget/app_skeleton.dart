// Shimmer skeleton loading widgets for StanDiag Auto.
// Used on every screen that loads remote data.
// Static elements render immediately — only data sections use skeletons.
// The skeleton shape must match the real content it replaces.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

// ─── Base Shimmer ──────────────────────────────────────────────────────────

// A single shimmering rectangular block.
// Use this as the building block for all skeleton components.
class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.sm,
    this.margin,
  });

  /// Full-width skeleton block. Width fills the parent.
  const AppSkeleton.wide({
    super.key,
    required this.height,
    this.radius = AppRadius.sm,
    this.margin,
  }) : width = double.infinity;

  /// Circular skeleton — for avatars.
  const AppSkeleton.circle({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        radius = AppRadius.full;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value, 0),
                colors: const [
                  Color(0xFF1A1A1A),
                  Color(0xFF222222),
                  Color(0xFF1A1A1A),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Composite Skeletons ───────────────────────────────────────────────────

// Skeleton for a mechanic card row (avatar + name + rating + expertise tags).
class MechanicCardSkeleton extends StatelessWidget {
  const MechanicCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AppSkeleton.circle(size: 46),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.wide(height: 13, radius: AppRadius.xs),
                SizedBox(height: 6),
                AppSkeleton(width: 80, height: 10, radius: AppRadius.xs),
                SizedBox(height: 8),
                Row(
                  children: [
                    AppSkeleton(width: 50, height: 18, radius: AppRadius.full),
                    SizedBox(width: 6),
                    AppSkeleton(width: 60, height: 18, radius: AppRadius.full),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Skeleton for a transaction history row.
class TransactionRowSkeleton extends StatelessWidget {
  const TransactionRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AppSkeleton(width: 36, height: 36, radius: AppRadius.sm),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.wide(height: 12, radius: AppRadius.xs),
                SizedBox(height: 5),
                AppSkeleton(width: 80, height: 10, radius: AppRadius.xs),
              ],
            ),
          ),
          SizedBox(width: 12),
          AppSkeleton(width: 40, height: 13, radius: AppRadius.xs),
        ],
      ),
    );
  }
}

// Skeleton for a vehicle card.
class VehicleCardSkeleton extends StatelessWidget {
  const VehicleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.wide(height: 13, radius: AppRadius.xs),
          SizedBox(height: 6),
          AppSkeleton(width: 120, height: 10, radius: AppRadius.xs),
          SizedBox(height: 10),
          Row(
            children: [
              AppSkeleton(width: 60, height: 18, radius: AppRadius.full),
              SizedBox(width: 6),
              AppSkeleton(width: 50, height: 18, radius: AppRadius.full),
            ],
          ),
        ],
      ),
    );
  }
}

// Skeleton for the credits balance card.
class CreditsBalanceSkeleton extends StatelessWidget {
  const CreditsBalanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.creditsCard),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(width: 80, height: 10, radius: AppRadius.xs),
          SizedBox(height: 10),
          AppSkeleton(width: 140, height: 44, radius: AppRadius.sm),
          SizedBox(height: 16),
          AppSkeleton(width: 110, height: 36, radius: AppRadius.full),
        ],
      ),
    );
  }
}

// Skeleton for a profile header (avatar + name + subtitle).
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppSkeleton.circle(size: 36),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 120, height: 14, radius: AppRadius.xs),
              SizedBox(height: 4),
              AppSkeleton(width: 80, height: 10, radius: AppRadius.xs),
            ],
          ),
        ),
      ],
    );
  }
}
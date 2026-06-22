// The primary reusable button widget for StanDiag Auto.
// Covers all button variants used across the app.
// Never build a custom button inline in a screen — always use AppButton.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

// The visual style of the button.
enum AppButtonVariant {
  /// Full-width red gradient pill. The primary action button.
  primary,

  /// Translucent ghost button. Used for secondary/cancel actions.
  ghost,

  /// Red-bordered outline button. Used for destructive confirmations.
  danger,
}

class AppButton extends StatefulWidget {
  /// The label shown on the button.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Visual variant. Defaults to primary.
  final AppButtonVariant variant;

  /// Whether to show a loading spinner instead of the label.
  /// Disables tap when true.
  final bool isLoading;

  /// Optional leading icon widget displayed before the label.
  final Widget? icon;

  /// Custom width. Defaults to full width (double.infinity).
  final double? width;

  /// Custom vertical padding. Defaults to 14.
  final double? paddingV;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.paddingV,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Subtle press scale animation for tactile feel
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null || widget.isLoading) return;
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onTap == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: disabled ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          child: _buildSurface(disabled),
        ),
      ),
    );
  }

  Widget _buildSurface(bool disabled) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _PrimaryButtonSurface(
          label: widget.label,
          isLoading: widget.isLoading,
          disabled: disabled,
          icon: widget.icon,
          paddingV: widget.paddingV ?? 14,
        );
      case AppButtonVariant.ghost:
        return _GhostButtonSurface(
          label: widget.label,
          isLoading: widget.isLoading,
          icon: widget.icon,
          paddingV: widget.paddingV ?? 13,
        );
      case AppButtonVariant.danger:
        return _DangerButtonSurface(
          label: widget.label,
          isLoading: widget.isLoading,
          paddingV: widget.paddingV ?? 13,
        );
    }
  }
}

// ─── Primary Button Surface ────────────────────────────────────────────────

// Red gradient pill with 3D highlight and glow shadow.
// Matches the primary button design in all HTML screens.
class _PrimaryButtonSurface extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool disabled;
  final Widget? icon;
  final double paddingV;

  const _PrimaryButtonSurface({
    required this.label,
    required this.isLoading,
    required this.disabled,
    this.icon,
    required this.paddingV,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      // Dim the button when disabled so user knows it is not tappable
      opacity: disabled && !isLoading ? 0.35 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: 20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(AppRadius.buttonPrimary),
          boxShadow: const [
            // Inner top highlight — creates the 3D raised effect
            BoxShadow(
              color: Color(0x47FFFFFF),
              offset: Offset(0, 1.5),
              blurRadius: 0,
              spreadRadius: 0,
            ),
            // Near red glow
            BoxShadow(
              color: Color(0x80820F0A),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
            // Far red glow
            BoxShadow(
              color: Color(0x38E8281E),
              offset: Offset(0, 6),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTypography.button,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Ghost Button Surface ──────────────────────────────────────────────────

// Translucent dark button with subtle border.
// Used for skip, cancel, and secondary actions.
class _GhostButtonSurface extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Widget? icon;
  final double paddingV;

  const _GhostButtonSurface({
    required this.label,
    required this.isLoading,
    this.icon,
    required this.paddingV,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF), // 5% white
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textMuted),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTypography.buttonSecondary,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Danger Button Surface ─────────────────────────────────────────────────

// Red gradient pill used for destructive actions like Delete Account.
// Same appearance as primary but no disabled state.
class _DangerButtonSurface extends StatelessWidget {
  final String label;
  final bool isLoading;
  final double paddingV;

  const _DangerButtonSurface({
    required this.label,
    required this.isLoading,
    required this.paddingV,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DE8281E),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: AppTypography.button,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
      ),
    );
  }
}
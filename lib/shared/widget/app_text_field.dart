// The primary reusable text input widget for StanDiag Auto.
// Implements the floating label design from the HTML screens.
// Never build a custom text input inline in a screen — always use AppTextField.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class AppTextField extends StatefulWidget {
  /// The floating label shown above the field when focused or filled.
  final String label;

  /// Hint text shown inside the field when empty and unfocused.
  final String? hint;

  /// Controller for reading and setting the field value.
  final TextEditingController? controller;

  /// Called on every character change.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (taps done/next on keyboard).
  final VoidCallback? onSubmitted;

  /// Whether this field hides its text (passwords).
  final bool obscureText;

  /// Keyboard type. Defaults to text.
  final TextInputType keyboardType;

  /// The action shown on the keyboard (next, done etc.).
  final TextInputAction textInputAction;

  /// Optional widget shown at the end of the field (e.g. eye icon for password).
  final Widget? suffix;

  /// Optional input formatters (e.g. phone number masking).
  final List<TextInputFormatter>? inputFormatters;

  /// Whether this field is enabled for input.
  final bool enabled;

  /// FocusNode for programmatic focus control.
  final FocusNode? focusNode;

  /// Maximum number of lines. Defaults to 1.
  final int maxLines;

  /// Maximum character count.
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.suffix,
    this.inputFormatters,
    this.enabled = true,
    this.focusNode,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Use provided FocusNode or create our own
    _focusNode = widget.focusNode ?? FocusNode();
    _obscure = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // Only dispose if we created the FocusNode — don't dispose a provided one
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.controller?.text.isNotEmpty ?? false;
    final bool showLabel = _isFocused || hasValue;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ─── Input Field ────────────────────────────────────────────────────
        Container(
          height: widget.maxLines > 1 ? null : 50,
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF), // 4% white — matches HTML design
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              // Border turns red on focus — matches HTML design
              color: _isFocused ? AppColors.primary : AppColors.borderActive,
              width: _isFocused ? 1.2 : 1.0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText ? _obscure : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            style: AppTypography.input,
            cursorColor: AppColors.primary,
            onChanged: (value) {
              // Trigger rebuild so the floating label responds to typing
              setState(() {});
              widget.onChanged?.call(value);
            },
            onSubmitted: (_) => widget.onSubmitted?.call(),
            decoration: InputDecoration(
              // Top padding accounts for the floating label above the field
              contentPadding: EdgeInsets.fromLTRB(
                12,
                showLabel ? 16 : 13,
                widget.suffix != null ? 40 : 12,
                13,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              // Empty label here — we draw our own floating label in the Stack
              labelText: null,
              hintText: (!showLabel && widget.hint != null) ? widget.hint : null,
              hintStyle: AppTypography.inputLabel,
              counterText: '',
            ),
          ),
        ),

        // ─── Floating Label ──────────────────────────────────────────────────
        // Positioned above the field border when focused or has content.
        // Sits on a background swatch to break the border line cleanly.
        if (showLabel)
          Positioned(
            top: -7,
            left: 11,
            child: Container(
              // The background must match the screen background exactly
              // so the label appears to float above the border.
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.label,
                style: _isFocused
                    ? AppTypography.inputLabelFocused
                    : AppTypography.inputLabel,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),

        // ─── Suffix Widget ───────────────────────────────────────────────────
        // Positioned at the right end of the field (e.g. eye icon).
        if (widget.suffix != null)
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(child: widget.suffix),
          )
        else if (widget.obscureText)
          // Auto-generate eye toggle for password fields
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}
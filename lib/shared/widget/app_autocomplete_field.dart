// A floating-label text field (same look as AppTextField) that shows a
// suggestions dropdown below it as the user types. Used for Make/Model on
// the vehicle forms. Suggestions are just an assist — the field stays fully
// freely editable, so a value with no matches is never blocked.
//
// The dropdown renders as an Overlay anchored to the field via a LayerLink,
// rather than inline in the widget tree, so a long suggestions list floats
// on top of whatever's below the field instead of pushing it down. That
// matters most when two of these sit side by side in a Row (Make/Model):
// an inline dropdown would only have half the row's width to grow into and
// would shove the row below it down by a different amount depending on
// which field's list happened to be longer.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class AppAutocompleteField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;

  /// Returns the suggestions to show for the current field text.
  /// Called again on every keystroke while the field is focused.
  final List<String> Function(String query) suggestionsBuilder;

  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  const AppAutocompleteField({
    super.key,
    required this.label,
    required this.controller,
    required this.suggestionsBuilder,
    this.hint,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AppAutocompleteField> createState() => _AppAutocompleteFieldState();
}

class _AppAutocompleteFieldState extends State<AppAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  bool _isFocused = false;
  List<String> _suggestions = const [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      _suggestions = _isFocused
          ? widget.suggestionsBuilder(widget.controller.text)
          : const [];
    });
    _syncOverlay();
  }

  void _onTextChanged(String value) {
    setState(() {
      _suggestions = _isFocused ? widget.suggestionsBuilder(value) : const [];
    });
    _syncOverlay();
    widget.onChanged?.call(value);
  }

  /// Inserts, updates, or removes the overlay entry to match [_suggestions]
  /// — called after every state change that can affect what it should show.
  void _syncOverlay() {
    if (_suggestions.isEmpty) {
      _removeOverlay();
      return;
    }
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    final width = context.size?.width ?? 0;
    return OverlayEntry(
      builder: (_) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 190),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.borderSubtle),
                itemBuilder: (_, i) => InkWell(
                  onTap: () => _select(_suggestions[i]),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                    child: Text(
                      _suggestions[i],
                      style:
                          AppTypography.body.copyWith(color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _select(String value) {
    widget.controller.text = value;
    widget.controller.selection =
        TextSelection.collapsed(offset: value.length);
    setState(() => _suggestions = const []);
    _removeOverlay();
    widget.onChanged?.call(value);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.controller.text.isNotEmpty;
    final bool showLabel = _isFocused || hasValue;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: _isFocused ? AppColors.primary : AppColors.borderActive,
                width: _isFocused ? 1.2 : 1.0,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              textInputAction: widget.textInputAction,
              style: AppTypography.input,
              cursorColor: AppColors.primary,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                    12, showLabel ? 18 : 15, 12, 15),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: (!showLabel && widget.hint != null)
                    ? widget.hint
                    : null,
                hintStyle: AppTypography.inputLabel,
              ),
            ),
          ),
          if (showLabel)
            Positioned(
              top: -7,
              left: 11,
              child: Container(
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
        ],
      ),
    );
  }
}

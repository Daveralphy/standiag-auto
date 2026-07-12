// A floating-label text field (same look as AppTextField) that shows a
// suggestions dropdown below it as the user types. Used for Make/Model on
// the vehicle forms. Suggestions are just an assist — the field stays fully
// freely editable, so a value with no matches is never blocked.

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
  bool _isFocused = false;
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      _suggestions =
          _isFocused ? widget.suggestionsBuilder(widget.controller.text) : const [];
    });
  }

  void _onTextChanged(String value) {
    setState(() {
      _suggestions = _isFocused ? widget.suggestionsBuilder(value) : const [];
    });
    widget.onChanged?.call(value);
  }

  void _select(String value) {
    widget.controller.text = value;
    widget.controller.selection =
        TextSelection.collapsed(offset: value.length);
    setState(() => _suggestions = const []);
    widget.onChanged?.call(value);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.controller.text.isNotEmpty;
    final bool showLabel = _isFocused || hasValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0x0AFFFFFF),
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
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: _suggestions.isEmpty
              ? const SizedBox(width: double.infinity, height: 0)
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
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
                        const Divider(height: 1, color: AppColors.borderSubtle),
                    itemBuilder: (_, i) => InkWell(
                      onTap: () => _select(_suggestions[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 12),
                        child: Text(
                          _suggestions[i],
                          style: AppTypography.body
                              .copyWith(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

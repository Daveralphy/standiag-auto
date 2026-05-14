import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_system.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Seamless dropdown â€” field bottom border removed when open,
// dropdown attaches directly below with no gap, same background.
// Uses Overlay so it floats above all other widgets.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class AppSearchDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final String? value;
  final IconData icon;
  final List<String> items;
  final void Function(String) onSelected;
  final bool searchable;

  const AppSearchDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onSelected,
    this.value,
    this.icon = Icons.arrow_drop_down,
    this.searchable = false,
  });

  @override
  State<AppSearchDropdown> createState() => _AppSearchDropdownState();
}

class _AppSearchDropdownState extends State<AppSearchDropdown> {
  final _link = LayerLink();
  final _key  = GlobalKey();
  final _searchCtrl = TextEditingController();
  OverlayEntry? _entry;
  List<String> _filtered = [];
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void didUpdateWidget(AppSearchDropdown old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _filtered = widget.items;
      if (_open) WidgetsBinding.instance.addPostFrameCallback((_) => _rebuild());
    }
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _open = false;
    _searchCtrl.dispose();
    super.dispose();
  }

  RenderBox? get _box =>
      _key.currentContext?.findRenderObject() as RenderBox?;
  double get _width => _box?.size.width ?? 300;

  void _toggle() => _open ? _close() : _openDrop();

  void _openDrop() {
    _filtered = widget.items;
    _searchCtrl.clear();
    _open = true;
    _entry = _build();
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    _open = false;
    if (mounted) setState(() {});
  }

  void _rebuild() {
    _entry?.remove();
    _entry = _build();
    Overlay.of(context).insert(_entry!);
  }

  void _filter(String q) {
    _filtered = widget.items
        .where((i) => i.toLowerCase().contains(q.toLowerCase()))
        .toList();
    _rebuild();
  }

  OverlayEntry _build() {
    final w = _width;
    return OverlayEntry(builder: (_) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _close,
      child: Stack(children: [
        Positioned.fill(child: Container(color: Colors.transparent)),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: const Offset(0, 47),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: w,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(14)),
                    border: Border(
                      left:   BorderSide(color: _open ? AppColors.primaryBorder : AppColors.border),
                      right:  BorderSide(color: _open ? AppColors.primaryBorder : AppColors.border),
                      bottom: BorderSide(color: _open ? AppColors.primaryBorder : AppColors.border),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.searchable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(
                                color: AppColors.borderSubtle)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.search_rounded,
                                color: AppColors.textTertiary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              onChanged: _filter,
                              style: AppTypography.body.copyWith(
                                  color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: AppTypography.body.copyWith(
                                    color: AppColors.textDisabled),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            )),
                          ]),
                        ),
                      Flexible(child: _filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('No results found',
                                style: AppTypography.body.copyWith(
                                    color: AppColors.textTertiary)))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: AppColors.borderSubtle),
                            itemBuilder: (_, i) {
                              final item = _filtered[i];
                              final sel  = item == widget.value;
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  widget.onSelected(item);
                                  _close();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 13),
                                  child: Row(children: [
                                    Expanded(child: Text(item,
                                        style: AppTypography.body.copyWith(
                                            color: sel
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                            fontWeight: sel
                                                ? FontWeight.w700
                                                : FontWeight.w400))),
                                    if (sel)
                                      const Icon(Icons.check_rounded,
                                          color: AppColors.primary,
                                          size: 16),
                                  ]),
                                ),
                              );
                            })),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Stack(
        key: _key,
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                // When open: no bottom border so dropdown connects
                borderRadius: _open
                    ? const BorderRadius.vertical(top: Radius.circular(14))
                    : AppRadius.lgAll,
                border: _open
                    ? Border(
                        top:   BorderSide(color: AppColors.primaryBorder),
                        left:  BorderSide(color: AppColors.primaryBorder),
                        right: BorderSide(color: AppColors.primaryBorder),
                      )
                    : Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                const SizedBox(width: 16),
                Icon(widget.icon, color: AppColors.textTertiary, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  widget.value ?? widget.hint,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                      color: widget.value != null
                          ? AppColors.textPrimary
                          : AppColors.textDisabled),
                )),
                Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiary, size: 20),
                const SizedBox(width: 16),
              ]),
            ),
          ),
          Positioned(
            top: -9, left: 12,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(widget.label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Multi-select seamless dropdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppMultiSelectDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> options;
  final Set<String> selected;
  final void Function(Set<String>) onChanged;
  final IconData icon;

  const AppMultiSelectDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.icon = Icons.build_outlined,
  });

  @override
  State<AppMultiSelectDropdown> createState() =>
      _AppMultiSelectDropdownState();
}

class _AppMultiSelectDropdownState extends State<AppMultiSelectDropdown> {
  final _link = LayerLink();
  final _key  = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;
  late Set<String> _temp;

  @override
  void initState() {
    super.initState();
    _temp = Set.from(widget.selected);
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _open = false;
    super.dispose();
  }

  double get _width =>
      ((_key.currentContext?.findRenderObject()) as RenderBox?)
          ?.size.width ?? 300;

  void _toggle() => _open ? _close() : _openDrop();

  void _openDrop() {
    _temp = Set.from(widget.selected);
    _open = true;
    _entry = _build();
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    _open = false;
    if (mounted) setState(() {});
  }

  void _rebuild() {
    _entry?.remove();
    _entry = _build();
    Overlay.of(context).insert(_entry!);
  }

  void _confirm() {
    widget.onChanged(Set.from(_temp));
    _close();
  }

  OverlayEntry _build() {
    final w = _width;
    return OverlayEntry(builder: (_) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _close,
      child: Stack(children: [
        Positioned.fill(child: Container(color: Colors.transparent)),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: const Offset(0, 47),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: w,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(14)),
                    border: const Border(
                      left:   BorderSide(color: AppColors.primaryBorder),
                      right:  BorderSide(color: AppColors.primaryBorder),
                      bottom: BorderSide(color: AppColors.primaryBorder),
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: widget.options.map((s) {
                          final sel = _temp.contains(s);
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (sel) {
                                _temp.remove(s);
                              } else {
                                _temp.add(s);
                              }
                              WidgetsBinding.instance.addPostFrameCallback((_) => _rebuild());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primarySubtle
                                    : AppColors.surfaceCard,
                                borderRadius: AppRadius.fullAll,
                                border: Border.all(
                                    color: sel
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: sel ? 1.5 : 1.0),
                              ),
                              child: Text(s,
                                  style: AppTypography.bodySm.copyWith(
                                      color: sel
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.w400)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _confirm,
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: Center(child: Text('Confirm',
                              style: AppTypography.button
                                  .copyWith(fontSize: 14))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.selected.isEmpty
        ? widget.hint
        : widget.selected.join(', ');
    return CompositedTransformTarget(
      link: _link,
      child: Stack(
        key: _key,
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: _open
                    ? const BorderRadius.vertical(top: Radius.circular(14))
                    : AppRadius.lgAll,
                border: _open
                    ? const Border(
                        top:   BorderSide(color: AppColors.primaryBorder),
                        left:  BorderSide(color: AppColors.primaryBorder),
                        right: BorderSide(color: AppColors.primaryBorder),
                      )
                    : Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(children: [
                Icon(widget.icon,
                    color: AppColors.textTertiary, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(display,
                    style: AppTypography.body.copyWith(
                        color: widget.selected.isEmpty
                            ? AppColors.textDisabled
                            : AppColors.textPrimary))),
                Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiary, size: 20),
              ]),
            ),
          ),
          Positioned(
            top: -9, left: 12,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(widget.label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ DOB seamless dropdown â€” 3 independent wheel columns â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppDobDropdown extends StatefulWidget {
  final String label;
  final int day;
  final int month;
  final int year;
  final bool confirmed;
  final void Function(int day, int month, int year) onChanged;

  const AppDobDropdown({
    super.key,
    required this.label,
    required this.day,
    required this.month,
    required this.year,
    required this.confirmed,
    required this.onChanged,
  });

  @override
  State<AppDobDropdown> createState() => _AppDobDropdownState();
}

class _AppDobDropdownState extends State<AppDobDropdown> {
  final _link = LayerLink();
  final _key  = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;
  late int _day, _month, _year;

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  @override
  void initState() {
    super.initState();
    _day   = widget.day;
    _month = widget.month;
    _year  = widget.year;
  }

  @override
  void dispose() {
    _saveAndClose();
    super.dispose();
  }

  double get _width =>
      ((_key.currentContext?.findRenderObject()) as RenderBox?)
          ?.size.width ?? 300;

  void _toggle() => _open ? _saveAndClose() : _openDrop();

  void _openDrop() {
    _open = true;
    _entry = _build();
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _saveAndClose() {
    if (_open) widget.onChanged(_day, _month, _year);
    _entry?.remove();
    _entry = null;
    _open = false;
    if (mounted) setState(() {});
  }

  OverlayEntry _build() {
    final w = _width;
    return OverlayEntry(builder: (_) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _saveAndClose,
      child: Stack(children: [
        Positioned.fill(child: Container(color: Colors.transparent)),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: const Offset(0, 47),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: w,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 190,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(14)),
                    border: Border(
                      left:   BorderSide(color: AppColors.primaryBorder),
                      right:  BorderSide(color: AppColors.primaryBorder),
                      bottom: BorderSide(color: AppColors.primaryBorder),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                  child: Row(children: [
                    Expanded(child: _DobCol(
                      label: 'DAY',
                      count: 31,
                      initial: _day - 1,
                      labelOf: (i) => '${i + 1}',
                      onChanged: (i) => _day = i + 1,
                    )),
                    Container(width: 1, color: AppColors.borderSubtle),
                    Expanded(child: _DobCol(
                      label: 'MONTH',
                      count: 12,
                      initial: _month - 1,
                      labelOf: (i) => _months[i],
                      onChanged: (i) => _month = i + 1,
                    )),
                    Container(width: 1, color: AppColors.borderSubtle),
                    Expanded(child: _DobCol(
                      label: 'YEAR',
                      count: DateTime.now().year - 1950 - 9,
                      initial: _year - 1950,
                      labelOf: (i) => '${1950 + i}',
                      onChanged: (i) => _year = 1950 + i,
                    )),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Stack(
        key: _key,
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: _open
                    ? const BorderRadius.vertical(top: Radius.circular(14))
                    : AppRadius.lgAll,
                border: _open
                    ? const Border(
                        top:   BorderSide(color: AppColors.primaryBorder),
                        left:  BorderSide(color: AppColors.primaryBorder),
                        right: BorderSide(color: AppColors.primaryBorder),
                      )
                    : Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                const SizedBox(width: 16),
                const Icon(Icons.calendar_month_outlined,
                    color: AppColors.textTertiary, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  widget.confirmed
                      ? '${widget.day} ${_months[widget.month - 1]} ${widget.year}'
                      : 'Select date of birth',
                  style: AppTypography.body.copyWith(
                      color: widget.confirmed
                          ? AppColors.textPrimary
                          : AppColors.textDisabled),
                )),
                Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiary, size: 20),
                const SizedBox(width: 16),
              ]),
            ),
          ),
          Positioned(
            top: -9, left: 12,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(widget.label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Single DOB wheel column â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DobCol extends StatefulWidget {
  final String label;
  final int count;
  final int initial;
  final String Function(int) labelOf;
  final void Function(int) onChanged;

  const _DobCol({
    required this.label,
    required this.count,
    required this.initial,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  State<_DobCol> createState() => _DobColState();
}

class _DobColState extends State<_DobCol> {
  late FixedExtentScrollController _ctrl;
  late int _cur;

  @override
  void initState() {
    super.initState();
    _cur  = widget.initial;
    _ctrl = FixedExtentScrollController(initialItem: _cur);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(widget.label,
          style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 9)),
      const SizedBox(height: 4),
      Expanded(
        child: ListWheelScrollView.useDelegate(
          controller: _ctrl,
          itemExtent: 36,
          perspective: 0.003,
          diameterRatio: 1.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (i) {
            setState(() => _cur = i);
            widget.onChanged(i);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.count,
            builder: (_, i) {
              final sel  = i == _cur;
              final near = (i - _cur).abs() == 1;
              return Center(child: Text(
                widget.labelOf(i),
                style: TextStyle(
                    fontSize: sel ? 20 : near ? 15 : 12,
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                    color: sel
                        ? AppColors.textPrimary
                        : near
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                    fontFamily: 'Inter'),
              ));
            },
          ),
        ),
      ),
    ]);
  }
}






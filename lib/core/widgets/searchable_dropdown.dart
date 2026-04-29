import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom searchable dropdown with:
/// - Search bar at top
/// - Max 5 items visible at once
/// - Proper positioning (opens downward from dropdown)
/// - Scroll if more than 5 items
class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _searchController;
  late List<String> _filteredItems;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = List.from(widget.items);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectItem(String item) {
    widget.onChanged(item);
    setState(() {
      _isOpen = false;
      _searchController.clear();
      _filteredItems = List.from(widget.items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
              fontFamily: 'Inter',
            )),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? 'Select ${widget.label.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.value != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterItems,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.label.toLowerCase()}...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontFamily: 'Inter',
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // Items list (max 5 visible)
                  SizedBox(
                    height: _filteredItems.isEmpty ? 50 : ((_filteredItems.length > 5 ? 5 : _filteredItems.length) * 44.0),
                    child: _filteredItems.isEmpty
                        ? const Center(
                            child: Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _filteredItems.length,
                            itemBuilder: (_, index) {
                              final item = _filteredItems[index];
                              final isSelected = item == widget.value;
                              return GestureDetector(
                                onTap: () => _selectItem(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                            fontFamily: 'Inter',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
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

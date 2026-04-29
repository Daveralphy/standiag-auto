import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'mechanic_orders_screen.dart';
import 'mechanic_scan_screen.dart';
import 'mechanic_earnings_screen.dart';
import 'mechanic_profile_screen.dart';

class MechanicNavigation extends StatefulWidget {
  const MechanicNavigation({super.key});

  @override
  State<MechanicNavigation> createState() =>
      _MechanicNavigationState();
}

class _MechanicNavigationState extends State<MechanicNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MechanicOrdersScreen(),
    MechanicScanScreen(),
    MechanicEarningsScreen(),
    MechanicProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.navBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: _NavItem(
                icons: [
                  (Icons.receipt_long_outlined, Icons.receipt_long_rounded),
                  (Icons.wifi_tethering_outlined, Icons.wifi_tethering_rounded),
                  (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded),
                  (Icons.person_outline_rounded, Icons.person_rounded),
                ][i],
                labels: ['Orders', 'Scan', 'Earnings', 'Profile'][i],
                index: i,
                selected: _selectedIndex,
                onTap: (idx) => setState(() => _selectedIndex = idx),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final (IconData, IconData) icons;
  final String labels;
  final int index;
  final int selected;
  final void Function(int) onTap;

  const _NavItem({
    required this.icons,
    required this.labels,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.selected == widget.index) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.selected == widget.index && old.selected != widget.index) {
      _ctrl.forward();
    } else if (widget.selected != widget.index && old.selected == widget.index) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selected == widget.index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onTap(widget.index),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? widget.icons.$2 : widget.icons.$1,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              widget.labels,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
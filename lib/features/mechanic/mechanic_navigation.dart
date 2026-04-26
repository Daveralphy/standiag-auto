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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.navBg,
        border: Border(
            top: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'Orders',
              index: 0,
              selected: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i)),
          _NavItem(
              icon: Icons.wifi_tethering_outlined,
              activeIcon: Icons.wifi_tethering_rounded,
              label: 'Scan',
              index: 1,
              selected: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i)),
          _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet_rounded,
              label: 'Earnings',
              index: 2,
              selected: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i)),
          _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              index: 3,
              selected: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, selected;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.textTertiary,
              size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }
}
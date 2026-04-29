import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../scan/scan_idle_screen.dart';
import '../mechanics/mechanics_screen.dart';
import '../profile/profile_screen.dart';

final mainNavKey = GlobalKey<MainNavigationState>();

class MainNavigation extends StatefulWidget {
  MainNavigation({Key? key}) : super(key: key ?? mainNavKey);

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomeScreenContent(),
      ScanIdleScreen(),
      MechanicsScreen(),
      ProfileScreen(),
    ];
  }

  void switchToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: _FloatingNavBar(
          selectedIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

// ── NAV ITEMS ─────────────────────────────────────────────────
class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavItem({required this.activeIcon, required this.inactiveIcon, required this.label});
}

const _navItems = [
  _NavItem(activeIcon: Icons.home_rounded, inactiveIcon: Icons.home_outlined, label: 'Home'),
  _NavItem(activeIcon: Icons.wifi_tethering_rounded, inactiveIcon: Icons.wifi_tethering_outlined, label: 'Scan'),
  _NavItem(activeIcon: Icons.handyman_rounded, inactiveIcon: Icons.handyman_outlined, label: 'Mechanics'),
  _NavItem(activeIcon: Icons.account_circle_rounded, inactiveIcon: Icons.account_circle_outlined, label: 'Profile'),
];

// ── FLOATING NAV BAR ──────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _FloatingNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _navItems.length,
          (i) => Expanded(
            child: _NavTab(
              item: _navItems[i],
              isSelected: selectedIndex == i,
              onTap: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

// ── ANIMATED TAB ──────────────────────────────────────────────
class _NavTab extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> with SingleTickerProviderStateMixin {
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
    if (widget.isSelected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavTab old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: widget.isSelected ? _scale.value : 1.0,
          child: child,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isSelected ? widget.item.activeIcon : widget.item.inactiveIcon,
              color: widget.isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 22,
            ),
            if (widget.isSelected) ...[
              const SizedBox(height: 2),
              Text(
                widget.item.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

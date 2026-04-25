import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../scan/scan_idle_screen.dart';
import '../mechanics/mechanics_screen.dart';
import '../profile/profile_screen.dart';

// Global key so any screen can switch tabs
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.navBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.8), width: 1.5),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontFamily: 'Inter',
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 0
                      ? Icons.home
                      : Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 1
                      ? Icons.bluetooth
                      : Icons.bluetooth_outlined),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 2 ? Icons.car_repair : Icons.car_repair),
                  label: 'Mechanics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 3
                      ? Icons.person
                      : Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







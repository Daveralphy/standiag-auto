import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../scan/scan_idle_screen.dart';
import '../mechanics/mechanics_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreenContent(),
      const ScanIdleScreen(),
      const MechanicsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onNavigationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onNavigationTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                    size: 24,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _selectedIndex == 1 ? Icons.search : Icons.search_outlined,
                    size: 24,
                  ),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _selectedIndex == 2 ? Icons.person : Icons.person_outline,
                    size: 24,
                  ),
                  label: 'Mechanics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _selectedIndex == 3 ? Icons.person : Icons.person_outline,
                    size: 24,
                  ),
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

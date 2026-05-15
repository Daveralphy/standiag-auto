import 'package:flutter/material.dart';
import '../home/mechanic_home_screen.dart';

class MechanicNavigation extends StatefulWidget {
  const MechanicNavigation({super.key});

  @override
  State<MechanicNavigation> createState() => _MechanicNavigationState();
}

class _MechanicNavigationState extends State<MechanicNavigation> {
  int _index = 0;

  final _screens = const [
    MechanicHomeScreen(),
    Scaffold(backgroundColor: Color(0xFF0A0A0B),
        body: Center(child: Text('Bookings', style: TextStyle(color: Colors.white)))),
    Scaffold(backgroundColor: Color(0xFF0A0A0B),
        body: Center(child: Text('Profile', style: TextStyle(color: Colors.white)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Stack(children: [
        _screens[_index],
        Positioned(
          bottom: 20, left: 20, right: 20,
          child: _FloatingNav(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
          ),
        ),
      ]),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _FloatingNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_rounded,         label: 'Home'),
    (icon: Icons.check_circle_rounded, label: 'Bookings'),
    (icon: Icons.person_rounded,       label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xEC0E0E12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 40, offset: const Offset(0, 12))],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: active ? const Color(0x21C0272D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_items[i].icon, size: 22,
                      color: active
                          ? const Color(0xFFC0272D)
                          : const Color(0xFF5E5E6A)),
                  const SizedBox(height: 3),
                  Text(_items[i].label,
                      style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: active
                              ? const Color(0xFFC0272D)
                              : const Color(0xFF5E5E6A))),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
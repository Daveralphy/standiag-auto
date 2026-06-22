// The floating pill navigation bar used on all primary screens.
// Matches the nav bar design exactly as shown in all HTML screen files.
// User nav bar items:    Scan | Home | Mechanics
// Mechanic nav bar items: Scan | Home | Users

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum NavBarItem { scan, home, third }

enum NavBarUserType { carOwner, mechanic }

class AppNavBar extends StatelessWidget {
  final NavBarItem activeItem;
  final NavBarUserType userType;
  final VoidCallback onScanTap;
  final VoidCallback onHomeTap;
  final VoidCallback onThirdTap;

  const AppNavBar({
    super.key,
    required this.activeItem,
    required this.userType,
    required this.onScanTap,
    required this.onHomeTap,
    required this.onThirdTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.navBarBottomOffset,
      left: AppSpacing.navBarSideOffset,
      right: AppSpacing.navBarSideOffset,
      child: SizedBox(
        height: AppSpacing.navBarHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.floatingNav),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.navBarBackground,
                  borderRadius: BorderRadius.circular(AppRadius.floatingNav),
                  border: Border.all(color: AppColors.navBarBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      offset: Offset(0, 8),
                      blurRadius: 32,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                _NavItem(
                  icon: _ScanIcon(
                    color: activeItem == NavBarItem.scan
                        ? Colors.white
                        : AppColors.textMuted,
                    size: activeItem == NavBarItem.scan ? 18 : 20,
                  ),
                  label: 'Scan',
                  isActive: activeItem == NavBarItem.scan,
                  onTap: onScanTap,
                ),
                _NavItem(
                  icon: _HomeIcon(
                    color: activeItem == NavBarItem.home
                        ? Colors.white
                        : AppColors.textMuted,
                    size: activeItem == NavBarItem.home ? 18 : 20,
                  ),
                  label: 'Home',
                  isActive: activeItem == NavBarItem.home,
                  onTap: onHomeTap,
                ),
                _NavItem(
                  icon: userType == NavBarUserType.carOwner
                      ? _MechanicIcon(
                          color: activeItem == NavBarItem.third
                              ? Colors.white
                              : AppColors.textMuted,
                          size: activeItem == NavBarItem.third ? 18 : 20,
                        )
                      : _UsersIcon(
                          color: activeItem == NavBarItem.third
                              ? Colors.white
                              : AppColors.textMuted,
                          size: activeItem == NavBarItem.third ? 18 : 20,
                        ),
                  label: userType == NavBarUserType.carOwner ? 'Mechanics' : 'Users',
                  isActive: activeItem == NavBarItem.third,
                  onTap: onThirdTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: isActive
            ? _ActiveItem(icon: icon, label: label)
            : _InactiveItem(icon: icon, label: label),
      ),
    );
  }
}

class _ActiveItem extends StatelessWidget {
  final Widget icon;
  final String label;
  const _ActiveItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: AppSpacing.navBarActiveSize,
          height: AppSpacing.navBarActiveSize,
          margin: const EdgeInsets.only(bottom: 4),
          transform: Matrix4.translationValues(0, -AppSpacing.navBarActiveProtrude, 0),
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.navBarActiveGlow,
                offset: Offset(0, -4),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Color(0x66E8281E),
                offset: Offset(0, 6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Center(child: icon),
        ),
        Transform.translate(
          offset: const Offset(0, -AppSpacing.navBarActiveProtrude),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: AppTypography.labelActive,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _InactiveItem extends StatelessWidget {
  final Widget icon;
  final String label;
  const _InactiveItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        icon,
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelInactive,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _ScanIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _ScanIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ScanPainter(color: color)),
    );
  }
}

class _ScanPainter extends CustomPainter {
  final Color color;
  const _ScanPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round;
    final double s = size.width / 24;
    // Top-left corner
    canvas.drawLine(Offset(3 * s, 7 * s), Offset(3 * s, 4 * s), paint);
    canvas.drawLine(Offset(3 * s, 4 * s), Offset(7 * s, 4 * s), paint);
    // Top-right corner
    canvas.drawLine(Offset(17 * s, 4 * s), Offset(20 * s, 4 * s), paint);
    canvas.drawLine(Offset(20 * s, 4 * s), Offset(20 * s, 7 * s), paint);
    // Bottom-right corner
    canvas.drawLine(Offset(20 * s, 17 * s), Offset(20 * s, 20 * s), paint);
    canvas.drawLine(Offset(20 * s, 20 * s), Offset(17 * s, 20 * s), paint);
    // Bottom-left corner
    canvas.drawLine(Offset(7 * s, 20 * s), Offset(4 * s, 20 * s), paint);
    canvas.drawLine(Offset(4 * s, 20 * s), Offset(4 * s, 17 * s), paint);
    // Scan line
    canvas.drawLine(Offset(6 * s, 12 * s), Offset(18 * s, 12 * s), paint);
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.color != color;
}

class _HomeIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _HomeIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HomePainter(color: color)),
    );
  }
}

class _HomePainter extends CustomPainter {
  final Color color;
  const _HomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeJoin = StrokeJoin.round;
    final double s = size.width / 24;
    final Path path = Path()
      ..moveTo(3 * s, 10.5 * s)
      ..lineTo(12 * s, 3 * s)
      ..lineTo(21 * s, 10.5 * s)
      ..lineTo(21 * s, 20 * s)
      ..lineTo(15 * s, 20 * s)
      ..lineTo(15 * s, 16 * s)
      ..lineTo(9 * s, 16 * s)
      ..lineTo(9 * s, 20 * s)
      ..lineTo(3 * s, 20 * s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HomePainter old) => old.color != color;
}

class _MechanicIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _MechanicIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.121 2.121 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"
          stroke="${_toHex(color)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>''',
      width: size,
      height: size,
    );
  }
}

class _UsersIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _UsersIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" stroke="${_toHex(color)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
        <circle cx="9" cy="7" r="4" stroke="${_toHex(color)}" stroke-width="1.8"/>
        <path d="M23 21v-2a4 4 0 0 0-3-3.87" stroke="${_toHex(color)}" stroke-width="1.8" stroke-linecap="round"/>
        <path d="M16 3.13a4 4 0 0 1 0 7.75" stroke="${_toHex(color)}" stroke-width="1.8" stroke-linecap="round"/>
      </svg>''',
      width: size,
      height: size,
    );
  }
}

// Converts a Flutter Color to a CSS hex string for inline SVG use.
// Uses component accessors to avoid deprecated .value property.
String _toHex(Color color) {
  final int r = (color.r * 255).round();
  final int g = (color.g * 255).round();
  final int b = (color.b * 255).round();
  return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
}
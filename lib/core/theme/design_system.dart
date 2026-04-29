import 'package:flutter/material.dart';
import 'app_colors.dart';

// â”€â”€ TYPOGRAPHY â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppTypography {
  AppTypography._();

  // Display â€” hero numbers, big stats
  static const display = TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'Inter', letterSpacing: -1.0, height: 1.1);

  // Heading â€” screen titles, card headings
  static const h1 = TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter', letterSpacing: -0.5, height: 1.2);
  static const h2 = TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter', letterSpacing: -0.3, height: 1.2);
  static const h3 = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Inter', letterSpacing: -0.2, height: 1.3);
  static const h4 = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Inter', height: 1.3);

  // Body
  static const bodyLg = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: 'Inter', height: 1.6);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: 'Inter', height: 1.55);
  static const bodySm = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: 'Inter', height: 1.5);

  // Label
  static const labelLg = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Inter');
  static const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Inter');
  static const labelSm = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, fontFamily: 'Inter', letterSpacing: 1.5);

  // Caption
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary, fontFamily: 'Inter', height: 1.4);
  static const captionBold = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, fontFamily: 'Inter');

  // Button
  static const button = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Inter', letterSpacing: 0.3);
  static const buttonSm = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Inter', letterSpacing: 0.2);

  // Overline â€” section labels like ACCOUNT, SETTINGS
  static const overline = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, fontFamily: 'Inter', letterSpacing: 1.8);
}

// â”€â”€ SPACING â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;

  static const SizedBox hxs = SizedBox(height: xs);
  static const SizedBox hsm = SizedBox(height: sm);
  static const SizedBox hmd = SizedBox(height: md);
  static const SizedBox hbase = SizedBox(height: base);
  static const SizedBox hlg = SizedBox(height: lg);
  static const SizedBox hxl = SizedBox(height: xl);
  static const SizedBox hxxl = SizedBox(height: xxl);

  static const SizedBox wxs = SizedBox(width: xs);
  static const SizedBox wsm = SizedBox(width: sm);
  static const SizedBox wmd = SizedBox(width: md);
  static const SizedBox wbase = SizedBox(width: base);
  static const SizedBox wlg = SizedBox(width: lg);
  static const SizedBox wxl = SizedBox(width: xl);
}

// â”€â”€ RADIUS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
  static const BorderRadius topXl = BorderRadius.vertical(top: Radius.circular(xl));
  static const BorderRadius topXxl = BorderRadius.vertical(top: Radius.circular(xxl));
}

// â”€â”€ SHADOWS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6)),
  ];

  static List<BoxShadow> get advisoryGlow => [
    BoxShadow(color: AppColors.advisory.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6)),
  ];
}

// â”€â”€ BORDERS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppBorders {
  AppBorders._();

  static Border get subtle => Border.all(color: AppColors.borderSubtle);
  static Border get default_ => Border.all(color: AppColors.border);
  static Border get primary => Border.all(color: AppColors.primaryBorder);
  static Border get primaryStrong => Border.all(color: AppColors.primary, width: 1.5);
}

// â”€â”€ ICON BUTTON â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Standard 40x40 icon button used in all headers
class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? borderColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: borderColor ?? AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

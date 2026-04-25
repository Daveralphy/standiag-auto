import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'add_vehicle_screen.dart';
import '../navigation/main_navigation.dart';

class FirstVehicleScreen extends StatelessWidget {
  const FirstVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              _buildCarIllustration(),
              const SizedBox(height: 32),
              _buildHeadline(),
              const SizedBox(height: 8),
              _buildSubtext(),
              const SizedBox(height: 24),
              _buildFeatureList(),
              const SizedBox(height: 28),
              _buildCTAButton(context),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => MainNavigation()),
                    (route) => false,
                  ),
                  child: const Text("I'll add a vehicle later →",
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                          fontFamily: 'Inter')),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCarIllustration() {
    return Center(
      child: Container(
        width: double.infinity, height: 180,
        decoration: BoxDecoration(
          color: AppColors.vehicleCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryBorder),
          boxShadow: [BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 28)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200, height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 40, spreadRadius: 10)],
              ),
            ),
            CustomPaint(
              size: const Size(280, 120),
              painter: _CarPainter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('ONE MORE STEP',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 2,
                fontFamily: 'Inter')),
        SizedBox(height: 10),
        Text('Add your first',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
                letterSpacing: -0.5)),
        Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'vehicle ',
                style: TextStyle(color: AppColors.primary)),
            TextSpan(
                text: 'to begin.',
                style: TextStyle(color: AppColors.textPrimary)),
          ]),
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildSubtext() {
    return const Text(
      'StanDiag needs to know your car to give you accurate diagnostics and smart results.',
      style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
          fontFamily: 'Inter'),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Accurate fault code interpretation',
      'Personalised maintenance schedule',
      'Service history stored per vehicle',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: features
            .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Text(f,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
      ),
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.40),
              blurRadius: 20,
              offset: const Offset(0, 8))],
        ),
        child: const Center(
          child: Text('ADD MY VEHICLE',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                  fontFamily: 'Inter')),
        ),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A0608)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2 + 10;

    final bodyPath = Path();
    bodyPath.moveTo(cx - 110, cy + 10);
    bodyPath.lineTo(cx - 110, cy - 10);
    bodyPath.quadraticBezierTo(cx - 108, cy - 30, cx - 80, cy - 44);
    bodyPath.lineTo(cx - 40, cy - 60);
    bodyPath.quadraticBezierTo(cx - 20, cy - 68, cx + 10, cy - 68);
    bodyPath.lineTo(cx + 60, cy - 68);
    bodyPath.quadraticBezierTo(cx + 85, cy - 68, cx + 96, cy - 52);
    bodyPath.lineTo(cx + 110, cy - 30);
    bodyPath.lineTo(cx + 110, cy + 10);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, borderPaint);

    final windowPaint = Paint()
      ..color = const Color(0xFF0A0A0B)
      ..style = PaintingStyle.fill;
    final windowPath = Path();
    windowPath.moveTo(cx - 74, cy - 44);
    windowPath.lineTo(cx - 40, cy - 62);
    windowPath.quadraticBezierTo(cx - 22, cy - 68, cx + 10, cy - 68);
    windowPath.lineTo(cx + 60, cy - 68);
    windowPath.quadraticBezierTo(cx + 82, cy - 68, cx + 90, cy - 54);
    windowPath.lineTo(cx + 72, cy - 44);
    windowPath.close();
    canvas.drawPath(windowPath, windowPaint);

    final wheelPaint = Paint()
      ..color = const Color(0xFF111118)
      ..style = PaintingStyle.fill;
    final wheelBorder = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(cx - 65, cy + 24), 22, wheelPaint);
    canvas.drawCircle(Offset(cx - 65, cy + 24), 22, wheelBorder);
    canvas.drawCircle(Offset(cx - 65, cy + 24), 10,
        Paint()
          ..color = const Color(0xFF1E1E24)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx + 65, cy + 24), 22, wheelPaint);
    canvas.drawCircle(Offset(cx + 65, cy + 24), 22, wheelBorder);
    canvas.drawCircle(Offset(cx + 65, cy + 24), 10,
        Paint()
          ..color = const Color(0xFF1E1E24)
          ..style = PaintingStyle.fill);

    final shadowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, cy + 42), width: 220, height: 14),
        shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}







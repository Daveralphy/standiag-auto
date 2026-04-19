import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import 'scan_connecting_screen.dart';
import '../onboarding/obd_guide_screen.dart';

class ScanIdleScreen extends StatefulWidget {
  const ScanIdleScreen({super.key});

  @override
  State<ScanIdleScreen> createState() => _ScanIdleScreenState();
}

class _ScanIdleScreenState extends State<ScanIdleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 8),
              _buildVehiclePill(),
              const SizedBox(height: 32),
              _buildGauge(context),
              const SizedBox(height: 16),
              const Text(
                'Ready to diagnose.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Plug in your OBD-II adapter, make sure\nBluetooth is on, then tap the button above.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              _buildStatusCards(),
              const SizedBox(height: 20),
              _buildHelperCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Diagnostic Scan',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildVehiclePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Toyota Corolla 2016',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildGauge(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const ScanConnectingScreen()),
          ),
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 260, height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.08),
                          width: 1),
                    ),
                  ),
                ),
                Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.12),
                        width: 1),
                  ),
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _GaugePainter(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'TAP TO SCAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary.withOpacity(0.85),
                        letterSpacing: 2,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCards() {
    return Column(
      children: [
        _StatusRow(
          icon: Icons.bluetooth,
          iconColor: AppColors.bluetooth,
          iconBg: AppColors.bluetooth.withOpacity(0.12),
          title: 'Bluetooth',
          subtitle: 'Enabled  •  Ready',
          dotColor: AppColors.advisory,
        ),
        const SizedBox(height: 10),
        _StatusRow(
          icon: Icons.power_outlined,
          iconColor: AppColors.textSecondary,
          iconBg: AppColors.surface,
          title: 'OBD-II Adapter',
          subtitle: 'Not detected  •  Plug in to begin',
          dotColor: AppColors.moderate,
        ),
      ],
    );
  }

  Widget _buildHelperCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.power_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'First time scanning?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You need an ELM327 Bluetooth adapter. They cost under ₦5,000 and work on any car with an OBD-II port (most cars after 2000).',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const OBDGuideScreen()),
                  ),
                  child: const Text(
                    'Where to buy one →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.65;
    const sweepAngle = math.pi * 1.22;

    final trackPaint = Paint()
      ..color = const Color(0xFF1E1E24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, trackPaint);

    final tickPaint = Paint()
      ..color = const Color(0xFF5E5E6A)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final labels = ['0', '20', '40', '60', '80', '100', '110'];
    for (int i = 0; i < labels.length; i++) {
      final angle = startAngle + (sweepAngle / (labels.length - 1)) * i;
      final outerPoint = Offset(center.dx + (radius + 2) * math.cos(angle),
          center.dy + (radius + 2) * math.sin(angle));
      final innerPoint = Offset(center.dx + (radius - 10) * math.cos(angle),
          center.dy + (radius - 10) * math.sin(angle));
      canvas.drawLine(innerPoint, outerPoint, tickPaint);

      final tp = TextPainter(
        text: TextSpan(text: labels[i],
            style: const TextStyle(color: Color(0xFF5E5E6A), fontSize: 9,
                fontWeight: FontWeight.w500)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(
          center.dx + (radius - 24) * math.cos(angle) - tp.width / 2,
          center.dy + (radius - 24) * math.sin(angle) - tp.height / 2));
    }

    final needlePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final needleEnd = Offset(
        center.dx + (radius - 30) * math.cos(startAngle),
        center.dy + (radius - 30) * math.sin(startAngle));
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 6, Paint()..color = AppColors.primary);
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFF0A0A0B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg, dotColor;
  final String title, subtitle;

  const _StatusRow({required this.icon, required this.iconColor,
      required this.iconBg, required this.title, required this.subtitle,
      required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textSecondary, fontFamily: 'Inter')),
              ],
            ),
          ),
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: dotColor, shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: dotColor.withOpacity(0.5), blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }
}

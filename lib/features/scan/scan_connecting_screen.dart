import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import 'scan_results_screen.dart';

class ScanConnectingScreen extends StatefulWidget {
  const ScanConnectingScreen({super.key});

  @override
  State<ScanConnectingScreen> createState() => _ScanConnectingScreenState();
}

class _ScanConnectingScreenState extends State<ScanConnectingScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _spinController;
  late Animation<double> _ring1;
  late Animation<double> _ring2;
  late Animation<double> _ring3;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _ring1 = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ringController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _ring2 = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ringController,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOut)));
    _ring3 = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ringController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _ringController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildVehiclePill(),
            const SizedBox(height: 32),
            _buildAnimatedRings(),
            const SizedBox(height: 24),
            const Text(
              'Searching for adapter…',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Make sure your ELM327 is plugged into the\nOBD-II port and Bluetooth is on.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                    height: 1.5, fontFamily: 'Inter'),
              ),
            ),
            const SizedBox(height: 24),
            _buildStepProgress(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDevicesFound(context),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cancel scan',
                            style: TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter')),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 12,
                              color: AppColors.textTertiary, fontFamily: 'Inter'),
                          children: [
                            TextSpan(text: "Don't have an OBD-II adapter?\n"),
                            TextSpan(text: 'Buy one for under ₦5,000 →',
                                style: TextStyle(color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Connecting to Adapter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
        ],
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
      child: const Text('Toyota Corolla 2016',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary,
              fontFamily: 'Inter')),
    );
  }

  Widget _buildAnimatedRings() {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _ringController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1.0 - _ring3.value).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _ring3.value,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.10), width: 1),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: (1.0 - _ring2.value + 0.3).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _ring2.value,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.16), width: 1),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: (1.0 - _ring1.value + 0.5).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _ring1.value,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.22), width: 1.5),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _spinController,
                builder: (context, _) {
                  return Container(
                    width: 100, height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBorder),
                      boxShadow: [BoxShadow(
                          color: AppColors.primary.withOpacity(0.18),
                          blurRadius: 20)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 26, height: 26,
                          child: CustomPaint(
                            painter: _SpinArcPainter(_spinController.value),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('ELM327',
                            style: TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace', letterSpacing: 1)),
                        const Text('OBD-II',
                            style: TextStyle(fontSize: 8,
                                color: AppColors.textTertiary,
                                fontFamily: 'Inter')),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepProgress() {
    final steps = ['BT On', 'Searching', 'Pairing', 'Init', 'Scanning'];
    const activeStep = 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final si = i ~/ 2;
            return Expanded(
              child: Container(height: 1,
                  color: si < activeStep
                      ? AppColors.primary.withOpacity(0.4)
                      : AppColors.borderSubtle),
            );
          }
          final si = i ~/ 2;
          final isDone = si < activeStep;
          final isActive = si == activeStep;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.advisoryBg
                      : isActive ? AppColors.primarySubtle
                      : AppColors.surfaceDeep,
                  border: Border.all(
                      color: isDone ? AppColors.advisory
                          : isActive ? AppColors.primary
                          : AppColors.border),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: AppColors.advisory)
                      : isActive
                          ? Container(width: 8, height: 8,
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle))
                          : Text('${si + 1}',
                              style: const TextStyle(fontSize: 10,
                                  color: AppColors.textTertiary,
                                  fontFamily: 'Inter')),
                ),
              ),
              const SizedBox(height: 4),
              Text(steps[si],
                  style: TextStyle(
                      fontSize: 9,
                      color: isActive ? AppColors.primary
                          : isDone ? AppColors.advisory
                          : AppColors.textTertiary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontFamily: 'Inter')),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDevicesFound(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DEVICES FOUND NEARBY',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScanResultsScreen())),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.bluetooth.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.bluetooth,
                      color: AppColors.bluetooth, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ELM327 OBDII',
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 2),
                      Text('Connecting…  •  Signal strong',
                          style: TextStyle(fontSize: 11,
                              color: AppColors.textSecondary, fontFamily: 'Inter')),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.moderateBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.moderateBorder)),
                  child: const Text('Connecting',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                          color: AppColors.moderate, fontFamily: 'Inter')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bluetooth_disabled_rounded,
                    color: AppColors.textTertiary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unknown BT Device',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary, fontFamily: 'Inter')),
                    SizedBox(height: 2),
                    Text('Not an OBD-II adapter',
                        style: TextStyle(fontSize: 11,
                            color: AppColors.textTertiary, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const Text('Skip',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpinArcPainter extends CustomPainter {
  final double progress;
  _SpinArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    final arc = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
        progress * 2 * math.pi, math.pi * 1.2, false, arc);
    final bt = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final m = c;
    canvas.drawLine(m, Offset(m.dx + 4, m.dy - 5), bt);
    canvas.drawLine(Offset(m.dx + 4, m.dy - 5), Offset(m.dx - 3, m.dy + 3), bt);
    canvas.drawLine(m, Offset(m.dx + 4, m.dy + 5), bt);
    canvas.drawLine(Offset(m.dx + 4, m.dy + 5), Offset(m.dx - 3, m.dy - 3), bt);
  }

  @override
  bool shouldRepaint(_SpinArcPainter old) => old.progress != progress;
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';

class OnboardingSlide3 extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingSlide3({
    super.key,
    required this.currentPage,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // â”€â”€ Progress dots â€” no Skip on last screen â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _ProgressDot(state: _DotState.done),
                  const SizedBox(width: 5),
                  _ProgressDot(state: _DotState.done),
                  const SizedBox(width: 5),
                  _ProgressDot(state: _DotState.active),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // â”€â”€ Map illustration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              flex: 58,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _MapCard(),
              ),
            ),
            // â”€â”€ Bottom section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              flex: 42,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                        children: [
                          TextSpan(text: 'Find your\n'),
                          TextSpan(
                            text: 'mechanic',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(text: ' near you'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'See verified mechanics nearby. Call or\nWhatsApp with your fault pre-filled.',
                      style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary, height: 1.55),
                    ),
                    const SizedBox(height: 24),
                    // GET STARTED button
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onNext,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadius.lgAll,
                          boxShadow: AppShadows.primaryGlow,
                        ),
                        child: Center(
                          child: Text('GET STARTED',
                              style: AppTypography.button.copyWith(
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Sign in link
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onSkip,
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.textTertiary),
                            children: const [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Dot state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
enum _DotState { active, done }

class _ProgressDot extends StatelessWidget {
  final _DotState state;
  const _ProgressDot({required this.state});

  @override
  Widget build(BuildContext context) {
    final isActive = state == _DotState.active;
    final isDone = state == _DotState.done;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : isDone
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.border,
        borderRadius: isActive ? AppRadius.smAll : AppRadius.fullAll,
      ),
    );
  }
}

// â”€â”€ Map card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0C1520),
        ),
        child: Stack(
          children: [
            // Map grid
            CustomPaint(
              painter: _MapGridPainter(),
              child: const SizedBox.expand(),
            ),
            // Roads
            Positioned(
              top: 0, bottom: 0,
              left: 0, right: 0,
              child: CustomPaint(painter: _RoadsPainter()),
            ),
            // Radar circles
            const Center(child: _RadarCircles()),
            // User dot
            const Center(child: _UserDot()),
            // Mechanic pins
            const Positioned(
              top: 80, left: 40,
              child: _MechPin(label: 'Ade Mech Â· 0.3km', primary: true),
            ),
            const Positioned(
              top: 55, right: 30,
              child: _MechPin(label: 'Kayode Auto', primary: false),
            ),
            const Positioned(
              top: 145, left: 60,
              child: _MechPin(label: 'Lanre Workshop', primary: false),
            ),
            // Cards overlay at bottom
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _MechCardsOverlay(),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Map grid painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1E90FF).withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override bool shouldRepaint(_) => false;
}

// â”€â”€ Roads painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 8;
    // Horizontal roads
    canvas.drawLine(Offset(0, size.height * 0.38),
        Offset(size.width, size.height * 0.38), p);
    canvas.drawLine(Offset(0, size.height * 0.62),
        Offset(size.width, size.height * 0.62), p);
    // Vertical roads
    canvas.drawLine(Offset(size.width * 0.42, 0),
        Offset(size.width * 0.42, size.height), p);
    canvas.drawLine(Offset(size.width * 0.68, 0),
        Offset(size.width * 0.68, size.height), p);
  }
  @override bool shouldRepaint(_) => false;
}

// â”€â”€ Radar circles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RadarCircles extends StatelessWidget {
  const _RadarCircles();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, height: 200,
      child: CustomPaint(painter: _RadarPainter()),
    );
  }
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, size.width / 2, paint);
    paint.color = AppColors.primary.withValues(alpha: 0.12);
    canvas.drawCircle(center, size.width / 3, paint);
    paint.color = AppColors.primary.withValues(alpha: 0.08);
    canvas.drawCircle(center, size.width / 5, paint);
  }
  @override bool shouldRepaint(_) => false;
}

// â”€â”€ User dot â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _UserDot extends StatelessWidget {
  const _UserDot();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bluetooth.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.bluetooth.withValues(alpha: 0.2)),
          ),
        ),
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bluetooth,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(
              color: AppColors.bluetooth.withValues(alpha: 0.7),
              blurRadius: 14,
            )],
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Mechanic pin â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MechPin extends StatelessWidget {
  final String label;
  final bool primary;
  const _MechPin({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primary ? AppColors.primary : AppColors.surfaceCard,
            borderRadius: AppRadius.smAll,
            border: primary ? null : Border.all(color: AppColors.border),
            boxShadow: primary ? AppShadows.primaryGlow : null,
          ),
          child: Text(label,
              style: AppTypography.caption.copyWith(
                  color: primary ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9)),
        ),
        Container(
          width: 4, height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Mechanic cards overlay â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MechCardsOverlay extends StatelessWidget {
  const _MechCardsOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF0C1520), Color(0xFF0C1520), Colors.transparent],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MechCard(
            initials: 'AO',
            avatarColor: const Color(0xFF8A1B20),
            name: 'Ade Okonkwo Auto',
            detail: 'Specialist Workshop Â· Lagos Island',
            rating: 4.8,
            reviews: 729,
          ),
          const SizedBox(height: 8),
          _MechCard(
            initials: 'KA',
            avatarColor: const Color(0xFF1A3A20),
            name: 'Kayode Auto Workshop',
            detail: 'General Repairs Â· 5.6km Â· Victoria Island',
            rating: 4.6,
            reviews: 83,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.advisory, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('Fault details auto-filled â€” pre-sent to the mechanic',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.advisory, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Mechanic card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MechCard extends StatelessWidget {
  final String initials;
  final Color avatarColor;
  final String name;
  final String detail;
  final double rating;
  final int reviews;

  const _MechCard({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.detail,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xF5111114),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800,
                      color: Colors.white, fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.label.copyWith(
                        color: AppColors.textPrimary, fontSize: 12)),
                Text(detail,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary),
                    overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 11),
                    const SizedBox(width: 3),
                    Text(rating.toStringAsFixed(1),
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 3),
                    Text('( reviews)',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Buttons
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.smAll,
                ),
                child: Text('Call',
                    style: AppTypography.caption.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.whatsApp.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smAll,
                  border: Border.all(
                      color: AppColors.whatsApp.withValues(alpha: 0.3)),
                ),
                child: Text('WA',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.whatsApp,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = sw / 430;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 48 * s, 20 * s, 0),
              child: SizedBox(
                height: 28 * s,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: active ? 20 * s : 6 * s,
                          height: 6 * s,
                          margin: EdgeInsets.only(right: 8 * s),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : const Color(0xFF2A2A32),
                            borderRadius: BorderRadius.circular(3 * s),
                          ),
                        );
                      }),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _skip,
                        child: Text('Skip',
                            style: TextStyle(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _SlideDiagnose(s: s),
                  _SlideUnderstand(s: s),
                  _SlideFind(s: s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideDiagnose extends StatelessWidget {
  final double s;
  const _SlideDiagnose({required this.s});

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(height: sh * 0.11),
        // ── Illustration ─────────────────────────────────
        SizedBox(
          height: sh * 0.30,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28 * s),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 20, offset: const Offset(0, 4),
                  )],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * s),
                  child: Padding(
                    padding: EdgeInsets.all(16 * s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10 * s),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 13 * s),
                              SizedBox(width: 6 * s),
                              Text('OBD SCAN  •  REALTIME',
                                  style: TextStyle(fontSize: 9 * s, fontWeight: FontWeight.w700,
                                      color: Colors.white, letterSpacing: 0.6, fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                        SizedBox(height: 12 * s),
                        _DtcRow(s: s, code: 'P0301', label: 'Cylinder 1 Misfire', color: AppColors.critical),
                        _DtcRow(s: s, code: 'P0420', label: 'Catalyst Efficiency Low', color: AppColors.critical),
                        _DtcRow(s: s, code: 'P0171', label: 'System Too Lean B1', color: AppColors.moderate),
                        _DtcRow(s: s, code: 'B1234', label: 'Battery Voltage Low', color: AppColors.advisory),
                        SizedBox(height: 12 * s),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
                          decoration: BoxDecoration(
                            color: AppColors.criticalBg,
                            borderRadius: BorderRadius.circular(8 * s),
                            border: Border.all(color: AppColors.criticalBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 13 * s),
                              SizedBox(width: 6 * s),
                              Text('4 FAULT CODES DETECTED',
                                  style: TextStyle(fontSize: 9 * s, fontWeight: FontWeight.w700,
                                      color: AppColors.primaryLight, letterSpacing: 0.6, fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: sh * 0.11),
        // ── Text section ──────────────────────────────────
        _BottomGroup(
          s: s, isLast: false,
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 32 * s, fontWeight: FontWeight.w900,
                  fontFamily: 'Inter', letterSpacing: -0.3, height: 1.2,
                  color: AppColors.textPrimary),
              children: const [
                TextSpan(text: 'Diagnose your\ncar '),
                TextSpan(text: 'instantly', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
          body: 'Connect via Bluetooth to your OBD-II adapter. Read fault codes and live data in seconds.',
        ),
        const Spacer(),
      ],
    );
  }
}

class _SlideUnderstand extends StatelessWidget {
  final double s;
  const _SlideUnderstand({required this.s});

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(height: sh * 0.11),
        // ── Illustration ─────────────────────────────────
        SizedBox(
          height: sh * 0.30,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28 * s),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.vehicleCard,
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(color: AppColors.primaryBorder),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 20, offset: const Offset(0, 4),
                  )],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * s),
                  child: Padding(
                    padding: EdgeInsets.all(16 * s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 22 * s, height: 22 * s,
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(6 * s),
                              ),
                              child: Center(child: Text('🤖', style: TextStyle(fontSize: 12 * s))),
                            ),
                            SizedBox(width: 8 * s),
                            Text('AI ANALYSIS',
                                style: TextStyle(fontSize: 10 * s, fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary, letterSpacing: 0.7, fontFamily: 'Inter')),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(4 * s),
                                border: Border.all(color: AppColors.primaryBorder),
                              ),
                              child: Text('GPT-4o',
                                  style: TextStyle(fontSize: 8 * s, fontWeight: FontWeight.w600,
                                      color: AppColors.primary, fontFamily: 'Inter')),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * s),
                        _FaultAnalysisCard(s: s, code: 'P0301', severity: '⚠ CRITICAL',
                            severityColor: AppColors.primary, severityBg: AppColors.criticalBg,
                            severityBorder: AppColors.criticalBorder,
                            description: "Cylinder 1 misfiring. Fuel not burning fully — rough idle and power loss.",
                            tags: const ['Engine', 'Ignition']),
                        SizedBox(height: 6 * s),
                        _FaultAnalysisCard(s: s, code: 'P0420', severity: '⚠ CRITICAL',
                            severityColor: AppColors.primary, severityBg: AppColors.criticalBg,
                            severityBorder: AppColors.criticalBorder,
                            description: 'Catalytic converter efficiency below threshold.',
                            tags: const ['Exhaust', 'Emissions']),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: sh * 0.11),
        // ── Text section ──────────────────────────────────
        _BottomGroup(
          s: s, isLast: false,
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 32 * s, fontWeight: FontWeight.w900,
                  fontFamily: 'Inter', letterSpacing: -0.3, height: 1.2,
                  color: AppColors.textPrimary),
              children: const [
                TextSpan(text: 'Understand\nevery '),
                TextSpan(text: 'fault', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
          body: 'AI turns raw fault codes into plain language. Know the cause, urgency, and exactly what to do.',
        ),
        const Spacer(),
      ],
    );
  }
}

class _SlideFind extends StatelessWidget {
  final double s;
  const _SlideFind({required this.s});

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(height: sh * 0.11),
        // ── Illustration ─────────────────────────────────
        SizedBox(
          height: sh * 0.30,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1420),
                        borderRadius: BorderRadius.circular(14 * s),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14 * s),
                        child: Stack(
                          children: [
                            Positioned.fill(child: CustomPaint(painter: _MapGrid(s: s))),
                            const Center(child: _UserDot()),
                            Positioned(left: 20 * s, top: 14 * s, child: _Pin(label: 'Ade Mech · 0.8km', primary: true, s: s)),
                            Positioned(right: 16 * s, top: 10 * s, child: _Pin(label: 'Kayode Auto', primary: false, s: s)),
                            Positioned(right: 14 * s, bottom: 16 * s, child: _Pin(label: 'Lanre Workshop', primary: false, s: s)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _MechCard(s: s, initials: 'AO', name: 'Ade Okonkwo Auto',
                      detail: 'Toyota specialist  •  0.8 km', stars: 5, btnLabel: 'Call', btnPrimary: true),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: sh * 0.11),
        // ── Text section ──────────────────────────────────
        _BottomGroup(
          s: s, isLast: true,
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 32 * s, fontWeight: FontWeight.w900,
                  fontFamily: 'Inter', letterSpacing: -0.3, height: 1.2,
                  color: AppColors.textPrimary),
              children: const [
                TextSpan(text: 'Find your\n'),
                TextSpan(text: 'mechanic', style: TextStyle(color: AppColors.primary)),
                TextSpan(text: ' near you'),
              ],
            ),
          ),
          body: 'See verified mechanics nearby. Call or WhatsApp them with your fault codes pre-filled.',
        ),
        const Spacer(),
      ],
    );
  }
}

class _BottomGroup extends StatelessWidget {
  final double s;
  final bool isLast;
  final Widget title;
  final String body;

  const _BottomGroup({required this.s, required this.isLast, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_OnboardingScreenState>();
    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          SizedBox(height: 12 * s),
          Text(body,
              style: TextStyle(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.55,
                  fontFamily: 'Inter')),
          SizedBox(height: 24 * s),
          GestureDetector(
            onTap: () => state?._next(),
            child: Container(
              width: double.infinity,
              height: 56 * s,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14 * s),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  isLast ? 'GET STARTED' : 'NEXT',
                  style: TextStyle(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontFamily: 'Inter'),
                ),
              ),
            ),
          ),
          if (isLast) ...[
            SizedBox(height: 14 * s),
            Center(
              child: GestureDetector(
                onTap: () => state?._skip(),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 13 * s,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter'),
                    children: const [
                      TextSpan(text: 'Already have an account?  '),
                      TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
class _FaultAnalysisCard extends StatelessWidget {
  final double s;
  final String code, severity, description;
  final Color severityColor, severityBg, severityBorder;
  final List<String> tags;

  const _FaultAnalysisCard({
    required this.s,
    required this.code,
    required this.severity,
    required this.severityColor,
    required this.severityBg,
    required this.severityBorder,
    required this.description,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: severityBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                decoration: BoxDecoration(color: severityBg, borderRadius: BorderRadius.circular(4 * s)),
                child: Text(code,
                    style: TextStyle(fontSize: 8 * s, fontWeight: FontWeight.w700, color: severityColor, fontFamily: 'monospace')),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5 * s, vertical: 2 * s),
                decoration: BoxDecoration(
                  color: severityBg,
                  borderRadius: BorderRadius.circular(4 * s),
                  border: Border.all(color: severityBorder),
                ),
                child: Text(severity,
                    style: TextStyle(fontSize: 6 * s, fontWeight: FontWeight.w700, color: severityColor, fontFamily: 'Inter')),
              ),
            ],
          ),
          SizedBox(height: 5 * s),
          Text(description,
              style: TextStyle(fontSize: 7.5 * s, color: AppColors.textSecondary, height: 1.45, fontFamily: 'Inter')),
          SizedBox(height: 5 * s),
          Wrap(
            spacing: 3 * s,
            runSpacing: 3 * s,
            children: tags
                .map((t) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 2 * s),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDeep,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(t, style: TextStyle(fontSize: 6.5 * s, color: AppColors.textSecondary, fontFamily: 'Inter')),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MechCard extends StatelessWidget {
  final double s;
  final String initials, name, detail, btnLabel;
  final int stars;
  final bool btnPrimary;

  const _MechCard({required this.s, required this.initials, required this.name, required this.detail, required this.stars, required this.btnLabel, required this.btnPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 11 * s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13 * s),
        border: Border.all(color: btnPrimary ? AppColors.primaryBorder : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38 * s, height: 38 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: btnPrimary ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
              color: btnPrimary ? null : AppColors.surfaceDeep,
              border: btnPrimary ? null : Border.all(color: AppColors.border),
            ),
            child: Center(child: Text(initials, style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w800, color: btnPrimary ? Colors.white : AppColors.textSecondary, fontFamily: 'Inter'))),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Inter')),
                Text(detail, style: TextStyle(fontSize: 9 * s, color: AppColors.textSecondary, fontFamily: 'Inter')),
                Row(children: List.generate(5, (i) => Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.gold, size: 9 * s))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: btnPrimary ? AppColors.primary : AppColors.whatsApp.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10 * s),
              border: btnPrimary ? null : Border.all(color: AppColors.whatsApp.withValues(alpha: 0.4)),
            ),
            child: Text(btnLabel, style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w700, color: btnPrimary ? Colors.white : AppColors.whatsApp, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }
}


class _DtcRow extends StatelessWidget {
  final double s;
  final String code, label;
  final Color color;
  const _DtcRow({required this.s, required this.code, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33 * s,
      margin: EdgeInsets.symmetric(horizontal: 6 * s),
      padding: EdgeInsets.symmetric(horizontal: 7 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(width: 3 * s, height: 16 * s, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1.5))),
          SizedBox(width: 6 * s),
          Text(code, style: TextStyle(fontSize: 8.5 * s, fontWeight: FontWeight.w700, color: color, fontFamily: 'monospace')),
          SizedBox(width: 5 * s),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8.5 * s, color: AppColors.textSecondary, fontFamily: 'Inter'))),
          Container(width: 5.5 * s, height: 5.5 * s, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}



class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bluetooth.withValues(alpha: 0.08), border: Border.all(color: AppColors.bluetooth.withValues(alpha: 0.22), width: 1))),
      Container(width: 12, height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bluetooth, border: Border.all(color: Colors.white, width: 2))),
    ]);
  }
}

class _Pin extends StatelessWidget {
  final String label;
  final bool primary;
  final double s;
  const _Pin({required this.label, required this.primary, required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: primary ? 8 * s : 6 * s, vertical: primary ? 4 * s : 3 * s),
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(6 * s),
          border: primary ? null : Border.all(color: AppColors.border),
          boxShadow: primary ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 7)] : null,
        ),
        child: Text(label, style: TextStyle(fontSize: primary ? 9 * s : 8 * s, fontWeight: FontWeight.w600, color: primary ? Colors.white : AppColors.textSecondary, fontFamily: 'Inter')),
      ),
      Container(width: 4 * s, height: 4 * s, decoration: BoxDecoration(color: primary ? AppColors.primary : AppColors.textTertiary, shape: BoxShape.circle)),
    ]);
  }
}

class _MapGrid extends CustomPainter {
  final double s;
  const _MapGrid({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final g = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), g);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), g);
    }
    final r = Paint()..color = Colors.white.withValues(alpha: 0.07)..strokeWidth = 8;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), r);
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), r);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}










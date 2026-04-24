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
              padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 0),
              child: SizedBox(
                height: 20 * s,
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
            SizedBox(height: 14 * s),
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
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 10 * s),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16 * s),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 28,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16 * s),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 12 * s),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 40 * s,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12 * s),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10 * s),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 14 * s,
                                        height: 14 * s,
                                        decoration: const BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 9 * s),
                                      ),
                                      SizedBox(width: 6 * s),
                                      Text('OBD SCAN',
                                          style: TextStyle(
                                            fontSize: 10 * s,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 1.4,
                                            fontFamily: 'Inter',
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 2 * s),
                                  Text('REALTIME DIAGNOSTICS',
                                      style: TextStyle(
                                        fontSize: 6.5 * s,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.86),
                                        letterSpacing: 0.8,
                                        fontFamily: 'Inter',
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10 * s),
                          _DtcRow(s: s, code: 'P0301', label: 'Cylinder 1 Misfire', color: AppColors.critical),
                          _DtcRow(s: s, code: 'P0420', label: 'Catalyst Efficiency Low', color: AppColors.critical),
                          _DtcRow(s: s, code: 'P0171', label: 'System Too Lean B1', color: AppColors.moderate),
                          _DtcRow(s: s, code: 'B1234', label: 'Battery Voltage Low', color: AppColors.advisory),
                          _DtcRow(s: s, code: 'P0455', label: 'Evap Leak Detected', color: AppColors.moderate),
                          _DtcRow(s: s, code: 'P0128', label: 'Coolant Temp Low', color: AppColors.advisory),
                          _DtcRow(s: s, code: 'P0174', label: 'System Too Lean B2', color: AppColors.moderate),
                          _DtcRow(s: s, code: 'P0300', label: 'Random Misfire Detected', color: AppColors.critical),
                          _DtcRow(s: s, code: 'U0100', label: 'Lost ECM Communication', color: AppColors.critical),
                          _DtcRow(s: s, code: 'P0507', label: 'Idle RPM Too High', color: AppColors.advisory),
                          SizedBox(height: 10 * s),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 4 * s),
                            decoration: BoxDecoration(
                              color: AppColors.criticalBg,
                              borderRadius: BorderRadius.circular(5 * s),
                              border: Border.all(color: AppColors.criticalBorder),
                            ),
                            child: Text('4 CODES FOUND',
                                style: TextStyle(
                                  fontSize: 9 * s,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight,
                                  letterSpacing: 0.8,
                                  fontFamily: 'Inter',
                                )),
                          ),
                          SizedBox(height: 8 * s),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8 * s),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E0F13),
                              borderRadius: BorderRadius.circular(10 * s),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _PulseBar(s: s, height: 13 * s),
                                    SizedBox(width: 4 * s),
                                    _PulseBar(s: s, height: 10 * s),
                                    SizedBox(width: 4 * s),
                                    _PulseBar(s: s, height: 16 * s),
                                    SizedBox(width: 4 * s),
                                    _PulseBar(s: s, height: 11 * s),
                                    SizedBox(width: 4 * s),
                                    _PulseBar(s: s, height: 8 * s),
                                  ],
                                ),
                                SizedBox(height: 6 * s),
                                Text('DIAGNOSTIC ACTIVE',
                                    style: TextStyle(
                                      fontSize: 7 * s,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textTertiary,
                                      letterSpacing: 0.9,
                                      fontFamily: 'Inter',
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 30 * s,
                            margin: EdgeInsets.symmetric(horizontal: 6 * s),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16161C),
                              borderRadius: BorderRadius.circular(7 * s),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 16 * s,
                                  height: 16 * s,
                                  decoration: BoxDecoration(
                                    color: AppColors.bluetooth.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.bluetooth, color: AppColors.bluetooth, size: 10 * s),
                                ),
                                SizedBox(width: 5 * s),
                                Text('BLUETOOTH ACTIVE',
                                    style: TextStyle(
                                      fontSize: 9 * s,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.bluetooth,
                                      letterSpacing: 0.6,
                                      fontFamily: 'Inter',
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(height: 4 * s),
                          Text('ELM327 Adapter  •  OBD-II port',
                              style: TextStyle(fontSize: 8 * s, color: AppColors.textTertiary, fontFamily: 'Inter')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _BottomGroup(
          s: s,
          isLast: false,
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 40 * s, fontWeight: FontWeight.w800, fontFamily: 'Inter', letterSpacing: -0.4, height: 1.2, color: AppColors.textPrimary),
              children: const [
                TextSpan(text: 'Diagnose your\ncar '),
                TextSpan(text: 'instantly', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
          body: 'Connect via Bluetooth to your OBD-II adapter. Read fault codes and live sensor data in seconds.',
        ),
      ],
    );
  }
}

class _SlideUnderstand extends StatelessWidget {
  final double s;
  const _SlideUnderstand({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 10 * s),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.vehicleCard,
                borderRadius: BorderRadius.circular(16 * s),
                border: Border.all(color: AppColors.primaryBorder),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 28, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16 * s),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 12 * s),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── TOP SECTION ──
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // AI header
                          Row(
                            children: [
                              Container(
                                width: 20 * s, height: 20 * s,
                                decoration: BoxDecoration(color: AppColors.primarySubtle, borderRadius: BorderRadius.circular(5 * s)),
                                child: Center(child: Text('🤖', style: TextStyle(fontSize: 11 * s))),
                              ),
                              SizedBox(width: 6 * s),
                              Expanded(
                                child: Text('AI ANALYSIS',
                                    style: TextStyle(fontSize: 9 * s, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.7, fontFamily: 'Inter')),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5 * s, vertical: 2 * s),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  borderRadius: BorderRadius.circular(4 * s),
                                  border: Border.all(color: AppColors.primaryBorder),
                                ),
                                child: Text('GPT-4o',
                                    style: TextStyle(fontSize: 7 * s, fontWeight: FontWeight.w600, color: AppColors.primary, fontFamily: 'Inter')),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * s),
                          // ── FAULT CARD 1: P0301 ──
                          _FaultAnalysisCard(
                            s: s,
                            code: 'P0301',
                            severity: '⚠ CRITICAL',
                            severityColor: AppColors.primary,
                            severityBg: AppColors.criticalBg,
                            severityBorder: AppColors.criticalBorder,
                            description: "Your engine's cylinder 1 is misfiring. Fuel not burning fully, causing rough idle and power loss.",
                            tags: const ['Engine', 'Workshop', 'Ignition'],
                          ),
                          SizedBox(height: 5 * s),
                          // ── FAULT CARD 2: P0420 ──
                          _FaultAnalysisCard(
                            s: s,
                            code: 'P0420',
                            severity: '⚠ CRITICAL',
                            severityColor: AppColors.primary,
                            severityBg: AppColors.criticalBg,
                            severityBorder: AppColors.criticalBorder,
                            description: 'Catalytic converter efficiency is below threshold. Exhaust emissions elevated.',
                            tags: const ['Exhaust', 'Emissions', 'Catalyst'],
                          ),
                          SizedBox(height: 5 * s),
                          // ── FAULT CARD 3: P0171 ──
                          _FaultAnalysisCard(
                            s: s,
                            code: 'P0171',
                            severity: '● MODERATE',
                            severityColor: AppColors.moderate,
                            severityBg: AppColors.moderateBg,
                            severityBorder: AppColors.moderateBorder,
                            description: 'Air-fuel mixture too lean on Bank 1. Check MAF sensor and vacuum lines.',
                            tags: const ['Fuel', 'MAF', 'Vacuum'],
                          ),
                          SizedBox(height: 5 * s),
                          // ── FAULT CARD 4: P0128 ──
                          _FaultAnalysisCard(
                            s: s,
                            code: 'P0128',
                            severity: '○ ADVISORY',
                            severityColor: AppColors.advisory,
                            severityBg: AppColors.advisoryBg,
                            severityBorder: AppColors.advisoryBorder,
                            description: 'Engine coolant temperature below thermostat regulating temperature.',
                            tags: const ['Cooling', 'Thermostat'],
                          ),
                          SizedBox(height: 5 * s),
                          // ── FAULT CARD 5: P0455 ──
                          _FaultAnalysisCard(
                            s: s,
                            code: 'P0455',
                            severity: '● MODERATE',
                            severityColor: AppColors.moderate,
                            severityBg: AppColors.moderateBg,
                            severityBorder: AppColors.moderateBorder,
                            description: 'Large leak detected in evaporative emission control system. Check fuel cap.',
                            tags: const ['EVAP', 'Fuel Cap', 'Emissions'],
                          ),
                        ],
                      ),
                      // ── BOTTOM SECTION ──
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PROBABLE CAUSES',
                              style: TextStyle(fontSize: 7 * s, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1, fontFamily: 'Inter')),
                          SizedBox(height: 5 * s),
                          _Cause(s: s, n: '01', text: 'Faulty spark plug or ignition coil'),
                          SizedBox(height: 3 * s),
                          _Cause(s: s, n: '02', text: 'Fuel injector clog or failure'),
                          SizedBox(height: 3 * s),
                          _Cause(s: s, n: '03', text: 'Low compression — worn valve seats'),
                          SizedBox(height: 8 * s),
                          Text('URGENCY ASSESSMENT',
                              style: TextStyle(fontSize: 6 * s, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1, fontFamily: 'Inter')),
                          SizedBox(height: 5 * s),
                          _Bar(s: s, label: 'Critical', value: 0.85, color: AppColors.critical),
                          SizedBox(height: 4 * s),
                          _Bar(s: s, label: 'Moderate', value: 0.50, color: AppColors.moderate),
                          SizedBox(height: 4 * s),
                          _Bar(s: s, label: 'Advisory', value: 0.20, color: AppColors.advisory),
                          SizedBox(height: 8 * s),
                          Row(
                            children: [
                              Expanded(child: _ActionChip(s: s, label: 'Scan coils')),
                              SizedBox(width: 6 * s),
                              Expanded(child: _ActionChip(s: s, label: 'Check injectors')),
                              SizedBox(width: 6 * s),
                              Expanded(child: _ActionChip(s: s, label: 'Book service')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _BottomGroup(
          s: s,
          isLast: false,
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 40 * s, fontWeight: FontWeight.w800, fontFamily: 'Inter', letterSpacing: -0.4, height: 1.2, color: AppColors.textPrimary),
              children: const [
                TextSpan(text: 'Understand\nevery '),
                TextSpan(text: 'fault', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
          body: 'AI turns raw codes into plain language. Know the cause, urgency, and what to do.',
        ),
      ],
    );
  }
}

class _SlideFind extends StatelessWidget {
  final double s;
  const _SlideFind({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 8 * s),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
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
                          Positioned(left: 20 * s, top: 16 * s, child: _Pin(label: 'Ade Mech · 0.8km', primary: true, s: s)),
                          Positioned(right: 20 * s, top: 12 * s, child: _Pin(label: 'Kayode Auto', primary: false, s: s)),
                          Positioned(right: 18 * s, bottom: 20 * s, child: _Pin(label: 'Lanre Workshop', primary: false, s: s)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8 * s),
                _MechCard(s: s, initials: 'AO', name: 'Ade Okonkwo Auto', detail: 'Toyota specialist  •  0.8 km  •  Lagos Island', stars: 5, btnLabel: 'Call', btnPrimary: true),
                SizedBox(height: 7 * s),
                _MechCard(s: s, initials: 'KA', name: 'Kayode Auto Workshop', detail: 'General Repairs  •  1.4 km', stars: 4, btnLabel: 'WA', btnPrimary: false),
              ],
            ),
          ),
        ),
        _BottomGroup(
          s: s,
          isLast: true,
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 40 * s, fontWeight: FontWeight.w800, fontFamily: 'Inter', letterSpacing: -0.4, height: 1.2, color: AppColors.textPrimary),
              children: const [
                TextSpan(text: 'Find your\n'),
                TextSpan(text: 'mechanic', style: TextStyle(color: AppColors.primary)),
                TextSpan(text: ' near you'),
              ],
            ),
          ),
          body: 'See verified mechanics nearby. Call or WhatsApp with your fault pre-filled.',
        ),
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
      padding: EdgeInsets.fromLTRB(20 * s, 6 * s, 20 * s, 38 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 4 * s),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.08), Colors.transparent]),
            ),
          ),
          SizedBox(height: 16 * s),
          title,
          SizedBox(height: 10 * s),
          Text(body, style: TextStyle(fontSize: 15 * s, color: AppColors.textSecondary, height: 1.5, fontFamily: 'Inter')),
          SizedBox(height: 18 * s),
          GestureDetector(
            onTap: () => state?._next(),
            child: Container(
              width: double.infinity,
              height: 50 * s,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12 * s),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 5))],
              ),
              child: Center(
                child: Text(isLast ? 'GET STARTED' : 'NEXT',
                    style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.6, fontFamily: 'Inter')),
              ),
            ),
          ),
          if (isLast) ...[
            SizedBox(height: 10 * s),
            Center(
              child: GestureDetector(
                onTap: () => state?._skip(),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 11 * s, color: AppColors.textSecondary, fontFamily: 'Inter'),
                    children: const [
                      TextSpan(text: 'Already have an account?  '),
                      TextSpan(text: 'Sign in', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ] else
            SizedBox(height: 18 * s),
        ],
      ),
    );
  }
}

// ── NEW: Full fault analysis card (used 5x in slide 2) ───────
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
              color: btnPrimary ? AppColors.primary : AppColors.whatsApp.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10 * s),
              border: btnPrimary ? null : Border.all(color: AppColors.whatsApp.withOpacity(0.4)),
            ),
            child: Text(btnLabel, style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w700, color: btnPrimary ? Colors.white : AppColors.whatsApp, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }
}

class _PulseBar extends StatelessWidget {
  final double s, height;
  const _PulseBar({required this.s, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4 * s, height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(999),
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
        color: Colors.white.withOpacity(0.04),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5)),
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

class _Cause extends StatelessWidget {
  final double s;
  final String n, text;
  const _Cause({required this.s, required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$n  ', style: TextStyle(fontSize: 6 * s, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'monospace')),
        Expanded(child: Text(text, style: TextStyle(fontSize: 6 * s, color: AppColors.textSecondary, fontFamily: 'Inter'))),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double s, value;
  final String label;
  final Color color;
  const _Bar({required this.s, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 36 * s, child: Text(label, style: TextStyle(fontSize: 6.5 * s, color: AppColors.textSecondary, fontFamily: 'Inter'))),
        Expanded(
          child: Stack(children: [
            Container(height: 3.5 * s, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(2))),
            FractionallySizedBox(widthFactor: value, child: Container(height: 3.5 * s, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          ]),
        ),
        SizedBox(width: 6 * s),
        Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 6.5 * s, fontWeight: FontWeight.w600, color: color, fontFamily: 'Inter')),
      ],
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bluetooth.withOpacity(0.08), border: Border.all(color: AppColors.bluetooth.withOpacity(0.22), width: 1))),
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
          boxShadow: primary ? [BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 7)] : null,
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
    final g = Paint()..color = Colors.white.withOpacity(0.04)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), g);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), g);
    }
    final r = Paint()..color = Colors.white.withOpacity(0.07)..strokeWidth = 8;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), r);
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), r);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _MiniStat extends StatelessWidget {
  final double s;
  final String label, value;
  final Color color;
  const _MiniStat({required this.s, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8 * s), border: Border.all(color: color.withOpacity(0.22))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 6.5 * s, color: AppColors.textTertiary, fontWeight: FontWeight.w600, letterSpacing: 0.6, fontFamily: 'Inter')),
        SizedBox(height: 2 * s),
        Text(value, style: TextStyle(fontSize: 9 * s, color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
      ]),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final double s;
  final String label;
  const _ActionChip({required this.s, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
      decoration: BoxDecoration(color: AppColors.surfaceDeep, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.border)),
      child: Center(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 6.5 * s, color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
    );
  }
}

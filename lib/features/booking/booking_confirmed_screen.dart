import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({super.key});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700))..forward();
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _buildCheck(),
              const SizedBox(height: 24),
              _buildHeadline(),
              const SizedBox(height: 16),
              _buildRefBadge(),
              const SizedBox(height: 24),
              _buildDetailsCard(),
              const SizedBox(height: 28),
              _buildButtons(context),
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: AppColors.textTertiary,
                        fontFamily: 'Inter'),
                    children: [
                      TextSpan(text: 'Need to cancel?  '),
                      TextSpan(text: 'Cancel booking',
                          style: TextStyle(color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheck() {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 160, height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 160, height: 160,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.advisory.withValues(alpha: 0.08), width: 1))),
              Container(width: 128, height: 128,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.advisory.withValues(alpha: 0.12), width: 1))),
              Container(width: 98, height: 98,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.advisory.withValues(alpha: 0.20), width: 1.5))),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.advisory.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.advisory, width: 2.5),
                  boxShadow: [BoxShadow(
                      color: AppColors.advisory.withValues(alpha: 0.35),
                      blurRadius: 24)],
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.advisory, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      children: const [
        Text('Booking Confirmed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Inter')),
        SizedBox(height: 8),
        Text('Ade Okonkwo Auto has been notified.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
        Text("You'll receive a confirmation shortly.",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildRefBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.advisoryBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.advisoryBorder),
      ),
      child: const Text('REF: SDA-2604-0001',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.advisory, fontFamily: 'monospace',
              letterSpacing: 1.5)),
    );
  }

  Widget _buildDetailsCard() {
    final rows = [
      ['Mechanic', 'Ade Okonkwo Auto', false],
      ['Date', 'Tuesday, 14 April 2026', false],
      ['Time', '8:00 AM', false],
      ['Vehicle', 'Toyota Corolla 2016', false],
      ['Fault codes', 'P0301 · P0420 · P0171', true],
      ['Location', 'Lagos Island, Lagos', false],
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.advisoryBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: const [
                Text('BOOKING DETAILS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary, letterSpacing: 1.5,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                Text(r[0] as String,
                    style: const TextStyle(fontSize: 13,
                        color: AppColors.textSecondary, fontFamily: 'Inter')),
                const Spacer(),
                Text(r[1] as String,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: (r[2] as bool)
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontFamily: 'Inter')),
              ],
            ),
          )),
          const Divider(height: 1, color: AppColors.borderSubtle),
          // Status row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                const Text('Status',
                    style: TextStyle(fontSize: 13,
                        color: AppColors.textSecondary, fontFamily: 'Inter')),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.moderateBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.moderateBorder),
                  ),
                  child: const Text('PENDING CONFIRM',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.moderate, letterSpacing: 0.5,
                          fontFamily: 'Inter')),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          // Deposit row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: const [
                Text('Deposit paid',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                        fontFamily: 'Inter')),
                Spacer(),
                Text('₦0  •  Free booking',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                        color: AppColors.advisory, fontFamily: 'Inter')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_outlined, color: AppColors.textSecondary, size: 16),
                  SizedBox(width: 8),
                  Text('WhatsApp Mech',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary, fontFamily: 'Inter')),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Pop back to home shell
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.38),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Center(
                child: Text('Go to Home',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white, fontFamily: 'Inter')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



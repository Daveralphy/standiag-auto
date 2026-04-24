import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  bool _isYearly = false;

  final _features = [
    'Unlimited diagnostic scans',
    'Full AI fault interpretation',
    'PDF scan report export',
    'Up to 10 vehicles',
    'Priority mechanic listings',
    'Unlimited maintenance reminders',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildHero(),
                    const SizedBox(height: 20),
                    _buildToggle(),
                    const SizedBox(height: 20),
                    _buildPrice(),
                    const SizedBox(height: 24),
                    _buildFeatureList(),
                    const SizedBox(height: 16),
                    _buildPaystackStrip(),
                    const SizedBox(height: 24),
                    _buildSubscribeButton(),
                    const SizedBox(height: 12),
                    Text(
                      '7-day free trial  •  No charge until 21 April 2026',
                      style: TextStyle(fontSize: 12,
                          color: AppColors.textTertiary, fontFamily: 'Inter'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 11,
                            color: AppColors.textDisabled, fontFamily: 'Inter'),
                        children: [
                          TextSpan(text: 'By subscribing you agree to our '),
                          TextSpan(text: 'Subscription Terms',
                              style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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
          const Text('Upgrade to Pro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18), width: 1.5),
                boxShadow: [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 28)],
              ),
            ),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.14),
              ),
            ),
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.primary, size: 40),
          ],
        ),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Inter'),
            children: [
              TextSpan(text: 'StanDiag '),
              TextSpan(text: 'Pro',
                  style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text('Unlimited diagnostics. Full AI reports.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildToggle() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isYearly = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: !_isYearly ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text('Monthly',
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: !_isYearly
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontFamily: 'Inter')),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isYearly = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isYearly ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text('Yearly',
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isYearly
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontFamily: 'Inter')),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Save 20% badge on Yearly
        Positioned(
          top: -10, right: 60,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text('Save 20%',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Inter')),
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    final price = _isYearly ? '₦14,400' : '₦1,500';
    final period = _isYearly ? 'per year' : 'per month';
    return Column(
      children: [
        Text(price,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900,
                color: AppColors.textPrimary, fontFamily: 'Inter',
                letterSpacing: -1)),
        Text('$period  •  cancel anytime',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WHAT YOU GET',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary, letterSpacing: 1.5,
                  fontFamily: 'Inter')),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          ..._features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.advisoryBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.advisoryBorder),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.advisory, size: 13),
                ),
                const SizedBox(width: 12),
                Text(f,
                    style: const TextStyle(fontSize: 14,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPaystackStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Center(
        child: Text('🔒  Secured by Paystack  •  Card  •  Bank Transfer  •  USSD',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary,
                fontFamily: 'Inter')),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Center(
        child: Text(
          _isYearly
              ? 'SUBSCRIBE FOR ₦14,400 / YEAR'
              : 'SUBSCRIBE FOR ₦1,500 / MONTH',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: 0.5, fontFamily: 'Inter'),
        ),
      ),
    );
  }
}


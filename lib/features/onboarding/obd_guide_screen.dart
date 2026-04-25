import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class OBDGuideScreen extends StatelessWidget {
  const OBDGuideScreen({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildDeviceCard(),
                    const SizedBox(height: 20),
                    _buildHeadline(),
                    const SizedBox(height: 12),
                    _buildCompatNote(),
                    const SizedBox(height: 24),
                    _buildWhereToBy(),
                    const SizedBox(height: 20),
                    _buildTipCard(),
                    const SizedBox(height: 28),
                    _buildCTAButton(context),
                    const SizedBox(height: 12),
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13,
                              color: AppColors.textTertiary, fontFamily: 'Inter'),
                          children: [
                            TextSpan(text: 'Already have one?  '),
                            TextSpan(text: 'Go to Scan →',
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
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('OBD-II Adapter Guide',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildDeviceCard() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 180, height: 90,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBorder),
              boxShadow: [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.20), blurRadius: 24)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ELM327',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: AppColors.primary, fontFamily: 'monospace',
                        letterSpacing: 2)),
                const Text('OBD-II Bluetooth',
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 6),
                // Connector pins
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (_) => Container(
                    width: 8, height: 6, margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.advisoryBg,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.advisoryBorder),
            ),
            child: const Text('₦3,000 – ₦12,000',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.advisory, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('What you need to scan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Inter')),
        SizedBox(height: 6),
        Text('Any ELM327-compatible Bluetooth adapter works with StanDiag Auto.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
                height: 1.5, fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildCompatNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bluetooth.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bluetooth.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Works on any car with an OBD-II port.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          SizedBox(height: 4),
          Text('Most petrol and diesel vehicles made after year 2000.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildWhereToBy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WHERE TO BUY IN NIGERIA',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        _StoreCard(
          emoji: '🛒',
          emojiColor: AppColors.primary,
          title: 'Jiji.ng',
          subtitle: "Search 'ELM327 Bluetooth OBD'  •  ₦3,000–₦7,000",
          link: 'jiji.ng →',
        ),
        const SizedBox(height: 8),
        _StoreCard(
          emoji: '📍',
          emojiColor: AppColors.bluetooth,
          title: 'Computer Village, Ikeja',
          subtitle: 'Most electronics shops stock ELM327 adapters',
          link: 'Lagos Island, Surulere, Oshodi markets too',
          isLink: false,
        ),
        const SizedBox(height: 8),
        _StoreCard(
          emoji: '📦',
          emojiColor: AppColors.gold,
          title: 'Jumia / Konga',
          subtitle: 'Order online  •  ₦5,000–₦12,000  •  Delivered 2–5 days',
          link: 'jumia.com.ng →',
        ),
      ],
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('💡  What to look for when buying',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          SizedBox(height: 8),
          Text(
            'Make sure it says ELM327 and Bluetooth on the box. Wi-Fi versions will NOT work with this app. Avoid "Mini" clones — they can be unreliable.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                height: 1.5, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.40),
              blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Center(
          child: Text('I Have My Adapter — Start Scanning →',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Inter')),
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final String emoji, title, subtitle, link;
  final Color emojiColor;
  final bool isLink;

  const _StoreCard({required this.emoji, required this.emojiColor,
      required this.title, required this.subtitle, required this.link,
      this.isLink = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: emojiColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(emoji,
                style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary, fontFamily: 'Inter')),
                const SizedBox(height: 3),
                Text(link,
                    style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isLink ? AppColors.primary : AppColors.textTertiary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/providers/profile_provider.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  final _tierFeatures = {
    'bronze': [
      '5 diagnostic scans per month',
      'Basic fault interpretation',
      'Vehicle management',
      'Scan history',
    ],
    'silver': [
      'Unlimited diagnostic scans',
      'Full AI fault interpretation',
      'PDF scan report export',
      'Up to 10 vehicles',
      'Priority mechanic listings',
    ],
    'gold': [
      'Everything in Silver',
      'Premium AI analysis',
      'Scheduled maintenance alerts',
      'Advanced diagnostics',
      'Lifetime scan history',
      'VIP support',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: profileAsync.when(
                data: (profile) {
                  final currentTier = (profile?['tier'] as String?)?.toLowerCase() ?? 'bronze';
                  return _buildTierComparison(context, currentTier);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (_, __) => _buildTierComparison(context, 'bronze'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left_rounded,
                color: AppColors.textSecondary, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(
            'Subscription Plans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierComparison(BuildContext context, String currentTier) {
    final tiers = [
      {'name': 'Bronze', 'color': const Color(0xFFCD7F32), 'price': 'FREE', 'period': 'Always'},
      {'name': 'Silver', 'color': const Color(0xFFC0C0C0), 'price': '₦1,500', 'period': 'Monthly'},
      {'name': 'Gold', 'color': const Color(0xFFFFD700), 'price': '₦3,000', 'period': 'Monthly'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Unlock unlimited diagnostics and premium features',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          ...tiers.map((tierData) {
            final tierNameStr = tierData['name'] as String;
            final tierName = tierNameStr.toLowerCase();
            final isCurrent = tierName == currentTier;
            final color = tierData['color'] as Color;

            return Column(
              children: [
                _buildTierCard(
                  context,
                  tierNameStr,
                  color,
                  tierData['price'] as String,
                  tierData['period'] as String,
                  _tierFeatures[tierName] ?? [],
                  isCurrent,
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    String tierName,
    Color tierColor,
    String price,
    String period,
    List<String> features,
    bool isCurrent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: isCurrent ? tierColor : AppColors.border,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [BoxShadow(
                color: tierColor.withValues(alpha: 0.15),
                blurRadius: 20,
              )]
            : null,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tierColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tierName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tierColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: tierColor),
                    ),
                    child: Text(
                      'CURRENT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: tierColor,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          // Features
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                ...features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.check_rounded,
                            color: tierColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Upgrade Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isCurrent ? null : () => _handleUpgrade(tierName),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.surface : tierColor,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: isCurrent ? AppColors.border : tierColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    isCurrent ? 'Your Current Plan' : 'Upgrade to $tierName',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCurrent ? AppColors.textSecondary : Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade(String tierName) {
    // TODO: Implement payment/upgrade logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgrade to $tierName coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}



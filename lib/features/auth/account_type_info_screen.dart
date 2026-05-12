import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';

class AccountTypeInfoScreen extends StatelessWidget {
  const AccountTypeInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary, size: 18),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Text('Account Types', style: AppTypography.h2),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _InfoCard(
                      icon: Icons.directions_car_rounded,
                      iconColor: AppColors.primary,
                      title: 'Car Owner',
                      description: 'For vehicle owners who want to diagnose their car problems. '
                          'Connect an OBD-II adapter to scan your vehicle, '
                          'get AI-powered fault analysis, and find nearby mechanics '
                          'who can fix the problem.',
                      features: const [
                        'Connect OBD-II adapter via Bluetooth',
                        'Scan and diagnose vehicle faults',
                        'Get AI-powered fault summaries',
                        'Find and call nearby mechanics',
                        'Manage your vehicles',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoCard(
                      icon: Icons.build_rounded,
                      iconColor: AppColors.advisory,
                      title: 'Mechanic',
                      description: 'For professional mechanics who want to grow their business. '
                          'Subscribe to appear on the map and receive calls from car '
                          'owners nearby. You can also use the scan tool to diagnose '
                          'vehicles you are working on.',
                      features: const [
                        'Appear on the mechanic map',
                        'Receive calls from nearby car owners',
                        'Scan client vehicles with OBD-II',
                        'See users actively searching for mechanics',
                        'Build your professional profile',
                      ],
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
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String> features;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(title, style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, color: iconColor, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(f, style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}


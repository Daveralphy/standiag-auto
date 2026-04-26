import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'register_screen.dart';
import 'mechanic_register_screen.dart';
import 'login_screen.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Back
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).canPop()
                    ? Navigator.of(context).pop()
                    : Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen())),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 20),
              ),
              const SizedBox(height: 32),
              // Heading
              const Text('Join StanDiag',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      letterSpacing: -0.4,
                      fontFamily: 'Inter')),
              const SizedBox(height: 8),
              const Text('Choose how you want to use the app.',
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
              const SizedBox(height: 48),

              // Car Owner card
              _AccountTypeCard(
                icon: Icons.directions_car_outlined,
                title: 'Car Owner',
                subtitle:
                    'Diagnose your car, find mechanics,\ntrack maintenance and repairs.',
                isPrimary: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const RegisterScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // Mechanic card
              _AccountTypeCard(
                icon: Icons.car_repair,
                title: 'Mechanic',
                subtitle:
                    'Receive job requests, manage\nearnings and grow your business.',
                isPrimary: false,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const MechanicRegisterScreen()),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'You can only have one account type per account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isPrimary
                  ? AppColors.primary
                  : AppColors.border,
              width: isPrimary ? 1.5 : 1),
          boxShadow: isPrimary
              ? [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 20, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: isPrimary ? AppColors.primaryGradient : null,
                color: isPrimary ? null : AppColors.surfaceDeep,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  color: isPrimary
                      ? Colors.white
                      : AppColors.textSecondary,
                  size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isPrimary
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontFamily: 'Inter')),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                          fontFamily: 'Inter')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



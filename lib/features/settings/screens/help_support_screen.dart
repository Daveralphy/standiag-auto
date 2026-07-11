// Help & Support screen — FAQs and contact options.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/system_ui_style.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

const _faqs = [
  _Faq('How do I find a mechanic?',
      'Tap the Mechanics tab and set your search radius. Nearby mechanics will appear on the map.'),
  _Faq('How does the credits system work?',
      'Credits are spent to contact a mechanic or run an OBD scan. Buy more anytime from the Credits screen.'),
  _Faq('What is the OBD scanner?',
      "It's a Bluetooth adapter that plugs into your car's OBD-II port and lets the app read your vehicle's diagnostic data."),
  _Faq('How do I add a vehicle?',
      'Open My Vehicles from the drawer and tap "+ Add" to enter your vehicle\'s details.'),
  _Faq('How do I rate a mechanic?',
      "After a job is marked complete, you'll be prompted to rate the mechanic and leave an optional comment."),
];

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Future<void> _openSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppStrings.supportEmail,
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(currentUserTypeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.go(RouteNames.settingsFor(type)),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text(AppStrings.helpTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FAQs', style: AppTypography.heading4,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 12),
                    ..._faqs.map((faq) =>
                        _FaqItem(question: faq.question, answer: faq.answer)),
                    const SizedBox(height: 24),
                    const Text(AppStrings.helpStillNeed,
                        style: AppTypography.heading4,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 12),
                    _ContactItem(
                      icon: Icons.mail_outline_rounded,
                      label: AppStrings.helpEmail,
                      value: AppStrings.supportEmail,
                      onTap: _openSupportEmail,
                    ),
                    const SizedBox(height: 8),
                    _ContactItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: AppStrings.helpLiveChat,
                      value: 'Chat with us now',
                      onTap: _openSupportEmail,
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

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(widget.question,
                  style: AppTypography.body,
                  overflow: TextOverflow.ellipsis, maxLines: 2)),
              Icon(_expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted, size: 18),
            ]),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(widget.answer,
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis, maxLines: 5),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodyLarge,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(value, style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          )),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textDisabled, size: 18),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Shared, responsive destinations for workspace actions that must never be
/// decorative or lead nowhere while their full backend workflows are built.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => const _SupportScaffold(
        title: 'Notifications',
        subtitle: 'Important updates about your account and repairs.',
        icon: Icons.notifications_none_rounded,
        child: _EmptyNotifications(),
      );
}

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({
    super.key,
    required this.email,
    required this.roleLabel,
  });

  final String email;
  final String roleLabel;

  @override
  Widget build(BuildContext context) => _SupportScaffold(
        title: 'Account settings',
        subtitle: 'Review the account you are currently signed in with.',
        icon: Icons.manage_accounts_outlined,
        child: Column(
          children: [
            _DetailTile(
              icon: Icons.email_outlined,
              title: 'Email address',
              detail: email.isEmpty ? 'No email address available' : email,
            ),
            const SizedBox(height: 12),
            _DetailTile(
              icon: Icons.badge_outlined,
              title: 'Account type',
              detail: roleLabel,
            ),
            const SizedBox(height: 16),
            const _Notice(
              text:
                  'Profile editing, password and security controls will be added here when their account workflows are connected. Your account details are not editable from this preview.',
            ),
          ],
        ),
      );
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = <(String, String)>[
    (
      'How do I request a repair?',
      'Save a vehicle, open Explore, choose an approved mechanic and follow the repair-request steps.'
    ),
    (
      'Why can I not access mechanic tools?',
      'Mechanic tools are available only after your application has been reviewed and approved.'
    ),
    (
      'What if my vehicle or repair is missing?',
      'Check that you are signed in to the correct account. If the issue continues, contact the app support team through the support channel provided by the app owner.'
    ),
    (
      'How do I protect my account?',
      'Use a strong password, verify your email address and sign out on devices you no longer use.'
    ),
  ];

  @override
  Widget build(BuildContext context) => _SupportScaffold(
        title: 'Help and support',
        subtitle: 'Find answers to common questions about Standiag Auto.',
        icon: Icons.help_outline_rounded,
        child: Column(
          children: [
            for (final faq in _faqs)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded),
                  title: Text(
                    faq.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(faq.$2),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const _Notice(
              text:
                  'A direct support contact will be added when the official support address or service is configured.',
            ),
          ],
        ),
      );
}

class _SupportScaffold extends StatelessWidget {
  const _SupportScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      );
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'You are all caught up',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'When there are account or repair updates to show, they will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(detail),
        ),
      );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

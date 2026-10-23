import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'repair_detail_screen.dart';
import 'mechanic_jobs_screen.dart';

/// Shared, responsive destinations for workspace actions that must never be
/// decorative or lead nowhere while their full backend workflows are built.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _SupportScaffold(
        title: 'Notifications',
        subtitle: 'Important updates about your account and repairs.',
        icon: Icons.notifications_none_rounded,
        child: _Notice(text: 'Sign in to see notifications for your account.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _NotificationState(
              icon: Icons.cloud_off_outlined,
              title: 'Notifications unavailable',
              message: 'Check your connection and try again.',
              action: FilledButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = [...?snapshot.data?.docs];
          docs.sort((a, b) {
            final ad = a.data()['createdAt'];
            final bd = b.data()['createdAt'];
            final at = ad is Timestamp ? ad.millisecondsSinceEpoch : 0;
            final bt = bd is Timestamp ? bd.millisecondsSinceEpoch : 0;
            return bt.compareTo(at);
          });
          if (docs.isEmpty) {
            return const _SupportScaffold(
              title: 'Notifications',
              subtitle: 'Important updates about your account and repairs.',
              icon: Icons.notifications_none_rounded,
              child: _EmptyNotifications(),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Text('Your updates', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Updates sent to your account appear here.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              for (final doc in docs)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: (doc.data()['isRead'] == true)
                      ? null
                      : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.42),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(_notificationIcon(doc.data()['type'] as String?)),
                    ),
                    title: Text(
                      doc.data()['title'] as String? ?? 'Account update',
                      style: TextStyle(fontWeight: doc.data()['isRead'] == true ? FontWeight.w500 : FontWeight.w800),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(doc.data()['body'] as String? ?? doc.data()['message'] as String? ?? 'Open to view this update.'),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openNotification(context, doc.id, doc.data()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static IconData _notificationIcon(String? type) {
    switch (type) {
      case 'repair':
      case 'service_request':
        return Icons.car_repair_rounded;
      case 'job':
        return Icons.assignment_outlined;
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'account':
        return Icons.person_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  static Future<void> _openNotification(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      if (data['isRead'] != true) {
        await FirebaseFirestore.instance.collection('notifications').doc(id).update({
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not mark this notification as read.')),
        );
      }
    }
    if (!context.mounted) return;
    final requestId = data['requestId'] as String?;
    final jobId = data['jobId'] as String?;
    if (requestId != null && requestId.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RepairDetailScreen(requestId: requestId),
      ));
    } else if (jobId != null && jobId.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MechanicJobDetailScreen(jobId: jobId),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This notification has no linked screen yet.')),
      );
    }
  }
}

class _NotificationState extends StatelessWidget {
  const _NotificationState({required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ]),
    ),
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

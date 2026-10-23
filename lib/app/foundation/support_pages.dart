import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'repair_detail_screen.dart';
import 'mechanic_jobs_screen.dart';

/// Shared, responsive destinations for workspace actions that must never be
/// decorative or lead nowhere while their full backend workflows are built.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const _SupportScaffold(
        title: 'Notifications',
        subtitle: 'Important updates about your account and repairs.',
        icon: Icons.notifications_none_rounded,
        child: _NotificationNotConnected(),
      );
    }
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
          final unreadDocs = docs.where((doc) => doc.data()['isRead'] != true).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Text('Your updates', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Updates sent to your account appear here.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (unreadDocs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _markAllAsRead(context, unreadDocs),
                    icon: const Icon(Icons.done_all_rounded),
                    label: Text('Mark all as read (${unreadDocs.length})'),
                  ),
                ),
              ],
              const SizedBox(height: 8),
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

  static Future<void> _markAllAsRead(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> unreadDocs,
  ) async {
    try {
      // Firestore batches support at most 500 writes. Chunk to keep this safe
      // even for accounts with a long notification history.
      for (var start = 0; start < unreadDocs.length; start += 450) {
        final batch = FirebaseFirestore.instance.batch();
        final end = (start + 450 < unreadDocs.length) ? start + 450 : unreadDocs.length;
        for (final doc in unreadDocs.sublist(start, end)) {
          batch.update(doc.reference, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read.')),
        );
      }
    } on FirebaseException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not mark all notifications as read. Please try again.')),
        );
      }
    }
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
    final type = data['type'] as String? ?? '';
    // Mechanic job notifications can include both IDs (for example, an
    // accepted quote). Route those to the assigned job, not the customer
    // repair-request view. Service-request notifications remain request-led.
    final isJobUpdate = {
      'quote_accepted',
      'direct_call',
    }.contains(type);
    if (jobId != null && jobId.isNotEmpty && (isJobUpdate || requestId == null || requestId.isEmpty)) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MechanicJobDetailScreen(jobId: jobId),
      ));
    } else if (requestId != null && requestId.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RepairDetailScreen(requestId: requestId),
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

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({
    super.key,
    required this.email,
    required this.roleLabel,
  });

  final String email;
  final String roleLabel;

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _sendingReset = false;
  String? _feedback;
  bool _feedbackIsError = false;

  Future<void> _sendPasswordReset() async {
    final address = widget.email.trim();
    if (address.isEmpty || _sendingReset) return;
    setState(() {
      _sendingReset = true;
      _feedback = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: address);
      if (!mounted) return;
      setState(() {
        _feedback = 'If an account can be reset with this email, a password reset message will be sent. Check your inbox and spam folder.';
        _feedbackIsError = false;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _feedback = switch (error.code) {
          'invalid-email' => 'The saved email address is not valid. Sign out and sign in with the correct account.',
          'network-request-failed' => 'Check your internet connection and try again.',
          'too-many-requests' => 'Too many attempts. Please wait before trying again.',
          _ => 'We could not start the password reset. Please try again later.',
        };
        _feedbackIsError = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _feedback = 'We could not start the password reset. Please try again later.';
        _feedbackIsError = true;
      });
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  @override
  Widget build(BuildContext context) => _SupportScaffold(
    title: 'Account settings',
    subtitle: 'Review your account details and security options.',
    icon: Icons.manage_accounts_outlined,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailTile(
          icon: Icons.email_outlined,
          title: 'Email address',
          detail: widget.email.isEmpty ? 'No email address available' : widget.email,
        ),
        const SizedBox(height: 12),
        _DetailTile(
          icon: Icons.badge_outlined,
          title: 'Account type',
          detail: widget.roleLabel,
        ),
        const SizedBox(height: 20),
        Text('Security', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock_reset_rounded),
            title: const Text('Reset password'),
            subtitle: const Text('Send a password reset email to your account address.'),
            trailing: _sendingReset
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chevron_right_rounded),
            onTap: _sendingReset || widget.email.trim().isEmpty ? null : _sendPasswordReset,
          ),
        ),
        if (_feedback != null) ...[
          const SizedBox(height: 12),
          _FeedbackPanel(message: _feedback!, isError: _feedbackIsError),
        ],
        const SizedBox(height: 20),
        Text('Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy policy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const LegalInfoScreen(kind: LegalInfoKind.privacy),
                )),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Terms of service'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const LegalInfoScreen(kind: LegalInfoKind.terms),
                )),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About Standiag Auto'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const LegalInfoScreen(kind: LegalInfoKind.about),
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _Notice(
          text: 'Account deletion is not available here yet because it requires a secure backend workflow that removes related data consistently.',
        ),
      ],
    ),
  );
}

enum LegalInfoKind { privacy, terms, about }

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key, required this.kind});
  final LegalInfoKind kind;

  @override
  Widget build(BuildContext context) {
    final title = switch (kind) {
      LegalInfoKind.privacy => 'Privacy policy',
      LegalInfoKind.terms => 'Terms of service',
      LegalInfoKind.about => 'About Standiag Auto',
    };
    final icon = switch (kind) {
      LegalInfoKind.privacy => Icons.privacy_tip_outlined,
      LegalInfoKind.terms => Icons.gavel_outlined,
      LegalInfoKind.about => Icons.info_outline_rounded,
    };
    final sections = switch (kind) {
      LegalInfoKind.privacy => const <(String, String)>[
        ('Account information', 'Standiag Auto uses account and profile information to provide sign-in, customer vehicle management, mechanic applications and repair-related features.'),
        ('Vehicle and repair information', 'Information you submit about vehicles and repair requests is used to support the services you request and to show relevant updates to your account.'),
        ('Access and security', 'Access to account and repair records is controlled by application authentication and database security rules. Do not submit passwords or payment secrets in profile fields or repair descriptions.'),
        ('Questions and requests', 'A verified privacy contact and data-retention procedure must be published by the app owner before this draft can be treated as the final privacy policy.'),
      ],
      LegalInfoKind.terms => const <(String, String)>[
        ('Using the service', 'Use accurate information and only create vehicle records and repair requests that you are authorised to submit.'),
        ('Mechanic approval', 'Submitting a mechanic application does not guarantee approval. Access to mechanic features depends on review and the approved account record.'),
        ('Quotes and repairs', 'Repair scope, pricing, timing, cancellations and disputes must be confirmed through the supported application workflow. Do not assume an unconfirmed quote is an accepted agreement.'),
        ('Publication status', 'These are preliminary product terms, not an approved legal agreement. The app owner must review and publish final terms before production use.'),
      ],
      LegalInfoKind.about => const <(String, String)>[
        ('A simpler way to manage car care', 'Standiag Auto is being built to help vehicle owners manage vehicle information, find mechanics and follow repair requests, while giving approved mechanics a place to review assigned work.'),
        ('Availability', 'Some workflows are still under development. Payment totals, account deletion and certain repair actions remain unavailable until their trusted backend services are completed.'),
      ],
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Icon(icon, size: 30, color: Theme.of(context).colorScheme.onPrimaryContainer),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
            ]),
          ),
          const SizedBox(height: 14),
          if (kind != LegalInfoKind.about)
            const _FeedbackPanel(
              message: 'DRAFT — this content needs owner/legal review before production publication.',
              isError: true,
            ),
          const SizedBox(height: 8),
          for (final section in sections) ...[
            const SizedBox(height: 14),
            Text(section.$1, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(section.$2, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
          color: isError ? colors.onErrorContainer : colors.onSecondaryContainer),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(
          color: isError ? colors.onErrorContainer : colors.onSecondaryContainer,
        ))),
      ]),
    );
  }
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

class _NotificationNotConnected extends StatelessWidget {
  const _NotificationNotConnected();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(children: [
      Icon(Icons.cloud_off_outlined, size: 42, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(height: 12),
      Text('Notifications need a connection', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Connect Firebase to load notifications for your account.', textAlign: TextAlign.center),
    ]),
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

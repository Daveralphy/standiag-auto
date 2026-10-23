import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'vehicles_screen.dart';
import 'mechanic_discovery_screen.dart';

/// First pass of the role-specific workspace shell. Data remains clearly
/// illustrative until each screen is connected to its verified data contract.
class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.email,
    required this.role,
    required this.onSignOut,
    this.onApplyMechanic,
  });

  final String email;
  final WorkspaceRole role;
  final Future<void> Function() onSignOut;
  final VoidCallback? onApplyMechanic;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

enum WorkspaceRole { customer, mechanic }

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  int _selectedIndex = 0;
  bool _isSigningOut = false;

  bool get _isCustomer => widget.role == WorkspaceRole.customer;

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await widget.onSignOut();
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.build_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Standiag Auto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                _showNotice(context, 'Notifications will appear here.'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _home(context),
            _isCustomer ? _explore(context) : _jobs(context),
            _isCustomer ? _repairs(context) : _earnings(context),
            _profile(context),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: _isCustomer
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.car_repair_rounded),
                  label: 'My repairs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Profile',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  label: 'Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  label: 'Earnings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Profile',
                ),
              ],
      ),
    );
  }

  Widget _home(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          _isCustomer
              ? 'Your car care, simplified.'
              : 'Ready for your next job?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isCustomer
              ? 'Find trusted help and keep your vehicle moving.'
              : 'Manage requests and keep your work organised.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 22),
        _HeroPanel(
          icon: _isCustomer ? Icons.car_repair_rounded : Icons.handyman_rounded,
          eyebrow: _isCustomer ? 'NEED A REPAIR?' : 'YOUR WORKSPACE',
          title: _isCustomer
              ? 'Get back on the road.'
              : 'Your next opportunity starts here.',
          subtitle: _isCustomer
              ? 'Describe what is wrong and find mechanics who can help.'
              : 'New job requests and customer updates will be organised here.',
          actionLabel: _isCustomer ? 'Find a mechanic' : 'View jobs',
          onPressed: () => setState(() => _selectedIndex = 1),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              _isCustomer ? 'Quick actions' : 'Work overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'DEMO DATA',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isCustomer) ...[
          _ActionTile(
            icon: Icons.search_rounded,
            title: 'Explore mechanics',
            subtitle: 'Browse services and expertise',
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          _ActionTile(
            icon: Icons.directions_car_outlined,
            title: 'My vehicles',
            subtitle: 'Add and manage your vehicles',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const VehiclesScreen()),
            ),
          ),
          _ActionTile(
            icon: Icons.car_repair_rounded,
            title: 'My repairs',
            subtitle: 'Track requests and job progress',
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ] else ...[
          const _MetricRow(
            items: [
              ('0', 'New requests'),
              ('0', 'Active jobs'),
              ('₦0', 'This week'),
            ],
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.assignment_outlined,
            title: 'Review job requests',
            subtitle: 'See and respond to customer requests',
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ],
        const SizedBox(height: 12),
        _InfoBanner(
          text: _isCustomer
              ? 'Your real vehicles, bookings and repair history will appear once these screens are connected to your account data.'
              : 'Mechanic job access depends on administrator approval. This preview does not grant provider access.',
        ),
      ],
    );
  }

  Widget _explore(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const _SectionPage(
        title: 'Find a mechanic',
        subtitle: 'Search approved mechanics by expertise and service area.',
        icon: Icons.travel_explore_rounded,
        emptyTitle: 'Mechanics will show up here',
        emptyMessage: 'Connect Firebase to load approved mechanic profiles.',
      );
    }
    return const MechanicDiscoveryScreen();
  }

  Widget _repairs(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const _SectionPage(
        title: 'My repairs',
        subtitle: 'Your service requests and repair progress in one place.',
        icon: Icons.car_repair_rounded,
        emptyTitle: 'No repairs yet',
        emptyMessage: 'Connect Firebase to load your repair requests.',
      );
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _SectionPage(
        title: 'My repairs',
        subtitle: 'Your service requests and repair progress in one place.',
        icon: Icons.car_repair_rounded,
        emptyTitle: 'Sign in to view repairs',
        emptyMessage: 'Your repair requests are linked to your account.',
      );
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('serviceRequests')
          .where('carOwnerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _SectionPage(
            title: 'My repairs',
            subtitle: 'Your service requests and repair progress in one place.',
            icon: Icons.cloud_off_outlined,
            emptyTitle: 'Could not load repairs',
            emptyMessage: 'Check your connection and try again.',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = [...?snapshot.data?.docs];
        docs.sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];
          final aTime = aDate is Timestamp ? aDate.millisecondsSinceEpoch : 0;
          final bTime = bDate is Timestamp ? bDate.millisecondsSinceEpoch : 0;
          return bTime.compareTo(aTime);
        });
        if (docs.isEmpty) {
          return const _SectionPage(
            title: 'My repairs',
            subtitle: 'Your service requests and repair progress in one place.',
            icon: Icons.car_repair_rounded,
            emptyTitle: 'No repairs yet',
            emptyMessage:
                'When you request a repair, its updates will appear here.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'My repairs',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Follow your requests and mechanic responses.'),
            const SizedBox(height: 18),
            for (final doc in docs)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (doc.data()['issue'] as String? ??
                                  'Repair request'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusPill(
                            status: doc.data()['status'] as String? ?? 'open',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vehicle ID: ${doc.data()['vehicleId'] ?? 'Not linked'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Request ID: ${doc.id}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _jobs(BuildContext context) => const _SectionPage(
    title: 'Job requests',
    subtitle: 'Review customer requests and keep work moving.',
    icon: Icons.assignment_outlined,
    emptyTitle: 'No job requests',
    emptyMessage:
        'Eligible requests will appear here after mechanic approval and backend connection.',
  );

  Widget _earnings(BuildContext context) => const _SectionPage(
    title: 'Earnings',
    subtitle: 'Keep track of completed work and payouts.',
    icon: Icons.account_balance_wallet_outlined,
    emptyTitle: 'Earnings will appear here',
    emptyMessage:
        'Verified job and payment records will be shown here once connected.',
  );

  Widget _profile(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Your profile',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 18),
      Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person_outline_rounded),
          ),
          title: Text(
            widget.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _isCustomer ? 'Customer account' : 'Mechanic workspace preview',
          ),
        ),
      ),
      const SizedBox(height: 12),
      const _ActionTile(
        icon: Icons.settings_outlined,
        title: 'Account settings',
        subtitle: 'Profile details and preferences',
      ),
      if (_isCustomer && widget.onApplyMechanic != null)
        _ActionTile(
          icon: Icons.handyman_outlined,
          title: 'Apply as a mechanic',
          subtitle: 'Submit an application for review',
          onTap: widget.onApplyMechanic,
        ),
      const _ActionTile(
        icon: Icons.help_outline_rounded,
        title: 'Help and support',
        subtitle: 'Get help with your account',
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        onPressed: _isSigningOut ? null : _signOut,
        icon: _isSigningOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout_rounded),
        label: const Text('Sign out'),
      ),
    ],
  );

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onPressed,
  });
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 18),
          Text(
            eyebrow,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          const SizedBox(height: 18),
          FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.items});
  final List<(String, String)> items;
  @override
  Widget build(BuildContext context) => Row(
    children: items
        .map(
          (item) => Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      item.$1,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
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
        const Icon(Icons.info_outline_rounded, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emptyTitle,
    required this.emptyMessage,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String emptyTitle;
  final String emptyMessage;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      Text(subtitle),
      const SizedBox(height: 48),
      _EmptyState(icon: icon, title: emptyTitle, message: emptyMessage),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

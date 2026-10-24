import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'vehicles_screen.dart';
import 'mechanic_discovery_screen.dart';
import 'support_pages.dart';
import 'repair_detail_screen.dart';
import 'mechanic_jobs_screen.dart';
import 'customer_profile_screen.dart';
import 'mechanic_profile_screen.dart';

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
  int _repairFilter = 0;
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
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
    final colors = theme.colorScheme;
    if (!_isCustomer) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Text('Ready for your next job?',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Manage requests and keep your work organised.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 20),
          _HeroPanel(
            icon: Icons.handyman_rounded,
            eyebrow: 'YOUR WORKSPACE',
            title: 'Your next opportunity starts here.',
            subtitle: 'New job requests and customer updates will be organised here.',
            actionLabel: 'View jobs',
            onPressed: () => setState(() => _selectedIndex = 1),
          ),
          const SizedBox(height: 24),
          Text('Work overview', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _ActionTile(icon: Icons.assignment_outlined, title: 'Review job requests',
            subtitle: 'See and respond to customer requests',
            onTap: () => setState(() => _selectedIndex = 1)),
          const SizedBox(height: 10),
          _ActionTile(icon: Icons.inbox_outlined, title: 'Incoming direct requests',
            subtitle: 'Review requests sent specifically to you',
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const MechanicIncomingRequestsScreen()))),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  children: [
                    const TextSpan(text: 'Standiag '),
                    TextSpan(text: 'Auto', style: TextStyle(color: colors.primary)),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const NotificationsScreen())),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(minHeight: 164),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF14232B), Color(0xFF11171B), Color(0xFF260C12)],
            ),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.38)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -24, top: 2, bottom: 0,
                child: Icon(Icons.directions_car_filled_rounded,
                  size: 178, color: colors.primary.withValues(alpha: 0.22)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 17, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 230,
                      child: Text('Find Reliable Mechanics Near You',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800, height: 1.08, letterSpacing: -0.4)),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: 205,
                      child: Text('Quality car repairs from trusted mechanics.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.3, color: colors.onSurfaceVariant)),
                    ),
                    const SizedBox(height: 13),
                    FilledButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Find Mechanics'), SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, size: 19),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 19),
        Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.32,
          children: [
            _CustomerQuickAction(icon: Icons.search_rounded, title: 'Find Mechanics',
              onTap: () => setState(() => _selectedIndex = 1)),
            _CustomerQuickAction(icon: Icons.calendar_month_rounded, title: 'Book a Service',
              onTap: () => setState(() => _selectedIndex = 1)),
            _CustomerQuickAction(icon: Icons.build_circle_outlined, title: 'My Repairs',
              onTap: () => setState(() => _selectedIndex = 2)),
            _CustomerQuickAction(icon: Icons.directions_car_filled_outlined, title: 'My Vehicles',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const VehiclesScreen())),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Text('Nearby Mechanics',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => setState(() => _selectedIndex = 1),
              child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 8),
        _homeMechanicsPreview(context),
      ],
    );
  }

  Widget _homeMechanicsPreview(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (Firebase.apps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mechanics to explore',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('mechanics')
              .where('isVisible', isEqualTo: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Mechanics could not be loaded right now. You can still search in Explore.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final mechanics = snapshot.data?.docs ?? [];
            if (mechanics.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(Icons.handyman_outlined, color: colors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Approved mechanics will appear here when available.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (final mechanic in mechanics) ...[
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.garage_rounded,
                                color: colors.primary,
                                size: 27,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (mechanic.data()['workshopName'] as String?)
                                                ?.trim()
                                                .isNotEmpty ==
                                            true
                                        ? (mechanic.data()['workshopName'] as String).trim()
                                        : 'Independent mechanic',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ((mechanic.data()['workshopAddress'] as String?)?.trim().isNotEmpty == true)
                                        ? (mechanic.data()['workshopAddress'] as String).trim()
                                        : 'Service area not provided',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  if ((mechanic.data()['expertise'] as List? ?? []).whereType<String>().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: (mechanic.data()['expertise'] as List? ?? [])
                                          .whereType<String>()
                                          .take(3)
                                          .map((item) => Chip(
                                                label: Text(item),
                                                visualDensity: VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
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
        final activeCount = docs.where((doc) {
          final status = (doc.data()['status'] as String? ?? 'open').toLowerCase();
          return status != 'completed' && status != 'cancelled' && status != 'rejected';
        }).length;
        final completedCount = docs.where((doc) =>
          (doc.data()['status'] as String? ?? '').toLowerCase() == 'completed'
        ).length;
        final filteredDocs = docs.where((doc) {
          final status = (doc.data()['status'] as String? ?? 'open').toLowerCase();
          switch (_repairFilter) {
            case 1:
              return status != 'completed' && status != 'cancelled' && status != 'rejected';
            case 2:
              return status == 'completed';
            case 3:
              return status == 'cancelled' || status == 'rejected';
            default:
              return true;
          }
        }).toList();

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
            Text('Follow your requests and mechanic responses.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _RepairSummaryCard(label: 'Total requests', value: '${docs.length}', icon: Icons.car_repair_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _RepairSummaryCard(label: 'Active', value: '$activeCount', icon: Icons.pending_actions_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _RepairSummaryCard(label: 'Completed', value: '$completedCount', icon: Icons.task_alt_rounded)),
              ],
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _repairFilterChip('All', 0),
                  const SizedBox(width: 8),
                  _repairFilterChip('Active', 1),
                  const SizedBox(width: 8),
                  _repairFilterChip('Completed', 2),
                  const SizedBox(width: 8),
                  _repairFilterChip('Cancelled', 3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (filteredDocs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.filter_list_off_rounded, size: 34,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 10),
                      Text('No ${['matching', 'active', 'completed', 'cancelled'][_repairFilter]} repairs',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Try another filter to see your repair requests.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            for (final doc in filteredDocs)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RepairDetailScreen(requestId: doc.id),
                    ),
                  ),
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
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 15,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              _repairDateLabel(doc.data()['createdAt']),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'View request details and mechanic responses',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _repairDateLabel(dynamic value) {
    if (value is! Timestamp) return 'Submission date unavailable';
    final date = value.toDate().toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Submitted ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _repairFilterChip(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      selected: _repairFilter == value,
      onSelected: (selected) {
        if (selected) setState(() => _repairFilter = value);
      },
    );
  }

  Widget _jobs(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const _SectionPage(
        title: 'Job requests',
        subtitle: 'Review customer requests and keep work moving.',
        icon: Icons.assignment_outlined,
        emptyTitle: 'No job requests',
        emptyMessage: 'Connect Firebase to load jobs assigned to your mechanic account.',
      );
    }
    return const MechanicJobsScreen();
  }

  Widget _earnings(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const _SectionPage(
        title: 'Earnings',
        subtitle: 'Keep track of completed work and payouts.',
        icon: Icons.account_balance_wallet_outlined,
        emptyTitle: 'Earnings will appear here',
        emptyMessage: 'Connect Firebase to load completed job records.',
      );
    }
    return const MechanicEarningsScreen();
  }

  Widget _profile(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceContainerHighest,
                colors.surface,
                colors.secondary.withValues(alpha: 0.62),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.65)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colors.primary.withValues(alpha: 0.16),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 30,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _isCustomer ? 'Customer account' : 'Mechanic workspace preview',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Account',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (_isCustomer)
          _ActionTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Personal information',
            subtitle: 'Update your name and phone number',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CustomerProfileScreen(),
              ),
            ),
          ),
        if (!_isCustomer)
          _ActionTile(
            icon: Icons.handyman_outlined,
            title: 'Mechanic profile',
            subtitle: 'View your workshop details and expertise',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MechanicProfileScreen(),
              ),
            ),
          ),
        _ActionTile(
          icon: Icons.settings_outlined,
          title: 'Account settings',
          subtitle: 'Review your account details',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AccountSettingsScreen(
                email: widget.email,
                roleLabel: _isCustomer ? 'Customer' : 'Approved mechanic',
              ),
            ),
          ),
        ),
        if (_isCustomer && widget.onApplyMechanic != null)
          _ActionTile(
            icon: Icons.handyman_outlined,
            title: 'Become a mechanic',
            subtitle: 'Submit an application for review',
            onTap: widget.onApplyMechanic,
          ),
        const SizedBox(height: 18),
        Text(
          'Support',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.help_outline_rounded,
          title: 'Help and support',
          subtitle: 'Browse common questions',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const HelpSupportScreen(),
            ),
          ),
        ),
        const SizedBox(height: 20),
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
  }

}

class _CustomerQuickAction extends StatelessWidget {
  const _CustomerQuickAction({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: const Color(0xFF111619),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: colors.primary, size: 27),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepairSummaryCard extends StatelessWidget {
  const _RepairSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
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
          colors: [
            colors.surfaceContainerHighest,
            colors.surface,
            colors.secondary.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -20,
            child: Icon(
              icon,
              size: 132,
              color: colors.primary.withValues(alpha: 0.13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  eyebrow,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: colors.primary, size: 23),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

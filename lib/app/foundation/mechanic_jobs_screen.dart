import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/jobs/models/job_model.dart';

/// Real, read-only job inbox for an approved mechanic.
/// Lifecycle mutations are intentionally excluded until the server-side
/// transition contract is verified and can reject invalid transitions.
class MechanicJobsScreen extends StatelessWidget {
  const MechanicJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _JobsState(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in to view jobs',
        message: 'Your job requests are linked to your mechanic account.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('mechanicId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _JobsState(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load jobs',
            message: 'Check your connection and try again.',
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
          return const _JobsState(
            icon: Icons.assignment_outlined,
            title: 'No jobs yet',
            message: 'Jobs assigned to your account will appear here. Make sure your mechanic profile is approved and visible.',
          );
        }

        final active = docs.where((doc) {
          final status = JobStatusExtension.fromString(doc.data()['status'] as String? ?? 'pending');
          return status != JobStatus.completed && status != JobStatus.rejected;
        }).length;
        final completed = docs.where((doc) =>
          JobStatusExtension.fromString(doc.data()['status'] as String? ?? 'pending') == JobStatus.completed
        ).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('Your jobs', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Review assigned work and follow each job status.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _SummaryCard(label: 'Active', value: '$active', icon: Icons.pending_actions_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryCard(label: 'Completed', value: '$completed', icon: Icons.task_alt_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            for (final doc in docs)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => MechanicJobDetailScreen(jobId: doc.id),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(doc.data()['issue'] as String? ?? 'Repair job', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                            const SizedBox(width: 8),
                            _JobStatusPill(status: doc.data()['status'] as String? ?? 'pending'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Vehicle reference: ${doc.data()['vehicleId'] ?? 'Not available'}', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text(_dateLabel(doc.data()['createdAt']), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            const Icon(Icons.chevron_right_rounded),
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

  static String _dateLabel(dynamic value) {
    if (value is! Timestamp) return 'Date unavailable';
    final date = value.toDate().toLocal();
    return 'Created ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class MechanicEarningsScreen extends StatelessWidget {
  const MechanicEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _JobsState(icon: Icons.lock_outline_rounded, title: 'Sign in to view earnings', message: 'Your completed work is linked to your mechanic account.');
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('jobs').where('mechanicId', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _JobsState(icon: Icons.cloud_off_outlined, title: 'Earnings unavailable', message: 'Check your connection and try again.');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        final completed = docs.where((doc) =>
          JobStatusExtension.fromString(doc.data()['status'] as String? ?? 'pending') == JobStatus.completed
        ).toList();
        completed.sort((a, b) {
          final ad = a.data()['completedAt'];
          final bd = b.data()['completedAt'];
          final at = ad is Timestamp ? ad.millisecondsSinceEpoch : 0;
          final bt = bd is Timestamp ? bd.millisecondsSinceEpoch : 0;
          return bt.compareTo(at);
        });
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('Earnings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('A record of completed jobs assigned to your account.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(15)),
                    child: Icon(Icons.task_alt_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${completed.length}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const Text('Completed jobs recorded'),
                  ])),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
              child: const Text('Payment amounts and payout history are not shown because the current job record does not provide a verified payment amount or payout status.'),
            ),
            const SizedBox(height: 22),
            Text('Completed work', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (completed.isEmpty)
              const _JobsState(icon: Icons.account_balance_wallet_outlined, title: 'No completed jobs yet', message: 'Completed work will appear here when a job is marked completed.')
            else
              for (final doc in completed)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.build_outlined)),
                    title: Text(doc.data()['issue'] as String? ?? 'Repair job', maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('Completed: ${MechanicJobDetailScreen.timestampLabel(doc.data()['completedAt'])}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => MechanicJobDetailScreen(jobId: doc.id),
                    )),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class MechanicJobDetailScreen extends StatelessWidget {
  const MechanicJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Job details')),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('jobs').doc(jobId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _JobsState(icon: Icons.cloud_off_outlined, title: 'Job unavailable', message: 'Check your connection and try again.');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const _JobsState(icon: Icons.search_off_rounded, title: 'Job not found', message: 'This job may no longer be available.');
        }
        final data = snapshot.data!.data()!;
        final status = JobStatusExtension.fromString(data['status'] as String? ?? 'pending');
        final createdAt = data['createdAt'];
        final acceptedAt = data['acceptedAt'];
        final startedAt = data['startedAt'];
        final completedAt = data['completedAt'];
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(22)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.handyman_rounded, size: 32),
                  const SizedBox(height: 14),
                  Text('ASSIGNED JOB', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Text(data['issue'] as String? ?? 'Repair job', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  _JobStatusPill(status: status.value),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Job information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _JobDetailRow(label: 'Vehicle reference', value: data['vehicleId'] as String? ?? 'Not available'),
            _JobDetailRow(label: 'Job reference', value: snapshot.data!.id),
            _JobDetailRow(label: 'Created', value: _timestamp(createdAt)),
            const SizedBox(height: 22),
            Text('Progress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _TimelineEntry(title: 'Job created', date: _timestamp(createdAt), complete: true),
            _TimelineEntry(title: 'Accepted', date: _timestamp(acceptedAt), complete: acceptedAt is Timestamp),
            _TimelineEntry(title: 'Work started', date: _timestamp(startedAt), complete: startedAt is Timestamp),
            _TimelineEntry(title: 'Completed', date: _timestamp(completedAt), complete: completedAt is Timestamp),
            const SizedBox(height: 16),
            Text(
              'Job status changes will be enabled here after the trusted backend transition rules are verified. This screen currently displays the saved job record only.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        );
      },
    ),
  );

  static String timestampLabel(dynamic value) => _timestamp(value);\n\n  static String _timestamp(dynamic value) {
    if (value is! Timestamp) return 'Not recorded';
    final date = value.toDate().toLocal();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.title, required this.date, required this.complete});
  final String title;
  final String date;
  final bool complete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: complete ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ])),
      ]),
    ),
  );
}

class _JobStatusPill extends StatelessWidget {
  const _JobStatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(30)),
    child: Text(status.replaceAll('_', ' '), style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSecondaryContainer)),
  );
}

class _JobDetailRow extends StatelessWidget {
  const _JobDetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 130, child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );
}

class _JobsState extends StatelessWidget {
  const _JobsState({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    ),
  );
}

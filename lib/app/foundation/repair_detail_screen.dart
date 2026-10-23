import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Customer-facing detail view for an existing service request.
/// It deliberately does not accept quotes or mutate request status until a
/// trusted, transactional acceptance contract is available.
class RepairDetailScreen extends StatelessWidget {
  const RepairDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repair request')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('serviceRequests')
            .doc(requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _RepairState(
              icon: Icons.cloud_off_outlined,
              title: 'Request unavailable',
              message: 'Check your connection and try again.',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const _RepairState(
              icon: Icons.search_off_rounded,
              title: 'Request not found',
              message: 'This repair request may have been removed.',
            );
          }

          final data = snapshot.data!.data()!;
          final status = data['status'] as String? ?? 'open';
          final issue = data['issue'] as String? ?? 'Repair request';
          final vehicleId = data['vehicleId'] as String? ?? '';
          final createdAt = data['createdAt'];
          final createdLabel = createdAt is Timestamp
              ? _formatDate(createdAt.toDate())
              : 'Date unavailable';
          final jobId = data['jobId'] as String?;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.car_repair_rounded, size: 32),
                    const SizedBox(height: 16),
                    Text('REPAIR REQUEST', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                    const SizedBox(height: 8),
                    Text(issue, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    _StatusTag(status: status),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Request information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _DetailRow(label: 'Submitted', value: createdLabel),
              _DetailRow(label: 'Vehicle reference', value: vehicleId.isEmpty ? 'Not linked' : vehicleId),
              _DetailRow(label: 'Request reference', value: snapshot.data!.id),
              if (jobId != null && jobId.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_turned_in_outlined),
                    title: const Text('A job has been created'),
                    subtitle: Text('Job reference: $jobId'),
                    trailing: const Icon(Icons.info_outline_rounded),
                  ),
                ),
              ],
              if (status == 'open' || status == 'pending') ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _cancelRequest(context, snapshot.data!.reference),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel repair request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Mechanic responses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Quotes received for this request will appear here.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('serviceRequests')
                    .doc(requestId)
                    .collection('quotes')
                    .snapshots(),
                builder: (context, quoteSnapshot) {
                  if (quoteSnapshot.hasError) {
                    return const _RepairState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Could not load responses',
                      message: 'Request details are available, but mechanic responses could not be loaded.',
                    );
                  }
                  if (quoteSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final quotes = [...?quoteSnapshot.data?.docs];
                  if (quotes.isEmpty) {
                    return const _RepairState(
                      icon: Icons.hourglass_empty_rounded,
                      title: 'Waiting for responses',
                      message: 'There are no mechanic quotes on this request yet. Check back later for updates.',
                    );
                  }
                  quotes.sort((a, b) {
                    final ad = a.data()['createdAt'];
                    final bd = b.data()['createdAt'];
                    final at = ad is Timestamp ? ad.millisecondsSinceEpoch : 0;
                    final bt = bd is Timestamp ? bd.millisecondsSinceEpoch : 0;
                    return at.compareTo(bt);
                  });
                  return Column(
                    children: quotes.map((quote) {
                      final q = quote.data();
                      final price = q['price'];
                      final note = q['note'] as String? ?? '';
                      final quoteStatus = q['status'] as String? ?? 'pending';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(child: Icon(Icons.handyman_outlined)),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('Mechanic response', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                                  _StatusTag(status: quoteStatus),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(price is num ? '₦${price.toStringAsFixed(2)}' : 'Price not provided', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                              if (note.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(note),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Quote acceptance is not available in this screen yet. We will connect it only when the backend can accept one quote and create the corresponding job atomically.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cancelRequest(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> requestRef,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this repair request?'),
        content: const Text('The mechanic will no longer be expected to respond to this request. This action cannot be undone from the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await requestRef.update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repair request cancelled.')),
        );
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.code == 'permission-denied'
                ? 'You are not allowed to cancel this request.'
                : 'Could not cancel the request. Please try again.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel the request. Please try again.')),
        );
      }
    }
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day at ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(normalized, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSecondaryContainer)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

class _RepairState extends StatelessWidget {
  const _RepairState({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    ),
  );
}

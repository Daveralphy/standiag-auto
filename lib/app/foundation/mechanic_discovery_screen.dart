import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'vehicles_screen.dart';

/// Reads only server-approved, visible mechanics and lets a customer send a
/// service request linked to one of their saved vehicles.
class MechanicDiscoveryScreen extends StatefulWidget {
  const MechanicDiscoveryScreen({super.key});

  @override
  State<MechanicDiscoveryScreen> createState() => _MechanicDiscoveryScreenState();
}

class _MechanicDiscoveryScreenState extends State<MechanicDiscoveryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedExpertise = 'All services';
  String? _submittingMechanicId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    return SafeArea(
      child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Trusted help for your vehicle', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('Browse approved mechanics and send a repair request.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Search expertise or service area',
                      suffixIcon: _query.isEmpty ? null : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () { _searchController.clear(); setState(() => _query = ''); },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('mechanics').where('isVisible', isEqualTo: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const _DiscoveryState(icon: Icons.cloud_off_outlined, title: 'Mechanics are unavailable', message: 'Check your connection and try again.');
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final allDocs = snapshot.data?.docs ?? [];
                  final expertiseOptions = allDocs
                      .expand((doc) => (doc.data()['expertise'] as List? ?? []).whereType<String>())
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
                  final docs = allDocs.where((doc) {
                    final data = doc.data();
                    final expertiseList = (data['expertise'] as List? ?? []).whereType<String>().toList();
                    final expertise = expertiseList.join(' ');
                    final name = data['workshopName'] as String? ?? '';
                    final area = data['workshopAddress'] as String? ?? '';
                    final matchesQuery = '$expertise $name $area'.toLowerCase().contains(_query);
                    final matchesExpertise = _selectedExpertise == 'All services' ||
                        expertiseList.any((item) => item.trim().toLowerCase() == _selectedExpertise.toLowerCase());
                    return matchesQuery && matchesExpertise;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (expertiseOptions.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                          child: Row(
                            children: [
                              'All services',
                              ...expertiseOptions,
                            ].map((option) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(option),
                                selected: _selectedExpertise == option,
                                onSelected: (selected) {
                                  if (selected) setState(() => _selectedExpertise = option);
                                },
                              ),
                            )).toList(),
                          ),
                        ),
                      Expanded(
                        child: docs.isEmpty
                            ? _DiscoveryState(
                                icon: Icons.travel_explore_rounded,
                                title: allDocs.isEmpty
                                    ? 'No approved mechanics yet'
                                    : 'No matching mechanics',
                                message: allDocs.isEmpty
                                    ? 'Approved mechanics will appear here when they join Standiag Auto.'
                                    : 'Try another service, clear the service filter, or search a different location keyword.',
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                      final data = doc.data();
                      final expertise = (data['expertise'] as List? ?? []).whereType<String>().toList();
                      final workshop = data['workshopName'] as String?;
                      final title = workshop != null && workshop.trim().isNotEmpty ? workshop : 'Independent mechanic';
                      final area = data['workshopAddress'] as String? ?? 'Service area not provided';
                      final years = data['yearsOfExperience'] as num?;
                      final rating = data['rating'] as num?;
                      final hasRating = rating != null && rating > 0;
                      final hasExperience = years != null && years > 0;
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 52, height: 52,
                                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(15)),
                                    child: Icon(workshop != null && workshop.isNotEmpty ? Icons.garage_rounded : Icons.handyman_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 27),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      Text(area, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      const SizedBox(height: 5),
                                      if (hasRating || hasExperience)
                                        Text(
                                          [
                                            if (hasRating) '★ ${rating.toStringAsFixed(1)}',
                                            if (hasExperience) '${years.toInt()} years experience',
                                          ].join('  •  '),
                                          style: Theme.of(context).textTheme.labelMedium,
                                        ),
                                    ]),
                                  ),
                                ],
                              ),
                              if (expertise.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Wrap(spacing: 6, runSpacing: 6, children: expertise.take(5).map((item) => Chip(label: Text(item), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero)).toList()),
                              ],
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: uid == null || _submittingMechanicId != null ? null : () => _sendRequest(doc.id, title),
                                icon: _submittingMechanicId == doc.id ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded),
                                label: Text(_submittingMechanicId == doc.id ? 'Sending request…' : 'Request this mechanic'),
                              ),
                            ],
                          ),
                        ),
                      );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  Future<void> _sendRequest(String mechanicId, String mechanicName) async {
    final uid = _uid;
    if (uid == null) return;
    final vehicles = await FirebaseFirestore.instance.collection('vehicles').where('ownerId', isEqualTo: uid).get();
    if (!mounted) return;
    if (vehicles.docs.isEmpty) {
      final addVehicle = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add your vehicle first'),
          content: const Text('A repair request needs to be linked to one of your saved vehicles.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add vehicle')),
          ],
        ),
      );
      if (addVehicle == true && mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const VehiclesScreen()));
      }
      return;
    }

    final issue = TextEditingController();
    String selectedVehicleId = vehicles.docs.first.id;
    final formKey = GlobalKey<FormState>();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Request $mechanicName', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Choose the vehicle and describe the problem. The mechanic can review the request before responding.'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedVehicleId,
                    decoration: const InputDecoration(labelText: 'Vehicle'),
                    items: vehicles.docs.map((doc) {
                      final data = doc.data();
                      final label = '${data['year'] ?? ''} ${data['make'] ?? ''} ${data['model'] ?? ''}'.trim();
                      return DropdownMenuItem(value: doc.id, child: Text(label.isEmpty ? 'Vehicle' : label, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (value) => setSheetState(() => selectedVehicleId = value ?? selectedVehicleId),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: issue,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: const InputDecoration(labelText: 'What is wrong?', hintText: 'Describe the symptoms or repair needed'),
                    validator: (value) => value == null || value.trim().length < 8 ? 'Please describe the issue in a little more detail.' : null,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () {
                    if (formKey.currentState!.validate()) Navigator.of(sheetContext).pop(true);
                  }, child: const Text('Send repair request')),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) {
      issue.dispose();
      return;
    }

    setState(() => _submittingMechanicId = mechanicId);
    try {
      await FirebaseFirestore.instance.collection('serviceRequests').add({
        'carOwnerId': uid,
        'issue': issue.text.trim(),
        'vehicleId': selectedVehicleId,
        'radiusKm': 15.0,
        'targetMechanicId': mechanicId,
        'status': 'open',
        'createdAt': Timestamp.now(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repair request sent. You can track responses in My repairs.')));
    } on FirebaseException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.code == 'permission-denied' ? 'You do not have permission to send this request.' : 'Could not send your request. Please try again.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not send your request. Please try again.')));
    } finally {
      issue.dispose();
      if (mounted) setState(() => _submittingMechanicId = null);
    }
  }
}

class _DiscoveryState extends StatelessWidget {
  const _DiscoveryState({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    ),
  );
}

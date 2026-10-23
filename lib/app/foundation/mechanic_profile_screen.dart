import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Shows the approved mechanic profile without exposing client-side controls
/// for server-managed approval or public visibility fields.
class MechanicProfileScreen extends StatelessWidget {
  const MechanicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        appBar: AppBar(title: Text('Mechanic profile')),
        body: _MechanicProfileState(
          icon: Icons.lock_outline_rounded,
          title: 'Sign in to view your profile',
          message: 'Your mechanic profile is linked to your account.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mechanic profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('mechanics').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MechanicProfileState(
              icon: Icons.cloud_off_outlined,
              title: 'Profile unavailable',
              message: 'Check your connection and try again.',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const _MechanicProfileState(
              icon: Icons.person_search_outlined,
              title: 'Mechanic profile not found',
              message: 'Your mechanic profile may still be under review. Check your application status from onboarding.',
            );
          }

          final data = snapshot.data!.data()!;
          final workshopName = _value(data['workshopName'], fallback: 'Independent mechanic');
          final address = _value(data['workshopAddress'], fallback: 'Service area not provided');
          final expertise = (data['expertise'] as List? ?? []).whereType<String>().toList();
          final years = data['yearsOfExperience'];
          final phone = _value(data['phone'] ?? data['phoneNumber'], fallback: 'Not provided');
          final isVisible = data['isVisible'] == true;
          final approved = data['approvedAt'] != null;

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
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Icon(Icons.handyman_rounded, size: 32, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('MECHANIC PROFILE', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                    const SizedBox(height: 8),
                    Text(workshopName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(approved && isVisible ? Icons.verified_rounded : Icons.pending_outlined, size: 18),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        approved && isVisible ? 'Approved and visible to customers' : 'Profile access needs review',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      )),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Workshop information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _ProfileDetail(icon: Icons.location_on_outlined, label: 'Service area', value: address),
              _ProfileDetail(icon: Icons.phone_outlined, label: 'Contact phone', value: phone),
              _ProfileDetail(icon: Icons.workspace_premium_outlined, label: 'Experience', value: years is num ? '${years.toInt()} years' : 'Not provided'),
              const SizedBox(height: 20),
              Text('Expertise', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (expertise.isEmpty)
                const Text('No expertise areas are listed on this profile.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: expertise.map((item) => Chip(
                    avatar: const Icon(Icons.build_outlined, size: 16),
                    label: Text(item),
                  )).toList(),
                ),
              const SizedBox(height: 20),
              const _MechanicProfileNotice(
                text: 'Approval, public visibility and core workshop details are managed through the reviewed mechanic application. Editing will be added when a secure profile-update workflow is available.',
              ),
            ],
          );
        },
      ),
    );
  }

  static String _value(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    ),
  );
}

class _MechanicProfileNotice extends StatelessWidget {
  const _MechanicProfileNotice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline_rounded),
      const SizedBox(width: 10),
      Expanded(child: Text(text)),
    ]),
  );
}

class _MechanicProfileState extends StatelessWidget {
  const _MechanicProfileState({required this.icon, required this.title, required this.message});
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
        Text(message, textAlign: TextAlign.center),
      ]),
    ),
  );
}

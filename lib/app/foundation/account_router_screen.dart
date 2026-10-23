import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'account_journey_screen.dart';
import 'workspace_screen.dart';

/// Routes verified users according to their saved profile and approval state.
/// A missing profile returns to onboarding; approval is always read from the
/// server-managed mechanic document, never inferred from an application alone.
class AccountRouterScreen extends StatelessWidget {
  const AccountRouterScreen({
    super.key,
    required this.uid,
    required this.email,
    required this.onSignOut,
    required this.isSigningOut,
    this.errorMessage,
  });

  final String uid;
  final String email;
  final Future<void> Function() onSignOut;
  final bool isSigningOut;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      future: _loadAccount(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AccountLoadError(onRetry: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => AccountRouterScreen(
                uid: uid,
                email: email,
                onSignOut: onSignOut,
                isSigningOut: isSigningOut,
                errorMessage: errorMessage,
              ),
            ),
          ));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        final userProfile = snapshot.data![0];
        final mechanicProfile = snapshot.data![1];
        if (!userProfile.exists) {
          return AccountJourneyScreen(
            email: email,
            onSignOut: onSignOut,
            isSigningOut: isSigningOut,
            errorMessage: errorMessage,
          );
        }

        final mechanicData = mechanicProfile.data() ?? {};
        final isApprovedMechanic = mechanicProfile.exists &&
            mechanicData['approvedAt'] != null &&
            mechanicData['isVisible'] == true;

        return WorkspaceScreen(
          email: email,
          role: isApprovedMechanic ? WorkspaceRole.mechanic : WorkspaceRole.customer,
          onSignOut: onSignOut,
          onApplyMechanic: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AccountJourneyScreen(
                email: email,
                onSignOut: onSignOut,
                isSigningOut: isSigningOut,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _loadAccount() async {
    final firestore = FirebaseFirestore.instance;
    final results = await Future.wait([
      firestore.collection('users').doc(uid).get(),
      firestore.collection('mechanics').doc(uid).get(),
    ]);
    return results;
  }
}

class _AccountLoadError extends StatelessWidget {
  const _AccountLoadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 44),
              const SizedBox(height: 16),
              const Text('We could not load your account. Check your connection and try again.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    ),
  );
}

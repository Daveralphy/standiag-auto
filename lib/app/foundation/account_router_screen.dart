import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'account_journey_screen.dart';
import 'workspace_screen.dart';

/// Routes verified users according to their saved profile and approval state.
/// A missing profile returns to onboarding; approval is always read from the
/// server-managed mechanic document, never inferred from an application alone.
class AccountRouterScreen extends StatefulWidget {
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
  State<AccountRouterScreen> createState() => _AccountRouterScreenState();
}

class _AccountRouterScreenState extends State<AccountRouterScreen> {
  late Future<List<DocumentSnapshot<Map<String, dynamic>>>> _accountFuture;

  @override
  void initState() {
    super.initState();
    _accountFuture = _loadAccount();
  }

  @override
  void didUpdateWidget(covariant AccountRouterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _accountFuture = _loadAccount();
    }
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _loadAccount() async {
    final firestore = FirebaseFirestore.instance;
    return Future.wait([
      firestore.collection('users').doc(widget.uid).get(),
      firestore.collection('mechanics').doc(widget.uid).get(),
    ]);
  }

  void _retry() {
    setState(() => _accountFuture = _loadAccount());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AccountLoadError(onRetry: _retry);
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
            email: widget.email,
            onSignOut: widget.onSignOut,
            isSigningOut: widget.isSigningOut,
            errorMessage: widget.errorMessage,
          );
        }

        final mechanicData = mechanicProfile.data() ?? {};
        final isApprovedMechanic = mechanicProfile.exists &&
            mechanicData['approvedAt'] != null &&
            mechanicData['isVisible'] == true;

        return WorkspaceScreen(
          email: widget.email,
          role: isApprovedMechanic
              ? WorkspaceRole.mechanic
              : WorkspaceRole.customer,
          onSignOut: widget.onSignOut,
          onApplyMechanic: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AccountJourneyScreen(
                email: widget.email,
                onSignOut: widget.onSignOut,
                isSigningOut: widget.isSigningOut,
              ),
            ),
          ),
        );
      },
    );
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We could not load your account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your connection and try again. Your account has not been changed.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

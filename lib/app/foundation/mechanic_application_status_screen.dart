import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// Dedicated status and review-note screen for mechanic applicants.
/// Application decisions remain server-controlled.
class MechanicApplicationStatusScreen extends StatefulWidget {
  const MechanicApplicationStatusScreen({super.key});

  @override
  State<MechanicApplicationStatusScreen> createState() =>
      _MechanicApplicationStatusScreenState();
}

class _MechanicApplicationStatusScreenState
    extends State<MechanicApplicationStatusScreen> {
  bool _loading = false;
  bool _checked = false;
  String? _status;
  String? _reviewNote;
  String? _error;

  Future<void> _loadStatus() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getMyMechanicApplication')
          .call();
      if (!mounted) return;
      final data = result.data;
      if (data is! Map || data['exists'] != true) {
        setState(() {
          _checked = true;
          _status = 'not_submitted';
          _reviewNote = null;
        });
        return;
      }
      setState(() {
        _checked = true;
        _status = data['status'] as String? ?? 'pending';
        _reviewNote = data['decisionReason'] as String?;
      });
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'We could not load your application. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
        return 'Your session has expired. Sign in again to check your application.';
      case 'failed-precondition':
        return 'Verify your email before checking your mechanic application.';
      case 'permission-denied':
        return 'You do not have permission to view this application.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'The service is temporarily unavailable. Please try again.';
      default:
        return error.message ?? 'We could not load your application. Please try again.';
    }
  }

  ({IconData icon, Color color, String title, String description}) _presentation(
    ColorScheme colors,
  ) {
    switch (_status) {
      case 'pending':
        return (icon: Icons.hourglass_top_rounded, color: colors.tertiary,
          title: 'Application under review',
          description: 'Your application has been received. An administrator must review and approve it before mechanic tools become available.');
      case 'approved':
        return (icon: Icons.verified_rounded, color: colors.primary,
          title: 'Application approved',
          description: 'Your application has been approved. If mechanic tools are not visible yet, refresh your account or sign in again.');
      case 'rejected':
        return (icon: Icons.info_outline_rounded, color: colors.error,
          title: 'Application not approved',
          description: 'Your application was not approved. Read the review note below for any guidance provided by the team.');
      case 'more_information':
        return (icon: Icons.assignment_late_outlined, color: colors.tertiary,
          title: 'More information needed',
          description: 'The team needs additional information before it can complete the review. Check the note below for details.');
      default:
        return (icon: Icons.assignment_outlined, color: colors.onSurfaceVariant,
          title: 'No application found',
          description: 'There is no mechanic application linked to this account yet. You can return to account setup and submit one when you are ready.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = _presentation(colors);
    return Scaffold(
      appBar: AppBar(title: const Text('Mechanic application')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: state.color.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(state.icon, color: state.color, size: 30),
                        ),
                        const SizedBox(height: 20),
                        Text('APPLICATION STATUS',
                          style: theme.textTheme.labelMedium?.copyWith(
                            letterSpacing: 1.2, fontWeight: FontWeight.w800,
                            color: colors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Text(_checked ? state.title : 'Check your application',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        Text(_checked ? state.description :
                          'View the latest review status and any note from the Standiag Auto team.',
                          style: theme.textTheme.bodyLarge),
                        if (_checked && _reviewNote != null && _reviewNote!.trim().isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              border: Border.all(color: colors.outlineVariant),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Review note', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                Text(_reviewNote!),
                              ],
                            ),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_error!, style: TextStyle(color: colors.onErrorContainer)),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _loading ? null : _loadStatus,
                          icon: _loading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.refresh_rounded),
                          label: Text(_loading ? 'Checking application…' : _checked ? 'Refresh status' : 'Check application status'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Back to account setup'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Approval is handled by the Standiag Auto team. Submitting an application does not automatically grant mechanic access.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

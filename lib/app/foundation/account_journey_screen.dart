import 'package:flutter/material.dart';

/// First-run account journey for a verified Firebase user.
///
/// This screen intentionally does not write role or approval fields to
/// Firestore. Persistence will be connected only after the profile write
/// contract and Firestore rules are tightened together.
class AccountJourneyScreen extends StatefulWidget {
  const AccountJourneyScreen({
    super.key,
    required this.email,
    required this.onSignOut,
    required this.isSigningOut,
    this.errorMessage,
  });

  final String email;
  final Future<void> Function() onSignOut;
  final bool isSigningOut;
  final String? errorMessage;

  @override
  State<AccountJourneyScreen> createState() => _AccountJourneyScreenState();
}

class _AccountJourneyScreenState extends State<AccountJourneyScreen> {
  _JourneyStep _step = _JourneyStep.choose;
  bool _isWorkshop = false;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _experience = TextEditingController();
  final _expertise = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _experience.dispose();
    _expertise.dispose();
    super.dispose();
  }

  void _showComingSoon(String journey) {
    setState(() {
      _message = '$journey setup is being connected to secure profile storage. '
          'Your account is safe, and no profile changes have been saved yet.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your account'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.isSigningOut ? null : widget.onSignOut,
            icon: widget.isSigningOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      size: 32,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _step == _JourneyStep.choose
                        ? 'Welcome to Standiag Auto'
                        : 'Mechanic application',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _step == _JourneyStep.choose
                        ? 'Choose how you want to get started. You can use one account for car care and apply to offer repair services later.'
                        : 'Tell us about your work. Applying does not automatically approve a mechanic account.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.email, style: theme.textTheme.bodyMedium),
                  if (widget.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _Notice(message: widget.errorMessage!, isError: true),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    _Notice(message: _message!, isError: false),
                  ],
                  const SizedBox(height: 24),
                  if (_step == _JourneyStep.choose) ...[
                    _JourneyCard(
                      icon: Icons.directions_car_outlined,
                      title: 'I need car care',
                      description:
                          'Find mechanics, manage your vehicles, and track repairs.',
                      actionLabel: 'Continue as a customer',
                      onPressed: () => _showComingSoon('Customer'),
                    ),
                    const SizedBox(height: 14),
                    _JourneyCard(
                      icon: Icons.handyman_outlined,
                      title: 'I repair vehicles',
                      description:
                          'Create a mechanic or workshop profile and submit it for review.',
                      actionLabel: 'Apply as a mechanic',
                      onPressed: () => setState(() {
                        _step = _JourneyStep.mechanic;
                        _message = null;
                      }),
                    ),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('I represent a workshop'),
                              subtitle: const Text(
                                'Turn this on for a workshop or garage rather than an independent mechanic.',
                              ),
                              value: _isWorkshop,
                              onChanged: (value) =>
                                  setState(() => _isWorkshop = value),
                            ),
                            const SizedBox(height: 8),
                            _field(_firstName, 'First name', required: true),
                            const SizedBox(height: 12),
                            _field(_lastName, 'Last name', required: true),
                            const SizedBox(height: 12),
                            _field(
                              _phone,
                              'Phone number',
                              keyboardType: TextInputType.phone,
                              required: true,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              _address,
                              _isWorkshop
                                  ? 'Workshop address'
                                  : 'Base address or service area',
                              required: true,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              _experience,
                              'Years of experience',
                              keyboardType: TextInputType.number,
                              required: true,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              _expertise,
                              'Areas of expertise',
                              hint: 'e.g. diagnostics, brakes, engine repair',
                              required: true,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: () {
                                final valid = _firstName.text.trim().isNotEmpty &&
                                    _lastName.text.trim().isNotEmpty &&
                                    _phone.text.trim().isNotEmpty &&
                                    _address.text.trim().isNotEmpty &&
                                    _expertise.text.trim().isNotEmpty &&
                                    int.tryParse(_experience.text.trim()) != null &&
                                    int.parse(_experience.text.trim()) >= 0;
                                setState(() {
                                  _message = valid
                                      ? 'Your application form is ready. Secure saving, document checks, and approval status are not connected yet, so nothing has been submitted.'
                                      : 'Complete all fields and enter a valid, non-negative number of years.';
                                });
                              },
                              child: const Text('Review application details'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(() {
                                _step = _JourneyStep.choose;
                                _message = null;
                              }),
                              child: const Text('Back to account options'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) =>
              (value == null || value.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }
}

enum _JourneyStep { choose, mechanic }

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onPressed,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isError ? colors.error : colors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}

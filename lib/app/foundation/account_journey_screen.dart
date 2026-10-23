import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'workspace_screen.dart';

/// Verified account setup. Privileged profile changes are performed by
/// callable backend functions, never by direct client writes.
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
  bool _isSaving = false;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _workshopName = TextEditingController();
  final _experience = TextEditingController();
  final _expertise = TextEditingController();
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _workshopName.dispose();
    _experience.dispose();
    _expertise.dispose();
    super.dispose();
  }

  Future<void> _saveCustomerProfile() async {
    if (_isSaving) return;
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      _showMessage('Enter your first name, last name, and phone number.', error: true);
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });
    try {
      await FirebaseFunctions.instance.httpsCallable('saveCustomerProfile').call({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': _phone.text.trim(),
      });
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WorkspaceScreen(
            email: widget.email,
            role: WorkspaceRole.customer,
            onSignOut: widget.onSignOut,
          ),
        ),
      );
    } on FirebaseFunctionsException catch (error) {
      if (mounted) _showMessage(_friendlyFunctionError(error), error: true);
    } catch (_) {
      if (mounted) _showMessage('We could not save your profile. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _submitMechanicApplication() async {
    if (_isSaving) return;
    final years = int.tryParse(_experience.text.trim());
    final expertise = _expertise.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final name = '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();

    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        years == null ||
        years < 0 ||
        expertise.isEmpty ||
        (_isWorkshop && _workshopName.text.trim().isEmpty)) {
      _showMessage(
        'Complete all required fields. Enter years as a non-negative whole number and separate expertise areas with commas.',
        error: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('submitMechanicApplication')
          .call({
        'applicantName': name,
        'phone': _phone.text.trim(),
        'serviceArea': _address.text.trim(),
        'yearsOfExperience': years,
        'expertise': expertise,
        'applicantType': _isWorkshop ? 'workshop' : 'independent',
        if (_isWorkshop) 'workshopName': _workshopName.text.trim(),
      });
      if (!mounted) return;
      final status = (result.data as Map?)?['status'] as String? ?? 'pending';
      _showMessage(
        status == 'pending'
            ? 'Your application has been submitted for review. You will not receive mechanic access until an administrator approves it.'
            : 'Your application status is $status.',
      );
    } on FirebaseFunctionsException catch (error) {
      if (mounted) _showMessage(_friendlyFunctionError(error), error: true);
    } catch (_) {
      if (mounted) _showMessage('We could not submit your application. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _friendlyFunctionError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
        return 'Your session has expired. Please sign in again.';
      case 'failed-precondition':
        return 'Verify your email before continuing, or check your application status.';
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'invalid-argument':
        return error.message ?? 'Please check the details and try again.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'The service is temporarily unavailable. Please try again.';
      default:
        return 'We could not complete this request. Please try again.';
    }
  }

  void _showMessage(String message, {bool error = false}) {
    setState(() {
      _message = message;
      _isError = error;
    });
  }

  void _goTo(_JourneyStep step) {
    setState(() {
      _step = step;
      _message = null;
      _isError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isChoosing = _step == _JourneyStep.choose;
    final isCustomer = _step == _JourneyStep.customer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your account'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.isSigningOut || _isSaving ? null : widget.onSignOut,
            icon: widget.isSigningOut
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
                    child: Icon(Icons.directions_car_filled_rounded, size: 32, color: colors.onPrimaryContainer),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isChoosing ? 'Welcome to Standiag Auto' : isCustomer ? 'Customer profile' : 'Mechanic application',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isChoosing
                        ? 'Use one account for car care and apply to offer repair services whenever you are ready.'
                        : isCustomer
                            ? 'Complete your basic details to set up your customer profile.'
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
                    _Notice(message: _message!, isError: _isError),
                  ],
                  const SizedBox(height: 24),
                  if (isChoosing) ...[
                    _JourneyCard(
                      icon: Icons.directions_car_outlined,
                      title: 'I need car care',
                      description: 'Find mechanics, manage your vehicles, and track repairs.',
                      actionLabel: 'Continue as a customer',
                      onPressed: () => _goTo(_JourneyStep.customer),
                    ),
                    const SizedBox(height: 14),
                    _JourneyCard(
                      icon: Icons.handyman_outlined,
                      title: 'I repair vehicles',
                      description: 'Create a mechanic or workshop profile and submit it for review.',
                      actionLabel: 'Apply as a mechanic',
                      onPressed: () => _goTo(_JourneyStep.mechanic),
                    ),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isCustomer)
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('I represent a workshop'),
                                subtitle: const Text('Turn this on for a workshop or garage rather than an independent mechanic.'),
                                value: _isWorkshop,
                                onChanged: _isSaving ? null : (value) => setState(() => _isWorkshop = value),
                              ),
                            _field(_firstName, 'First name'),
                            const SizedBox(height: 12),
                            _field(_lastName, 'Last name'),
                            const SizedBox(height: 12),
                            _field(_phone, 'Phone number', keyboardType: TextInputType.phone),
                            if (!isCustomer) ...[
                              const SizedBox(height: 12),
                              if (_isWorkshop) ...[
                                _field(_workshopName, 'Workshop name'),
                                const SizedBox(height: 12),
                              ],
                              _field(
                                _address,
                                _isWorkshop ? 'Workshop address' : 'Base address or service area',
                                                        maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              _field(_experience, 'Years of experience', keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              _field(
                                _expertise,
                                'Areas of expertise',
                                hint: 'Diagnostics, brakes, engine repair',
                                                        maxLines: 3,
                              ),
                            ],
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: _isSaving ? null : (isCustomer ? _saveCustomerProfile : _submitMechanicApplication),
                              child: _isSaving
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(isCustomer ? 'Save customer profile' : 'Submit for review'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _isSaving ? null : () => _goTo(_JourneyStep.choose),
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

enum _JourneyStep { choose, customer, mechanic }

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
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
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
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
    );
  }
}

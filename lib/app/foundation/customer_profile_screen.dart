import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// Editable customer profile using the existing server-side profile callable.
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _loadedOnce = false;
  String? _error;
  String? _success;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = _uid;
    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'Sign in again to edit your profile.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!mounted) return;
      final data = doc.data() ?? <String, dynamic>{};
      _firstName.text = data['firstName'] as String? ?? '';
      _lastName.text = data['lastName'] as String? ?? '';
      _phone.text = data['phone'] as String? ?? '';
      setState(() {
        _loading = false;
        _loadedOnce = true;
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.code == 'permission-denied'
            ? 'You do not have permission to view this profile.'
            : 'We could not load your profile. Check your connection and retry.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'We could not load your profile. Check your connection and retry.';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      await FirebaseFunctions.instance.httpsCallable('saveCustomerProfile').call({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': _phone.text.trim(),
      });
      if (!mounted) return;
      setState(() => _success = 'Your profile has been updated.');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully.')));
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'unauthenticated' => 'Your session has expired. Sign in again.',
        'failed-precondition' => 'Verify your email before editing your profile.',
        'invalid-argument' => error.message ?? 'Check the details and try again.',
        'permission-denied' => 'You do not have permission to update this profile.',
        'unavailable' || 'deadline-exceeded' => 'The service is unavailable. Try again shortly.',
        _ => 'We could not update your profile. Please try again.',
      };
      setState(() => _error = message);
    } catch (_) {
      if (mounted) setState(() => _error = 'We could not update your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_loadedOnce
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Icon(Icons.person_off_outlined, size: 48),
                    const SizedBox(height: 16),
                    Text(_error ?? 'Profile unavailable', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _loadProfile, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
                  ],
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: theme.colorScheme.surface,
                              child: Icon(Icons.person_outline_rounded, size: 30, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your personal details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('Keep your contact details up to date.', style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_error != null) _MessagePanel(message: _error!, isError: true),
                      if (_success != null) ...[
                        _MessagePanel(message: _success!, isError: false),
                        const SizedBox(height: 12),
                      ],
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _firstName,
                              enabled: !_saving,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.givenName],
                              decoration: const InputDecoration(labelText: 'First name', prefixIcon: Icon(Icons.person_outline_rounded)),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Enter your first name' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _lastName,
                              enabled: !_saving,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.familyName],
                              decoration: const InputDecoration(labelText: 'Last name', prefixIcon: Icon(Icons.person_outline_rounded)),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Enter your last name' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phone,
                              enabled: !_saving,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [AutofillHints.telephoneNumber],
                              decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone_outlined)),
                              validator: (value) {
                                final phone = value?.trim() ?? '';
                                if (phone.isEmpty) return 'Enter your phone number';
                                if (phone.replaceAll(RegExp(r'[^0-9+]'), '').length < 7) return 'Enter a valid phone number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            FilledButton.icon(
                              onPressed: _saving ? null : _saveProfile,
                              icon: _saving
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.save_outlined),
                              label: Text(_saving ? 'Saving changes…' : 'Save changes'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _saving ? null : () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: isError ? colors.onErrorContainer : colors.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: isError ? colors.onErrorContainer : colors.onSecondaryContainer))),
        ],
      ),
    );
  }
}

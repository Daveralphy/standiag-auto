import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Authentication boundary for the fresh application foundation.
///
/// Keep this screen focused on sign-in and account access. Role-specific
/// profiles and navigation are introduced only after their persisted contracts
/// have been verified.
class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late Stream<User?> _authStateChanges;

  bool _isCreatingAccount = false;
  bool _isSubmitting = false;
  bool _isSendingReset = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _statusMessage;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    // Reuse one stream for the lifetime of this screen. Recreating it in
    // build() would resubscribe whenever any form state changes.
    _authStateChanges = FirebaseAuth.instance.userChanges();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _isSendingReset) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      if (_isCreatingAccount) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await credential.user?.sendEmailVerification();
      } else {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyAuthError(error.code));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      if (mounted) {
        setState(() {
          _errorMessage = 'We could not sign you out. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'We could not sign you out. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isSendingReset) return;
    setState(() {
      _isSendingReset = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Your session has expired. Please sign in again.';
        });
        return;
      }
      await user.sendEmailVerification();
      if (mounted) {
        setState(() {
          _statusMessage = 'A new verification email has been requested.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyAuthError(error.code));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'We could not send the verification email. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Your session has expired. Please sign in again.';
        });
        return;
      }
      await user.reload();
      if (!mounted) return;

      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser?.emailVerified == true) {
        setState(() {
          _statusMessage = 'Email verified. Loading your account…';
        });
      } else {
        setState(() {
          _statusMessage = 'Your email is not verified yet. Open the link '
              'in your email, then check again.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyAuthError(error.code));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'We could not check verification yet. Try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_isSubmitting || _isSendingReset) return;

    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Enter your email address above first.';
        _statusMessage = null;
      });
      return;
    }

    setState(() {
      _isSendingReset = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() {
          // Keep the message neutral; do not disclose whether an account
          // exists for the submitted email address.
          _statusMessage =
              'If an account exists for this email, a reset link will be sent.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyAuthError(error.code));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'We could not send the reset email. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    final at = email.indexOf('@');
    return at > 0 &&
        at == email.lastIndexOf('@') &&
        at < email.length - 1 &&
        email.substring(at + 1).contains('.') &&
        !email.endsWith('.');
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists for this email. Try signing in.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password with at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled yet. Contact support.';
      default:
        return 'Authentication could not be completed. Please try again.';
    }
  }

  void _toggleMode() {
    if (_isSubmitting || _isSendingReset) return;
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _errorMessage = null;
      _statusMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return StreamBuilder<User?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AuthUnavailableScreen(
            onRetry: () => setState(
              () => _authStateChanges = FirebaseAuth.instance.userChanges(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null && !user.emailVerified) {
          return _EmailVerificationScreen(
            email: user.email ?? _emailController.text.trim(),
            onResend: _resendVerificationEmail,
            onCheckVerification: _checkVerificationStatus,
            isSending: _isSendingReset || _isSubmitting,
            errorMessage: _errorMessage,
            statusMessage: _statusMessage,
          );
        }

        if (user != null) {
          return _SignedInPlaceholder(
            email: user.email ?? 'Signed in',
            onSignOut: _signOut,
            isSigningOut: _isSigningOut,
            errorMessage: _errorMessage,
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
                  shrinkWrap: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.build_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Standiag Auto',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isCreatingAccount
                          ? 'Create your account to get started.'
                          : 'Car care, made simpler.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (value) {
                              if (!_isValidEmail(value ?? '')) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            autofillHints: [
                              _isCreatingAccount
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return 'Use at least 6 characters.';
                              }
                              return null;
                            },
                          ),
                          if (!_isCreatingAccount) ...[
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed:
                                    _isSubmitting || _isSendingReset
                                        ? null
                                        : _sendPasswordReset,
                                child: _isSendingReset
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Forgot password?'),
                              ),
                            ),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            _InlineMessage(
                              message: _errorMessage!,
                              isError: true,
                            ),
                          ],
                          if (_statusMessage != null) ...[
                            const SizedBox(height: 8),
                            _InlineMessage(
                              message: _statusMessage!,
                              isError: false,
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                _isSubmitting || _isSendingReset ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isCreatingAccount
                                        ? 'Create account'
                                        : 'Sign in',
                                  ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              _isCreatingAccount
                                  ? 'Already have an account? Sign in'
                                  : 'New to Standiag Auto? Create an account',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmailVerificationScreen extends StatelessWidget {
  const _EmailVerificationScreen({
    required this.email,
    required this.onResend,
    required this.onCheckVerification,
    required this.isSending,
    required this.errorMessage,
    required this.statusMessage,
  });

  final String email;
  final Future<void> Function() onResend;
  final Future<void> Function() onCheckVerification;
  final bool isSending;
  final String? errorMessage;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 56,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Open the verification link we sent you. You must verify '
                    'your email before continuing.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(email, textAlign: TextAlign.center),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 20),
                    _InlineMessage(message: errorMessage!, isError: true),
                  ],
                  if (statusMessage != null) ...[
                    const SizedBox(height: 12),
                    _InlineMessage(message: statusMessage!, isError: false),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSending ? null : onCheckVerification,
                    child: isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('I have verified my email'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isSending ? null : onResend,
                    child: const Text('Resend verification email'),
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

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.isError,
  });

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

class _AuthUnavailableScreen extends StatelessWidget {
  const _AuthUnavailableScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sign-in is temporarily unavailable',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Check your connection and Firebase configuration, then '
                    'try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Try again'),
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

class _SignedInPlaceholder extends StatelessWidget {
  const _SignedInPlaceholder({
    required this.email,
    required this.onSignOut,
    required this.isSigningOut,
    required this.errorMessage,
  });

  final String email;
  final Future<void> Function() onSignOut;
  final bool isSigningOut;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 52,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'You are signed in',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(email, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  const Text(
                    'Your customer and mechanic workspace is being rebuilt. '
                    'Your account is connected, but the new workspace is not '
                    'available yet.',
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _InlineMessage(message: errorMessage!, isError: true),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: isSigningOut ? null : onSignOut,
                    child: isSigningOut
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign out'),
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

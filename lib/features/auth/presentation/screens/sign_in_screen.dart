import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_sign_in_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go(AppRoutes.feed);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
    } catch (_) {
      setState(() => _errorMessage = AppLocalizations.of(context).error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final credential = await authRepo.signInWithGoogle();
      if (credential == null) {
        // User cancelled the Google sign-in flow.
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        // Check if this is a new user — navigate to profile setup if so.
        final userRepo = ref.read(userRepositoryProvider);
        final existingUser = await userRepo.getUser(credential.user!.uid);
        if (existingUser == null) {
          context.go(AppRoutes.profileSetup);
        } else {
          context.go(AppRoutes.feed);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
    } catch (_) {
      setState(() => _errorMessage = AppLocalizations.of(context).error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // ── Error banner ──
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Email ──
                AppTextField(
                  controller: _emailController,
                  label: l10n.email,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // ── Password ──
                AppTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onSubmitted: (_) => _signInWithEmail(),
                ),
                const SizedBox(height: 8),

                // ── Forgot password ──
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: l10n.forgotPassword,
                    variant: AppButtonVariant.text,
                    isFullWidth: false,
                    onPressed: () => _showForgotPasswordDialog(context),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign In button ──
                AppButton(
                  label: l10n.signIn,
                  isLoading: _isLoading,
                  onPressed: _signInWithEmail,
                ),
                const SizedBox(height: 24),

                // ── Divider ──
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.orContinueWith,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Google sign-in ──
                SocialSignInButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 32),

                // ── Link to sign up ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: theme.textTheme.bodyMedium,
                    ),
                    AppButton(
                      label: l10n.signUp,
                      variant: AppButtonVariant.text,
                      isFullWidth: false,
                      onPressed: () => context.push(AppRoutes.signUp),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resetEmailController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.forgotPassword),
        content: AppTextField(
          controller: resetEmailController,
          label: l10n.email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              final authRepo = ref.read(authRepositoryProvider);
              await authRepo.sendPasswordResetEmail(email);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

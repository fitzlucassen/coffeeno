import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_sign_in_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final credential = await authRepo.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user!;
      await user.updateDisplayName(_displayNameController.text.trim());

      final appUser = AppUser(
        uid: user.uid,
        email: _emailController.text.trim(),
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        createdAt: DateTime.now(),
      );

      await userRepo.createUser(appUser);

      if (mounted) context.go(AppRoutes.profileSetup);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
    } catch (e) {
      debugPrint('Sign up error: $e');
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final credential = await authRepo.signInWithGoogle();
      if (credential == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
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
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password sign up is not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signUp)),
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

                // ── Display Name ──
                AppTextField(
                  controller: _displayNameController,
                  label: l10n.displayName,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.required(value, l10n.displayName),
                ),
                const SizedBox(height: 16),

                // ── Username ──
                AppTextField(
                  controller: _usernameController,
                  label: l10n.username,
                  prefixIcon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                  validator: Validators.username,
                ),
                const SizedBox(height: 16),

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
                  onSubmitted: (_) => _signUpWithEmail(),
                ),
                const SizedBox(height: 24),

                // ── Sign Up button ──
                AppButton(
                  label: l10n.signUp,
                  isLoading: _isLoading,
                  onPressed: _signUpWithEmail,
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
                  onPressed: _isLoading ? null : _signUpWithGoogle,
                ),
                const SizedBox(height: 32),

                // ── Link to sign in ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: theme.textTheme.bodyMedium,
                    ),
                    AppButton(
                      label: l10n.signIn,
                      variant: AppButtonVariant.text,
                      isFullWidth: false,
                      onPressed: () => context.push(AppRoutes.signIn),
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
}

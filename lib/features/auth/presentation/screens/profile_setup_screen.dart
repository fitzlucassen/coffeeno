import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/app_user.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillFromAuth();
  }

  /// Pre-fills the form with data from the Firebase Auth user.
  void _prefillFromAuth() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
      // Derive a default username from the email prefix.
      final emailPrefix = user.email?.split('@').first ?? '';
      _usernameController.text = emailPrefix.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userRepo = ref.read(userRepositoryProvider);

      // Check whether a Firestore user doc already exists (Google sign-in may
      // not have created one yet).
      final existing = await userRepo.getUser(user.uid);

      if (existing != null) {
        final displayName = _displayNameController.text.trim();
        final username = _usernameController.text.trim().toLowerCase();
        await userRepo.updateUser(user.uid, {
          'displayName': displayName,
          'displayNameLower': displayName.toLowerCase(),
          'username': username,
          'usernameLower': username.toLowerCase(),
          'bio': _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
        });
      } else {
        // Create a new user doc (common after Google sign-in).
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: _displayNameController.text.trim(),
          username: _usernameController.text.trim().toLowerCase(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          avatarUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await userRepo.createUser(appUser);
      }

      // Refresh the currentUserProvider so downstream widgets see the update.
      ref.invalidate(currentUserProvider);

      if (mounted) context.go(AppRoutes.feed);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRepo = ref.read(userRepositoryProvider);
    final existing = await userRepo.getUser(user.uid);
    if (existing == null) {
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? user.email?.split('@').first ?? '',
        username: user.email?.split('@').first.toLowerCase() ?? user.uid,
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await userRepo.createUser(appUser);
    }

    if (mounted) context.go(AppRoutes.feed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _skip,
            child: Text(l10n.cancel), // "Skip" — using cancel string
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),

                // ── Avatar placeholder ──
                GestureDetector(
                  onTap: () {
                    // TODO: implement image picker for avatar
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: isDark
                            ? AppColors.darkCard
                            : AppColors.terracottaMuted.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.person_outline,
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.espressoMuted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

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

                // ── Bio (optional) ──
                AppTextField(
                  controller: _bioController,
                  label: l10n.bio,
                  prefixIcon: Icons.short_text,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  onSubmitted: (_) => _completeSetup(),
                ),
                const SizedBox(height: 32),

                // ── Complete Setup button ──
                AppButton(
                  label: l10n.save,
                  isLoading: _isLoading,
                  onPressed: _completeSetup,
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

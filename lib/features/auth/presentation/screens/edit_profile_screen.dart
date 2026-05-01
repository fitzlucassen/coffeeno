import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../../../social/presentation/providers/social_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    ref.read(userRepositoryProvider).getUser(uid).then((user) {
      if (user != null && mounted) {
        setState(() {
          _displayNameController.text = user.displayName;
          _usernameController.text = user.username;
          _bioController.text = user.bio ?? '';
          _countryController.text = user.country ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userRepo = ref.read(userRepositoryProvider);
      final displayName = _displayNameController.text.trim();
      final username = _usernameController.text.trim().toLowerCase();

      await userRepo.updateUser(uid, {
        'displayName': displayName,
        'displayNameLower': displayName.toLowerCase(),
        'username': username,
        'usernameLower': username.toLowerCase(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'country': _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
      });

      ref.invalidate(userProfileProvider(uid));
      ref.invalidate(currentUserProvider);

      if (mounted) context.pop();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                AppTextField(
                  controller: _displayNameController,
                  label: l10n.displayName,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.required(value, l10n.displayName),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _usernameController,
                  label: l10n.username,
                  prefixIcon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                  validator: Validators.username,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _bioController,
                  label: l10n.bio,
                  prefixIcon: Icons.short_text,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _countryController,
                  label: l10n.country,
                  prefixIcon: Icons.public,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: l10n.save,
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

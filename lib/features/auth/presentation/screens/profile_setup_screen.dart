import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/photo_upload_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_photo_picker.dart';
import '../../data/user_repository.dart';
import '../../domain/app_user.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  bool _prefilled = false;
  String? _avatarUrl;
  String? _pendingPhotoPath;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Seed a best-effort fallback from the auth account (Google display name /
    // photo, or the email prefix as a username). This is NOT locking: once the
    // Firestore user doc becomes available in build() it overrides these, which
    // is what stops the just-entered name/username from being clobbered by the
    // email prefix (e.g. "AdrianF" → "hvivas249").
    final authUser = ref.read(authStateProvider).value;
    if (authUser != null) {
      _displayNameController.text = authUser.displayName ?? '';
      final emailPrefix = authUser.email?.split('@').first ?? '';
      _usernameController.text = emailPrefix.replaceAll(
        RegExp(r'[^a-zA-Z0-9_]'),
        '',
      );
      _avatarUrl = authUser.photoURL;
    }
  }

  void _prefill(AppUser user) {
    _displayNameController.text = user.displayName;
    _usernameController.text = user.username;
    _bioController.text = user.bio ?? '';
    _avatarUrl = user.avatarUrl;
    _prefilled = true;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _pendingPhotoPath = image.path);
  }

  /// Uploads a freshly picked avatar (if any) and returns the URL to persist,
  /// falling back to whatever avatar is already set.
  Future<String?> _uploadPendingPhoto(String uid) async {
    if (_pendingPhotoPath == null) return _avatarUrl;
    setState(() => _uploadingPhoto = true);
    try {
      return await ref
          .read(photoUploadServiceProvider)
          .uploadJpeg(pathPrefix: 'users/$uid', localPath: _pendingPhotoPath!);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final userRepo = ref.read(userRepositoryProvider);

      // Upload any freshly picked avatar first so both branches persist the
      // final URL.
      final finalAvatarUrl = await _uploadPendingPhoto(user.uid);

      // Check whether a Firestore user doc already exists (Google sign-in may
      // not have created one yet).
      final existing = await userRepo.getUser(user.uid);

      if (existing != null) {
        await userRepo.updateUser(
          user.uid,
          UserRepository.buildProfileUpdate(
            displayName: _displayNameController.text,
            username: _usernameController.text,
            bio: _bioController.text,
            includeBio: true,
            avatarUrl: finalAvatarUrl,
            includeAvatar: true,
          ),
        );
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
          avatarUrl: finalAvatarUrl ?? user.photoURL,
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
    final user = ref.read(authStateProvider).value;
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

    // Once the real Firestore user doc is available, prefill from it (overriding
    // the auth fallback seeded in initState) so an existing name/username is
    // never replaced by the email-prefix guess.
    final currentUser = ref.watch(currentUserProvider).value;
    if (!_prefilled && currentUser != null) {
      _prefill(currentUser);
    }

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

                // ── Avatar ──
                ProfilePhotoPicker(
                  photoUrl: _avatarUrl,
                  pendingPath: _pendingPhotoPath,
                  uploading: _uploadingPhoto,
                  onTap: _pickPhoto,
                  fallbackIcon: Icons.person_outline,
                ),
                const SizedBox(height: 32),

                // ── Display Name ──
                AppTextField(
                  controller: _displayNameController,
                  label: l10n.displayName,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.required(value, l10n, l10n.displayName),
                ),
                const SizedBox(height: 16),

                // ── Username ──
                AppTextField(
                  controller: _usernameController,
                  label: l10n.username,
                  prefixIcon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.username(value, l10n),
                ),
                const SizedBox(height: 16),

                // ── Bio (optional) ──
                AppTextField(
                  controller: _bioController,
                  label: l10n.bio,
                  prefixIcon: Icons.short_text,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  maxLength: AppConstants.bioMaxLength,
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

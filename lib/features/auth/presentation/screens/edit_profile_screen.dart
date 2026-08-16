import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/photo_upload_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/country_picker_field.dart';
import '../../../../core/widgets/profile_photo_picker.dart';
import '../../data/user_repository.dart';
import '../../domain/app_user.dart';
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
  bool _isLoading = false;
  bool _prefilled = false;
  String? _country;
  String? _avatarUrl;
  String? _pendingPhotoPath;
  bool _uploadingPhoto = false;

  void _prefill(AppUser user) {
    _displayNameController.text = user.displayName;
    _usernameController.text = user.username;
    _bioController.text = user.bio ?? '';
    _country = user.country;
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
  /// falling back to the existing avatar when nothing new was picked.
  Future<String?> _uploadPendingPhoto(String uid) async {
    if (_pendingPhotoPath == null) return _avatarUrl;
    setState(() => _uploadingPhoto = true);
    try {
      return await ref
          .read(photoUploadServiceProvider)
          .uploadJpeg(
            pathPrefix: 'users/$uid',
            localPath: _pendingPhotoPath!,
          );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid == null) return;

      final userRepo = ref.read(userRepositoryProvider);

      // Upload any freshly picked avatar before writing so we never persist a
      // stale URL.
      final finalAvatarUrl = await _uploadPendingPhoto(uid);

      await userRepo.updateUser(
        uid,
        UserRepository.buildProfileUpdate(
          displayName: _displayNameController.text,
          username: _usernameController.text,
          bio: _bioController.text,
          includeBio: true,
          country: _country,
          includeCountry: true,
          avatarUrl: finalAvatarUrl,
          includeAvatar: true,
        ),
      );

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

    // Prefill controllers from the already-hydrated currentUserProvider the
    // first time a user doc becomes available. Subsequent rebuilds leave
    // whatever the user has typed untouched.
    final currentUser = ref.watch(currentUserProvider).value;
    if (!_prefilled && currentUser != null) {
      _prefill(currentUser);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                ProfilePhotoPicker(
                  photoUrl: _avatarUrl,
                  pendingPath: _pendingPhotoPath,
                  uploading: _uploadingPhoto,
                  onTap: _pickPhoto,
                  fallbackIcon: Icons.person_outline,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _displayNameController,
                  label: l10n.displayName,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.required(value, l10n, l10n.displayName),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _usernameController,
                  label: l10n.username,
                  prefixIcon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.username(value, l10n),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _bioController,
                  label: l10n.bio,
                  prefixIcon: Icons.short_text,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                  maxLength: AppConstants.bioMaxLength,
                ),
                const SizedBox(height: 16),
                CountryPickerField(
                  value: _country,
                  onChanged: (v) => setState(() => _country = v),
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

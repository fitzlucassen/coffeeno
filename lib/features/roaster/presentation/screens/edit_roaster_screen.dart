import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/roaster.dart';
import '../providers/roaster_provider.dart';

class EditRoasterScreen extends ConsumerStatefulWidget {
  const EditRoasterScreen({super.key, required this.roasterId});

  final String roasterId;

  @override
  ConsumerState<EditRoasterScreen> createState() => _EditRoasterScreenState();
}

class _EditRoasterScreenState extends ConsumerState<EditRoasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _keyPeopleController = TextEditingController();
  bool _isLoading = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _keyPeopleController.dispose();
    super.dispose();
  }

  void _prefillControllers(Roaster roaster) {
    if (_prefilled) return;
    _prefilled = true;
    _nameController.text = roaster.name;
    _descriptionController.text = roaster.description ?? '';
    _urlController.text = roaster.url ?? '';
    _countryController.text = roaster.country ?? '';
    _cityController.text = roaster.city ?? '';
    _keyPeopleController.text = roaster.keyPeople ?? '';
  }

  Future<void> _save(Roaster roaster) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updated = roaster.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        keyPeople: _keyPeopleController.text.trim().isEmpty
            ? null
            : _keyPeopleController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await ref.read(roasterRepositoryProvider).updateRoaster(updated);

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
    final roasterAsync = ref.watch(roasterDetailProvider(widget.roasterId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileInfo),
      ),
      body: roasterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.error)),
        data: (roaster) {
          if (roaster == null) {
            return Center(child: Text(l10n.error));
          }

          _prefillControllers(roaster);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _nameController,
                      label: l10n.coffeeName,
                      prefixIcon: Icons.store_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.required(value, l10n.coffeeName),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      prefixIcon: Icons.notes_outlined,
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _urlController,
                      label: 'Website URL',
                      prefixIcon: Icons.link_outlined,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _countryController,
                      label: l10n.originCountry,
                      prefixIcon: Icons.public_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _cityController,
                      label: 'City',
                      prefixIcon: Icons.location_city_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _keyPeopleController,
                      label: 'Key People',
                      prefixIcon: Icons.people_outline,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _save(roaster),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: l10n.save,
                      isLoading: _isLoading,
                      onPressed: () => _save(roaster),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

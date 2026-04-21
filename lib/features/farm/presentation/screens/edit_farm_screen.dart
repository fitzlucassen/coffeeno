import 'package:coffeeno/core/widgets/app_text_field.dart';
import 'package:coffeeno/features/farm/domain/farm.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/farm_provider.dart';

class EditFarmScreen extends ConsumerStatefulWidget {
  const EditFarmScreen({super.key, required this.farmId});

  final String farmId;

  @override
  ConsumerState<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends ConsumerState<EditFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _countryController = TextEditingController();
  final _regionController = TextEditingController();
  final _farmerNameController = TextEditingController();
  final _altitudeController = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    _farmerNameController.dispose();
    _altitudeController.dispose();
    super.dispose();
  }

  void _prefillControllers(Farm farm) {
    if (_prefilled) return;
    _prefilled = true;
    _nameController.text = farm.name;
    _descriptionController.text = farm.description ?? '';
    _urlController.text = farm.url ?? '';
    _countryController.text = farm.country ?? '';
    _regionController.text = farm.region ?? '';
    _farmerNameController.text = farm.farmerName ?? '';
    _altitudeController.text = farm.altitude ?? '';
  }

  Future<void> _save(Farm farm) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      String? opt(String val) => val.trim().isEmpty ? null : val.trim();
      final updated = farm.copyWith(
        name: _nameController.text.trim(),
        description: opt(_descriptionController.text),
        url: opt(_urlController.text),
        country: opt(_countryController.text),
        region: opt(_regionController.text),
        farmerName: opt(_farmerNameController.text),
        altitude: opt(_altitudeController.text),
        updatedAt: DateTime.now(),
      );

      await ref.read(farmRepositoryProvider).updateFarm(updated);

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final farmAsync = ref.watch(farmDetailProvider(widget.farmId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileInfo),
      ),
      body: farmAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (farm) {
          if (farm == null) {
            return const Center(child: Text('Farm not found'));
          }

          _prefillControllers(farm);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _urlController,
                    label: 'Website URL',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _countryController,
                    label: l10n.originCountry,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _regionController,
                    label: l10n.originRegion,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _farmerNameController,
                    label: l10n.farmerName,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _altitudeController,
                    label: l10n.altitude,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : () => _save(farm),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

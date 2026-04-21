import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:coffeeno/core/router/app_router.dart';
import 'package:coffeeno/core/constants/app_constants.dart';
import 'package:coffeeno/core/widgets/app_button.dart';
import 'package:coffeeno/core/widgets/app_text_field.dart';
import 'package:coffeeno/core/utils/validators.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/upgrade_prompt.dart';
import '../../../scanner/domain/scan_result.dart';
import '../../../roaster/data/roaster_repository.dart';
import '../../../roaster/domain/roaster.dart';
import '../../../roaster/presentation/providers/roaster_provider.dart';
import '../../../farm/data/farm_repository.dart';
import '../../../farm/domain/farm.dart';
import '../../../farm/presentation/providers/farm_provider.dart';
import '../../data/coffee_enrichment_service.dart';
import '../../data/coffee_repository.dart';
import '../../domain/coffee.dart';
import '../providers/coffee_provider.dart';

class AddCoffeeScreen extends ConsumerStatefulWidget {
  const AddCoffeeScreen({super.key});

  @override
  ConsumerState<AddCoffeeScreen> createState() => _AddCoffeeScreenState();
}

class _AddCoffeeScreenState extends ConsumerState<AddCoffeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roasterController = TextEditingController();
  final _countryController = TextEditingController();
  final _regionController = TextEditingController();
  final _farmController = TextEditingController();
  final _farmerController = TextEditingController();
  final _altitudeController = TextEditingController();
  final _varietyController = TextEditingController();
  final _flavorNoteController = TextEditingController();

  ProcessingMethod? _processingMethod;
  RoastLevel? _roastLevel;
  DateTime? _roastDate;
  final List<String> _flavorNotes = [];
  String? _photoPath;
  bool _isSaving = false;
  bool _prefilled = false;

  void _prefillFromScan(BuildContext context) {
    if (_prefilled) return;
    _prefilled = true;

    final extra = GoRouterState.of(context).extra;
    if (extra is! ScanResult) return;

    _nameController.text = extra.name ?? '';
    _roasterController.text = extra.roaster ?? '';
    _countryController.text = extra.originCountry ?? '';
    _regionController.text = extra.originRegion ?? '';
    _farmController.text = extra.farmName ?? '';
    _farmerController.text = extra.farmerName ?? '';
    _altitudeController.text = extra.altitude ?? '';
    _varietyController.text = extra.variety ?? '';
    _flavorNotes.addAll(extra.flavorNotes);

    if (extra.processingMethod != null) {
      for (final m in ProcessingMethod.values) {
        if (m.label.toLowerCase() == extra.processingMethod!.toLowerCase()) {
          _processingMethod = m;
          break;
        }
      }
    }

    if (extra.roastLevel != null) {
      for (final r in RoastLevel.values) {
        if (r.label.toLowerCase() == extra.roastLevel!.toLowerCase()) {
          _roastLevel = r;
          break;
        }
      }
    }

    if (extra.roastDate != null) {
      _roastDate = DateTime.tryParse(extra.roastDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roasterController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    _farmController.dispose();
    _farmerController.dispose();
    _altitudeController.dispose();
    _varietyController.dispose();
    _flavorNoteController.dispose();
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
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  Future<void> _pickRoastDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _roastDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (date != null) {
      setState(() => _roastDate = date);
    }
  }

  void _addFlavorNote(String note) {
    final trimmed = note.trim();
    if (trimmed.isNotEmpty && !_flavorNotes.contains(trimmed)) {
      setState(() {
        _flavorNotes.add(trimmed);
        _flavorNoteController.clear();
      });
    }
  }

  void _removeFlavorNote(String note) {
    setState(() => _flavorNotes.remove(note));
  }

  Future<String?> _uploadPhoto(String userId) async {
    if (_photoPath == null) return null;

    final file = File(_photoPath!);
    final fileName = '${const Uuid().v4()}.jpg';
    final storageRef = FirebaseStorage.instance
        .ref('users/$userId/coffees/$fileName');
    await storageRef.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return storageRef.getDownloadURL();
  }

  Future<Coffee?> _findSimilarCoffee(String userId) async {
    final country = _countryController.text.trim();
    final farm = _farmController.text.trim();
    final region = _regionController.text.trim();
    if (country.isEmpty) return null;

    final repository = ref.read(coffeeRepositoryProvider);
    final coffees = await repository.getUserCoffees(userId).first;

    for (final c in coffees) {
      if (c.originCountry.toLowerCase() != country.toLowerCase()) continue;
      if (farm.isNotEmpty &&
          c.farmName != null &&
          c.farmName!.toLowerCase() == farm.toLowerCase() &&
          c.roaster.toLowerCase() != _roasterController.text.trim().toLowerCase()) {
        return c;
      }
      if (farm.isEmpty &&
          region.isNotEmpty &&
          c.originRegion != null &&
          c.originRegion!.toLowerCase() == region.toLowerCase() &&
          c.roaster.toLowerCase() != _roasterController.text.trim().toLowerCase()) {
        return c;
      }
    }
    return null;
  }

  void _enrichInBackground(
    CoffeeEnrichmentService enrichmentService,
    CoffeeRepository coffeeRepo,
    RoasterRepository roasterRepo,
    FarmRepository farmRepo,
    String coffeeId,
    Coffee coffee,
  ) {
    _resolveEntities(
      enrichmentService,
      coffeeRepo,
      roasterRepo,
      farmRepo,
      coffeeId,
      coffee,
    ).catchError((e) {
      debugPrint('[COFFEENO] Enrichment failed for $coffeeId: $e');
    });
  }

  Future<void> _resolveEntities(
    CoffeeEnrichmentService enrichmentService,
    CoffeeRepository coffeeRepo,
    RoasterRepository roasterRepo,
    FarmRepository farmRepo,
    String coffeeId,
    Coffee coffee,
  ) async {
    final now = DateTime.now();
    String? roasterId;
    String? farmId;
    String? roasterUrl;
    String? roasterDescription;
    String? farmUrl;
    String? farmDescription;

    // Check if roaster already exists
    final existingRoaster = await roasterRepo.findByName(coffee.roaster);
    if (existingRoaster != null) {
      roasterId = existingRoaster.id;
      roasterUrl = existingRoaster.url;
      roasterDescription = existingRoaster.description;
      debugPrint('[COFFEENO] Reusing roaster: ${existingRoaster.name}');
    }

    // Check if farm already exists
    Farm? existingFarm;
    if (coffee.farmName != null && coffee.farmName!.isNotEmpty) {
      existingFarm = await farmRepo.findByName(
        coffee.farmName!,
        country: coffee.originCountry,
      );
      if (existingFarm != null) {
        farmId = existingFarm.id;
        farmUrl = existingFarm.url;
        farmDescription = existingFarm.description;
        debugPrint('[COFFEENO] Reusing farm: ${existingFarm.name}');
      }
    }

    // Call Gemini only if we need info for either entity
    final needsRoasterInfo = existingRoaster == null;
    final needsFarmInfo =
        coffee.farmName != null && coffee.farmName!.isNotEmpty && existingFarm == null;

    if ((needsRoasterInfo || needsFarmInfo) && enrichmentService.isAvailable) {
      final result = await enrichmentService.lookupInfo(
        roaster: coffee.roaster,
        farmName: coffee.farmName,
        originCountry: coffee.originCountry,
        originRegion: coffee.originRegion,
      );
      debugPrint('[COFFEENO] Enrichment result for $coffeeId: '
          'roasterUrl=${result.roasterUrl}, farmUrl=${result.farmUrl}');

      if (needsRoasterInfo) {
        roasterUrl = result.roasterUrl;
        roasterDescription = result.roasterDescription;
        final roaster = Roaster(
          id: '',
          name: coffee.roaster,
          description: result.roasterDescription,
          url: result.roasterUrl,
          country: result.roasterCountry,
          city: result.roasterCity,
          keyPeople: result.roasterKeyPeople,
          source: 'ai',
          createdAt: now,
          updatedAt: now,
        );
        roasterId = await roasterRepo.addRoaster(roaster);
        debugPrint('[COFFEENO] Created roaster $roasterId');
      }

      if (needsFarmInfo) {
        farmUrl = result.farmUrl;
        farmDescription = result.farmDescription;
        final farm = Farm(
          id: '',
          name: coffee.farmName!,
          description: result.farmDescription,
          url: result.farmUrl,
          country: coffee.originCountry,
          region: result.farmRegion ?? coffee.originRegion,
          farmerName: result.farmFarmerName ?? coffee.farmerName,
          altitude: result.farmAltitude ?? coffee.altitude,
          source: 'ai',
          createdAt: now,
          updatedAt: now,
        );
        farmId = await farmRepo.addFarm(farm);
        debugPrint('[COFFEENO] Created farm $farmId');
      }
    }

    // Update the coffee with entity references + inline fields
    final saved = await coffeeRepo.getCoffee(coffeeId);
    if (saved == null) return;
    await coffeeRepo.updateCoffee(saved.copyWith(
      roasterId: roasterId,
      farmId: farmId,
      roasterUrl: roasterUrl,
      roasterDescription: roasterDescription,
      farmUrl: farmUrl,
      farmDescription: farmDescription,
    ));
    debugPrint('[COFFEENO] Enrichment saved for $coffeeId');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isPremium = ref.read(isPremiumProvider);

    if (!isPremium) {
      final subRepo = ref.read(subscriptionRepositoryProvider);
      final coffeeCount = await subRepo.getUserCoffeeCount();
      if (coffeeCount >= AppConstants.freeTierMaxCoffees && mounted) {
        final l10n = AppLocalizations.of(context);
        showUpgradePrompt(
            context, l10n.coffeeLimitReached(AppConstants.freeTierMaxCoffees));
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final repository = ref.read(coffeeRepositoryProvider);

      final similar = await _findSimilarCoffee(userId);
      if (similar != null && mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.similarCoffeeAlert(similar.roaster)),
            action: SnackBarAction(
              label: l10n.viewSimilar,
              onPressed: () => context.push('/coffee/${similar.id}'),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      final photoUrl = isPremium ? await _uploadPhoto(userId) : null;

      final coffee = Coffee(
        id: '',
        uid: userId,
        photoUrl: photoUrl,
        roaster: _roasterController.text.trim(),
        name: _nameController.text.trim(),
        originCountry: _countryController.text.trim(),
        originRegion: _regionController.text.trim().isNotEmpty
            ? _regionController.text.trim()
            : null,
        farmName: _farmController.text.trim().isNotEmpty
            ? _farmController.text.trim()
            : null,
        farmerName: _farmerController.text.trim().isNotEmpty
            ? _farmerController.text.trim()
            : null,
        altitude: _altitudeController.text.trim().isNotEmpty
            ? _altitudeController.text.trim()
            : null,
        variety: _varietyController.text.trim().isNotEmpty
            ? _varietyController.text.trim()
            : null,
        processingMethod: _processingMethod?.label,
        roastDate: _roastDate,
        roastLevel: _roastLevel?.label,
        flavorNotes: _flavorNotes,
        createdAt: DateTime.now(),
      );

      final coffeeId = await repository.addCoffee(coffee);

      if (isPremium) {
        final enrichmentService = ref.read(coffeeEnrichmentProvider);
        final roasterRepo = ref.read(roasterRepositoryProvider);
        final farmRepo = ref.read(farmRepositoryProvider);
        _enrichInBackground(
            enrichmentService, repository, roasterRepo, farmRepo, coffeeId, coffee);
      }

      if (mounted) context.go(AppRoutes.library);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _prefillFromScan(context);

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCoffee),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Photo picker
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: _photoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_photoPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _PhotoPlaceholder(
                            colorScheme: colorScheme,
                          ),
                        ),
                      )
                    : _PhotoPlaceholder(colorScheme: colorScheme),
              ),
            ),
            const SizedBox(height: 24),

            // Required fields
            AppTextField(
              controller: _nameController,
              label: l10n.coffeeName,
              prefixIcon: Icons.coffee_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n.coffeeName),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _roasterController,
              label: l10n.roaster,
              prefixIcon: Icons.store_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n.roaster),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _countryController,
              label: l10n.originCountry,
              prefixIcon: Icons.public_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n.originCountry),
            ),
            const SizedBox(height: 16),

            // Optional fields
            AppTextField(
              controller: _regionController,
              label: l10n.originRegion,
              prefixIcon: Icons.place_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _farmController,
              label: l10n.farmName,
              prefixIcon: Icons.agriculture_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _farmerController,
              label: l10n.farmerName,
              prefixIcon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _altitudeController,
              label: l10n.altitude,
              prefixIcon: Icons.terrain_rounded,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _varietyController,
              label: l10n.variety,
              prefixIcon: Icons.eco_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Processing method dropdown
            DropdownButtonFormField<ProcessingMethod>(
              initialValue: _processingMethod,
              decoration: InputDecoration(
                labelText: l10n.processingMethod,
                prefixIcon: const Icon(Icons.water_drop_rounded),
              ),
              items: ProcessingMethod.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _processingMethod = v),
            ),
            const SizedBox(height: 16),

            // Roast level dropdown
            DropdownButtonFormField<RoastLevel>(
              initialValue: _roastLevel,
              decoration: InputDecoration(
                labelText: l10n.roastLevel,
                prefixIcon: const Icon(Icons.local_fire_department_rounded),
              ),
              items: RoastLevel.values
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _roastLevel = v),
            ),
            const SizedBox(height: 16),

            // Roast date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(l10n.roastDate),
              subtitle: _roastDate != null
                  ? Text(
                      '${_roastDate!.year}-${_roastDate!.month.toString().padLeft(2, '0')}-${_roastDate!.day.toString().padLeft(2, '0')}')
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.edit_calendar_rounded),
                onPressed: _pickRoastDate,
              ),
              onTap: _pickRoastDate,
            ),
            const SizedBox(height: 16),

            // Flavor notes chip input
            Text(l10n.flavorNotes, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _flavorNoteController,
                    hint: 'e.g. Chocolate, Citrus...',
                    textInputAction: TextInputAction.done,
                    onSubmitted: _addFlavorNote,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () =>
                      _addFlavorNote(_flavorNoteController.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_flavorNotes.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _flavorNotes
                    .map((note) => Chip(
                          label: Text(note),
                          onDeleted: () => _removeFlavorNote(note),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 32),

            // Save button
            AppButton(
              label: l10n.save,
              icon: Icons.check_rounded,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_a_photo_rounded,
            size: 40,
            color: colorScheme.onSecondaryContainer.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photo',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

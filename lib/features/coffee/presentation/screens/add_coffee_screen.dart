import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:coffeeno/core/router/app_router.dart';
import 'package:coffeeno/core/constants/app_constants.dart';
import 'package:coffeeno/core/services/photo_upload_service.dart';
import 'package:coffeeno/core/utils/enum_labels.dart';
import 'package:coffeeno/core/widgets/app_button.dart';
import 'package:coffeeno/core/widgets/app_text_field.dart';
import 'package:coffeeno/core/utils/validators.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/upgrade_prompt.dart';
import '../../../scanner/domain/scan_result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gamification/domain/gamification.dart';
import '../../domain/coffee.dart';
import '../providers/coffee_provider.dart';
import '../../data/freshness_notification_service.dart';
import '../providers/freshness_notification_provider.dart';

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
  final _priceController = TextEditingController();
  final _lotController = TextEditingController();
  final _harvestYearController = TextEditingController();

  ProcessingMethod? _processingMethod;
  RoastLevel? _roastLevel;
  DateTime? _roastDate;
  final List<String> _flavorNotes = [];
  String? _photoPath;
  bool _isSaving = false;
  bool _prefilled = false;
  bool _rebuyDismissed = false;

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

    // Scanner-extracted values arrive as English labels; existing coffees may
    // arrive as stable keys. `fromStored` handles both.
    if (extra.processingMethod != null) {
      _processingMethod = ProcessingMethod.fromStored(extra.processingMethod);
    }
    if (extra.roastLevel != null) {
      _roastLevel = RoastLevel.fromStored(extra.roastLevel);
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
    _priceController.dispose();
    _lotController.dispose();
    _harvestYearController.dispose();
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
    return ref
        .read(photoUploadServiceProvider)
        .uploadJpeg(
          pathPrefix: 'users/$userId/coffees',
          localPath: _photoPath!,
        );
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
          c.roaster.toLowerCase() !=
              _roasterController.text.trim().toLowerCase()) {
        return c;
      }
      if (farm.isEmpty &&
          region.isNotEmpty &&
          c.originRegion != null &&
          c.originRegion!.toLowerCase() == region.toLowerCase() &&
          c.roaster.toLowerCase() !=
              _roasterController.text.trim().toLowerCase()) {
        return c;
      }
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isPremium = ref.read(isPremiumProvider);
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    // Captured once up front so it can be used after later awaits without
    // touching BuildContext across async gaps.
    final l10n = AppLocalizations.of(context);

    if (!isPremium) {
      final coffeeCount = await ref
          .read(coffeeRepositoryProvider)
          .countForUser(userId);
      if (coffeeCount >= AppConstants.freeTierMaxCoffees && mounted) {
        showUpgradePrompt(
          context,
          l10n.coffeeLimitReached(AppConstants.freeTierMaxCoffees),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(coffeeRepositoryProvider);

      final similar = await _findSimilarCoffee(userId);
      if (similar != null && mounted) {
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
        processingMethod: _processingMethod?.key,
        roastDate: _roastDate,
        roastLevel: _roastLevel?.key,
        flavorNotes: _flavorNotes,
        price: _priceController.text.trim().isNotEmpty
            ? double.tryParse(_priceController.text.trim())
            : null,
        lot: _lotController.text.trim().isNotEmpty
            ? _lotController.text.trim()
            : null,
        harvestYear: _harvestYearController.text.trim().isNotEmpty
            ? int.tryParse(_harvestYearController.text.trim())
            : null,
        createdAt: DateTime.now(),
      );

      final coffeeId = await repository.addCoffee(coffee);

      // Award gamification points for adding a coffee (fire-and-forget; a
      // points write must never block or fail the core save).
      ref
          .read(userRepositoryProvider)
          .awardPoints(userId, GamificationPoints.addCoffee);

      // Schedule a freshness reminder notification for this coffee.
      final savedCoffee = coffee.copyWith(id: coffeeId);
      final notificationTitle = l10n.freshnessNotificationTitle;
      final notificationService = ref.read(freshnessNotificationProvider);
      notificationService.init().then((_) {
        notificationService
            .scheduleForCoffee(
              savedCoffee,
              title: notificationTitle,
              body: (c) => freshnessNotificationBody(l10n, c),
            )
            .catchError((e) {
              debugPrint(
                '[COFFEENO] Freshness notification scheduling failed: $e',
              );
            });
      });

      if (isPremium) {
        ref
            .read(coffeeEnrichmentOrchestratorProvider)
            .resolveInBackground(coffeeId, coffee);
      }

      if (mounted) context.go(AppRoutes.library);
    } catch (e) {
      debugPrint('[COFFEENO] Failed to save coffee: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Re-buy banner. Watches the canonical-match provider for the currently
  /// entered roaster + name + country; renders nothing until a match is found
  /// in the user's own library. Offers opening the existing coffee or
  /// dismissing to add a fresh entry anyway.
  Widget _buildRebuyBanner(AppLocalizations l10n) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final roaster = _roasterController.text.trim();
    final name = _nameController.text.trim();
    final country = _countryController.text.trim();

    // Need the identity fields populated before a lookup is meaningful.
    if (userId.isEmpty || roaster.isEmpty || name.isEmpty || country.isEmpty) {
      return const SizedBox.shrink();
    }

    final match = ref.watch(
      canonicalMatchProvider((
        userId: userId,
        roaster: roaster,
        name: name,
        originCountry: country,
      )),
    );

    final coffee = match.asData?.value;
    if (coffee == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: theme.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.alreadyInLibrary,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${coffee.name} · ${coffee.roaster}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    onPressed: () => context.go('/coffee/${coffee.id}'),
                    child: Text(l10n.openExisting),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _rebuyDismissed = true),
                    child: Text(l10n.addAgain),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _prefillFromScan(context);

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCoffee)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Re-buy banner: shown when this coffee already exists in the
            // user's library (same roaster + name + origin). Lets the user
            // open the existing entry instead of creating a duplicate.
            if (!_rebuyDismissed) _buildRebuyBanner(l10n),

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
                          errorBuilder: (_, _, _) =>
                              _PhotoPlaceholder(colorScheme: colorScheme),
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
              validator: (v) => Validators.required(v, l10n, l10n.coffeeName),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _roasterController,
              label: l10n.roaster,
              prefixIcon: Icons.store_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n, l10n.roaster),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _countryController,
              label: l10n.originCountry,
              prefixIcon: Icons.public_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  Validators.required(v, l10n, l10n.originCountry),
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
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.displayLabel(l10n)),
                    ),
                  )
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
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.displayLabel(l10n)),
                    ),
                  )
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
                      '${_roastDate!.year}-${_roastDate!.month.toString().padLeft(2, '0')}-${_roastDate!.day.toString().padLeft(2, '0')}',
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.edit_calendar_rounded),
                onPressed: _pickRoastDate,
              ),
              onTap: _pickRoastDate,
            ),
            const SizedBox(height: 16),

            // Price
            AppTextField(
              controller: _priceController,
              label: l10n.price,
              prefixIcon: Icons.euro_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text('€'),
              ),
            ),
            const SizedBox(height: 16),

            // Lot
            AppTextField(
              controller: _lotController,
              label: l10n.lot,
              prefixIcon: Icons.tag_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Harvest Year
            AppTextField(
              controller: _harvestYearController,
              label: l10n.harvestYear,
              prefixIcon: Icons.grass_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
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
                  onPressed: () => _addFlavorNote(_flavorNoteController.text),
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
                    .map(
                      (note) => Chip(
                        label: Text(note),
                        onDeleted: () => _removeFlavorNote(note),
                      ),
                    )
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
          Text('Add photo', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

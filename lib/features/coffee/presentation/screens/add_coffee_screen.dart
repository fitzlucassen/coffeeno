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
import '../../../scanner/domain/scan_result.dart';
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final repository = ref.read(coffeeRepositoryProvider);

      String? photoUrl;
      if (_photoPath != null) {
        try {
          final file = File(_photoPath!);
          debugPrint('[COFFEENO] Photo path: $_photoPath');
          debugPrint('[COFFEENO] File exists: ${file.existsSync()}, size: ${file.lengthSync()}');
          final fileName = '${const Uuid().v4()}.jpg';
          final storageRef = FirebaseStorage.instance
              .ref('users/$userId/coffees/$fileName');
          final task = storageRef.putFile(
            file,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          task.snapshotEvents.listen((snapshot) {
            debugPrint('[COFFEENO] Upload state: ${snapshot.state}, '
                '${snapshot.bytesTransferred}/${snapshot.totalBytes}');
          });
          await task;
          photoUrl = await storageRef.getDownloadURL();
          debugPrint('[COFFEENO] Photo uploaded: $photoUrl');
        } catch (e, stack) {
          debugPrint('[COFFEENO] Photo upload failed: $e');
          debugPrint('[COFFEENO] Stack: $stack');
        }
      }

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

      print('[COFFEENO] Saving coffee: ${coffee.name} by ${coffee.roaster}, uid=$userId');
      final docId = await repository.addCoffee(coffee);
      print('[COFFEENO] Coffee saved with id: $docId');

      if (mounted) context.go(AppRoutes.library);
    } catch (e, stack) {
      print('[COFFEENO] Save coffee FAILED: $e');
      print('[COFFEENO] Stack: $stack');
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

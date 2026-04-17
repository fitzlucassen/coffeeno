import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/scan_result.dart';
import '../widgets/scan_field_tile.dart';

/// Screen that displays the AI-extracted coffee data and lets the user review
/// and edit each field before saving to the library.
class ScanReviewScreen extends ConsumerStatefulWidget {
  const ScanReviewScreen({super.key});

  @override
  ConsumerState<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends ConsumerState<ScanReviewScreen> {
  late ScanResult _result;
  bool _initialized = false;

  void _ensureInitialized(BuildContext context) {
    if (_initialized) return;
    final extra = GoRouterState.of(context).extra;
    if (extra is ScanResult) {
      _result = extra;
    } else {
      _result = const ScanResult(rawOcrText: '');
    }
    _initialized = true;
  }

  void _updateField(String field, String value) {
    setState(() {
      final v = value.trim().isEmpty ? null : value.trim();
      switch (field) {
        case 'roaster':
          _result = _result.copyWith(roaster: v);
        case 'name':
          _result = _result.copyWith(name: v);
        case 'originCountry':
          _result = _result.copyWith(originCountry: v);
        case 'originRegion':
          _result = _result.copyWith(originRegion: v);
        case 'farmName':
          _result = _result.copyWith(farmName: v);
        case 'farmerName':
          _result = _result.copyWith(farmerName: v);
        case 'altitude':
          _result = _result.copyWith(altitude: v);
        case 'variety':
          _result = _result.copyWith(variety: v);
        case 'processingMethod':
          _result = _result.copyWith(processingMethod: v);
        case 'roastDate':
          _result = _result.copyWith(roastDate: v);
        case 'roastLevel':
          _result = _result.copyWith(roastLevel: v);
        case 'flavorNotes':
          final notes = value
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          _result = _result.copyWith(flavorNotes: notes);
        case 'additionalInfo':
          _result = _result.copyWith(additionalInfo: v);
      }
    });
  }

  Future<void> _save() async {
    // Navigate to the add-coffee screen passing the scan result as extra data
    // so it can be used to pre-fill the coffee form.
    context.go(AppRoutes.addCoffee, extra: _result);
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized(context);

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.scanReview),
      ),
      body: Column(
        children: [
          // ── Subtitle ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.scanReviewSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Field list ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                ScanFieldTile(
                  label: l10n.roaster,
                  value: _result.roaster,
                  icon: Icons.store_rounded,
                  onChanged: (v) => _updateField('roaster', v),
                ),
                ScanFieldTile(
                  label: l10n.coffeeName,
                  value: _result.name,
                  icon: Icons.coffee_rounded,
                  onChanged: (v) => _updateField('name', v),
                ),
                const Divider(height: 24),
                ScanFieldTile(
                  label: l10n.originCountry,
                  value: _result.originCountry,
                  icon: Icons.public_rounded,
                  onChanged: (v) => _updateField('originCountry', v),
                ),
                ScanFieldTile(
                  label: l10n.originRegion,
                  value: _result.originRegion,
                  icon: Icons.landscape_rounded,
                  onChanged: (v) => _updateField('originRegion', v),
                ),
                ScanFieldTile(
                  label: l10n.farmName,
                  value: _result.farmName,
                  icon: Icons.agriculture_rounded,
                  onChanged: (v) => _updateField('farmName', v),
                ),
                ScanFieldTile(
                  label: l10n.farmerName,
                  value: _result.farmerName,
                  icon: Icons.person_rounded,
                  onChanged: (v) => _updateField('farmerName', v),
                ),
                const Divider(height: 24),
                ScanFieldTile(
                  label: l10n.altitude,
                  value: _result.altitude,
                  icon: Icons.terrain_rounded,
                  onChanged: (v) => _updateField('altitude', v),
                ),
                ScanFieldTile(
                  label: l10n.variety,
                  value: _result.variety,
                  icon: Icons.eco_rounded,
                  onChanged: (v) => _updateField('variety', v),
                ),
                ScanFieldTile(
                  label: l10n.processingMethod,
                  value: _result.processingMethod,
                  icon: Icons.water_drop_rounded,
                  onChanged: (v) => _updateField('processingMethod', v),
                ),
                const Divider(height: 24),
                ScanFieldTile(
                  label: l10n.roastDate,
                  value: _result.roastDate,
                  icon: Icons.calendar_today_rounded,
                  onChanged: (v) => _updateField('roastDate', v),
                ),
                ScanFieldTile(
                  label: l10n.roastLevel,
                  value: _result.roastLevel,
                  icon: Icons.local_fire_department_rounded,
                  onChanged: (v) => _updateField('roastLevel', v),
                ),
                ScanFieldTile(
                  label: l10n.flavorNotes,
                  value: _result.flavorNotes.isNotEmpty
                      ? _result.flavorNotes.join(', ')
                      : null,
                  icon: Icons.restaurant_rounded,
                  onChanged: (v) => _updateField('flavorNotes', v),
                ),
                // Additional info is not in l10n, so we use a string literal
                // matching the pattern used elsewhere in the app.
                ScanFieldTile(
                  label: 'Additional Info',
                  value: _result.additionalInfo,
                  icon: Icons.info_outline_rounded,
                  onChanged: (v) => _updateField('additionalInfo', v),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Save button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SafeArea(
              child: AppButton(
                label: l10n.save,
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

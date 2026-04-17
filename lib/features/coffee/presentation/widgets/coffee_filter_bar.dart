import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/constants/app_constants.dart';

enum CoffeeSortOption { rating, dateAdded, name }

class CoffeeFilterBar extends StatelessWidget {
  const CoffeeFilterBar({
    super.key,
    this.selectedCountry,
    this.selectedRoastLevel,
    this.selectedProcessingMethod,
    this.selectedSort = CoffeeSortOption.dateAdded,
    this.onCountryChanged,
    this.onRoastLevelChanged,
    this.onProcessingMethodChanged,
    this.onSortChanged,
    this.availableCountries = const [],
  });

  final String? selectedCountry;
  final RoastLevel? selectedRoastLevel;
  final ProcessingMethod? selectedProcessingMethod;
  final CoffeeSortOption selectedSort;
  final ValueChanged<String?>? onCountryChanged;
  final ValueChanged<RoastLevel?>? onRoastLevelChanged;
  final ValueChanged<ProcessingMethod?>? onProcessingMethodChanged;
  final ValueChanged<CoffeeSortOption>? onSortChanged;
  final List<String> availableCountries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          // Origin country filter
          if (availableCountries.isNotEmpty)
            _FilterChip(
              label: selectedCountry ?? l10n.originCountry,
              selected: selectedCountry != null,
              onTap: () => _showCountryPicker(context),
              onDeleted:
                  selectedCountry != null ? () => onCountryChanged?.call(null) : null,
            ),
          const SizedBox(width: 8),

          // Roast level filter
          _FilterChip(
            label: selectedRoastLevel?.label ?? l10n.roastLevel,
            selected: selectedRoastLevel != null,
            onTap: () => _showRoastLevelPicker(context),
            onDeleted: selectedRoastLevel != null
                ? () => onRoastLevelChanged?.call(null)
                : null,
          ),
          const SizedBox(width: 8),

          // Processing method filter
          _FilterChip(
            label: selectedProcessingMethod?.label ?? l10n.processingMethod,
            selected: selectedProcessingMethod != null,
            onTap: () => _showProcessingMethodPicker(context),
            onDeleted: selectedProcessingMethod != null
                ? () => onProcessingMethodChanged?.call(null)
                : null,
          ),
          const SizedBox(width: 16),

          // Sort divider
          VerticalDivider(
            width: 1,
            indent: 8,
            endIndent: 8,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(width: 16),

          // Sort options
          for (final option in CoffeeSortOption.values) ...[
            ChoiceChip(
              label: Text(_sortLabel(option, l10n)),
              selected: selectedSort == option,
              onSelected: (_) => onSortChanged?.call(option),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  String _sortLabel(CoffeeSortOption option, AppLocalizations l10n) {
    switch (option) {
      case CoffeeSortOption.rating:
        return l10n.topRated;
      case CoffeeSortOption.dateAdded:
        return 'Newest';
      case CoffeeSortOption.name:
        return 'A-Z';
    }
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: availableCountries.map((country) {
          return ListTile(
            title: Text(country),
            trailing:
                country == selectedCountry ? const Icon(Icons.check) : null,
            onTap: () {
              Navigator.of(ctx).pop();
              onCountryChanged?.call(country);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showRoastLevelPicker(BuildContext context) {
    showModalBottomSheet<RoastLevel>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: RoastLevel.values.map((level) {
          return ListTile(
            title: Text(level.label),
            trailing:
                level == selectedRoastLevel ? const Icon(Icons.check) : null,
            onTap: () {
              Navigator.of(ctx).pop();
              onRoastLevelChanged?.call(level);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showProcessingMethodPicker(BuildContext context) {
    showModalBottomSheet<ProcessingMethod>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: ProcessingMethod.values.map((method) {
          return ListTile(
            title: Text(method.label),
            trailing: method == selectedProcessingMethod
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.of(ctx).pop();
              onProcessingMethodChanged?.call(method);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onDeleted,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      selected: selected,
      onPressed: onTap,
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
    );
  }
}

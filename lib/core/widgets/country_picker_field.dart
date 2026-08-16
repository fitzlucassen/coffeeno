import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../constants/countries.dart';

/// A read-only form field that opens a searchable country list in a bottom
/// sheet, replacing free-text country entry so stored values stay canonical.
class CountryPickerField extends StatelessWidget {
  const CountryPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  /// The currently selected country name, or null/empty when none is set.
  final String? value;

  /// Called with the newly selected country, or null when the selection is
  /// cleared.
  final ValueChanged<String?> onChanged;

  final String? label;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CountryPickerSheet(selected: value),
    );
    // A returned empty string means "clear"; null means the sheet was
    // dismissed without a choice, in which case we leave the value untouched.
    if (selected != null) {
      onChanged(selected.isEmpty ? null : selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label ?? l10n.country,
          prefixIcon: const Icon(Icons.public),
          suffixIcon: hasValue
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          hasValue ? value! : '',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({this.selected});

  final String? selected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filtered = _query.isEmpty
        ? kCountries
        : kCountries
              .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
              .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '${l10n.search}...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final country = filtered[index];
                  final isSelected = country == widget.selected;
                  return ListTile(
                    title: Text(country),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

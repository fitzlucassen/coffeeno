import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

/// SCA-inspired flavor wheel categories with sub-flavors.
const Map<String, List<String>> _flavorCategories = {
  'Fruity': ['Berry', 'Citrus', 'Stone Fruit', 'Tropical', 'Dried Fruit'],
  'Floral': ['Jasmine', 'Rose', 'Lavender', 'Hibiscus'],
  'Sweet': ['Caramel', 'Honey', 'Vanilla', 'Brown Sugar', 'Maple'],
  'Nutty': ['Almond', 'Hazelnut', 'Walnut', 'Peanut'],
  'Chocolatey': ['Dark Chocolate', 'Milk Chocolate', 'Cocoa', 'Cacao Nib'],
  'Spicy': ['Cinnamon', 'Clove', 'Black Pepper', 'Cardamom'],
  'Roasted': ['Tobacco', 'Smoky', 'Toasty', 'Malt'],
  'Vegetal': ['Herbal', 'Grassy', 'Earthy', 'Mushroom'],
  'Sour': ['Lemon', 'Green Apple', 'Vinegar', 'Wine'],
  'Other': [],
};

/// A two-step flavor picker: tap a category to reveal sub-flavors, then tap
/// sub-flavors to select them. The "Other" category allows free-text entry.
class FlavorSelector extends StatefulWidget {
  const FlavorSelector({
    super.key,
    required this.selectedFlavors,
    required this.onChanged,
  });

  final List<String> selectedFlavors;
  final ValueChanged<List<String>> onChanged;

  @override
  State<FlavorSelector> createState() => _FlavorSelectorState();
}

class _FlavorSelectorState extends State<FlavorSelector> {
  String? _expandedCategory;
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _toggleFlavor(String flavor) {
    final updated = List<String>.from(widget.selectedFlavors);
    if (updated.contains(flavor)) {
      updated.remove(flavor);
    } else {
      updated.add(flavor);
    }
    widget.onChanged(updated);
  }

  void _addCustomFlavor() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    if (!widget.selectedFlavors.contains(text)) {
      widget.onChanged([...widget.selectedFlavors, text]);
    }
    _customController.clear();
  }

  /// Returns true if any sub-flavor of [category] is currently selected.
  bool _categoryHasSelection(String category) {
    final subs = _flavorCategories[category] ?? [];
    return subs.any(widget.selectedFlavors.contains);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.flavorNotes, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.selectFlavors,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Category chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _flavorCategories.keys.map((category) {
            final isExpanded = _expandedCategory == category;
            final hasSelection = _categoryHasSelection(category);

            return FilterChip(
              label: Text(category),
              selected: isExpanded || hasSelection,
              onSelected: (_) {
                setState(() {
                  _expandedCategory = isExpanded ? null : category;
                });
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),

        // Sub-flavor chips (when a category is expanded)
        if (_expandedCategory != null) ...[
          const SizedBox(height: 12),
          if (_expandedCategory == 'Other')
            _buildCustomInput(theme, colorScheme)
          else
            _buildSubFlavors(
              _flavorCategories[_expandedCategory!]!,
              colorScheme,
            ),
        ],

        // Show selected flavors summary
        if (widget.selectedFlavors.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedFlavors.map((flavor) {
              return Chip(
                label: Text(
                  flavor,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: colorScheme.secondaryContainer,
                deleteIcon: Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                ),
                onDeleted: () => _toggleFlavor(flavor),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubFlavors(List<String> subFlavors, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subFlavors.map((flavor) {
        final isSelected = widget.selectedFlavors.contains(flavor);
        return FilterChip(
          label: Text(flavor),
          selected: isSelected,
          onSelected: (_) => _toggleFlavor(flavor),
          selectedColor: colorScheme.tertiaryContainer,
          checkmarkColor: colorScheme.onTertiaryContainer,
        );
      }).toList(),
    );
  }

  Widget _buildCustomInput(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _customController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Add a flavor...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addCustomFlavor(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _addCustomFlavor,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../../domain/flavor_wheel_data.dart';
import 'flavor_wheel_painter.dart';

/// SCA flavor-wheel picker: a tappable wheel that expands a panel of grouped
/// sub-flavors, plus a free-text custom-flavor input and a selected-chips
/// summary. The taxonomy lives in [kFlavorCategories]; the wheel rendering in
/// [FlavorWheel].
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

class _FlavorSelectorState extends State<FlavorSelector>
    with SingleTickerProviderStateMixin {
  int? _expandedIndex;
  final _customController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleFlavor(String flavor) {
    HapticFeedback.selectionClick();
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

  void _tapCategory(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
        _animController.reverse();
      } else {
        _expandedIndex = index;
        _animController.forward(from: 0);
      }
    });
  }

  int _categorySelectionCount(int index) {
    final allFlavors = kFlavorCategories[index].allFlavors;
    return allFlavors.where(widget.selectedFlavors.contains).length;
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
        const SizedBox(height: 16),

        // Flavor wheel
        SizedBox(
          height: 300,
          child: FlavorWheel(
            expandedIndex: _expandedIndex,
            onCategoryTap: _tapCategory,
            selectionCounts: List.generate(
              kFlavorCategories.length,
              _categorySelectionCount,
            ),
          ),
        ),

        // Sub-flavors panel
        if (_expandedIndex != null)
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) => SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: child,
            ),
            child: _SubFlavorPanel(
              category: kFlavorCategories[_expandedIndex!],
              selectedFlavors: widget.selectedFlavors,
              onToggle: _toggleFlavor,
            ),
          ),

        const SizedBox(height: 12),

        // Custom flavor
        _CustomFlavorInput(
          controller: _customController,
          hint: l10n.customFlavorHint,
          onAdd: _addCustomFlavor,
        ),

        // Selected summary
        if (widget.selectedFlavors.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedFlavors.map((flavor) {
              final categoryColor = flavorCategoryColor(flavor) ?? Colors.grey;
              return Chip(
                avatar: CircleAvatar(backgroundColor: categoryColor, radius: 6),
                label: Text(flavor, style: theme.textTheme.bodySmall),
                deleteIcon: const Icon(Icons.close, size: 16),
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
}

/// Panel showing grouped sub-flavors for the tapped category.
class _SubFlavorPanel extends StatelessWidget {
  const _SubFlavorPanel({
    required this.category,
    required this.selectedFlavors,
    required this.onToggle,
  });

  final FlavorCategory category;
  final List<String> selectedFlavors;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sub-categories with their flavors
          ...category.subCategories.map(
            (sub) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.subCategories.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        sub.name,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: category.color.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sub.flavors.map((flavor) {
                      final isSelected = selectedFlavors.contains(flavor);
                      return GestureDetector(
                        onTap: () => onToggle(flavor),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color
                                : category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? category.color
                                  : category.color.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            flavor,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? Colors.white : category.color,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomFlavorInput extends StatelessWidget {
  const _CustomFlavorInput({
    required this.controller,
    required this.hint,
    required this.onAdd,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              prefixIcon: const Icon(Icons.add_circle_outline, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

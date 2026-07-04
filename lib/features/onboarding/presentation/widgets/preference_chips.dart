import 'package:flutter/material.dart';

/// A selectable option with a stable persisted [value] and a localized
/// [display] string shown on the chip.
class PreferenceOption {
  const PreferenceOption({required this.value, required this.display});

  final String value;
  final String display;
}

/// A labelled wrap of multi-select [FilterChip]s used to capture a set of
/// preferences (brew methods, roast levels, flavors). Stateless: the parent
/// owns the selected set (of stable values) and is notified via [onToggle].
class PreferenceChips extends StatelessWidget {
  const PreferenceChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final String label;

  /// The full list of selectable options (value + localized display).
  final List<PreferenceOption> options;

  /// The currently-selected option values.
  final Set<String> selected;

  /// Called with the toggled option value whenever a chip is tapped.
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option.display),
                selected: selected.contains(option.value),
                onSelected: (_) => onToggle(option.value),
              ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// A labelled wrap of multi-select [FilterChip]s used to capture a set of
/// preferences (brew methods, roast levels, flavors). Stateless: the parent
/// owns the selected set and is notified via [onToggle].
class PreferenceChips extends StatelessWidget {
  const PreferenceChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final String label;

  /// The full list of selectable option labels.
  final List<String> options;

  /// The currently-selected option labels.
  final Set<String> selected;

  /// Called with the toggled option label whenever a chip is tapped.
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
                label: Text(option),
                selected: selected.contains(option),
                onSelected: (_) => onToggle(option),
              ),
          ],
        ),
      ],
    );
  }
}

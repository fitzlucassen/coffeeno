import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

/// SCA-inspired flavor wheel categories with sub-flavors and colors.
class _FlavorCategory {
  const _FlavorCategory(this.name, this.color, this.subFlavors);
  final String name;
  final Color color;
  final List<String> subFlavors;
}

const List<_FlavorCategory> _categories = [
  _FlavorCategory('Fruity', Color(0xFFE53935), [
    'Berry', 'Citrus', 'Stone Fruit', 'Tropical', 'Dried Fruit'
  ]),
  _FlavorCategory('Floral', Color(0xFFAB47BC), [
    'Jasmine', 'Rose', 'Lavender', 'Hibiscus'
  ]),
  _FlavorCategory('Sweet', Color(0xFFFF8F00), [
    'Caramel', 'Honey', 'Vanilla', 'Brown Sugar', 'Maple'
  ]),
  _FlavorCategory('Nutty', Color(0xFF8D6E63), [
    'Almond', 'Hazelnut', 'Walnut', 'Peanut'
  ]),
  _FlavorCategory('Chocolatey', Color(0xFF5D4037), [
    'Dark Chocolate', 'Milk Chocolate', 'Cocoa', 'Cacao Nib'
  ]),
  _FlavorCategory('Spicy', Color(0xFFFF5722), [
    'Cinnamon', 'Clove', 'Black Pepper', 'Cardamom'
  ]),
  _FlavorCategory('Roasted', Color(0xFF795548), [
    'Tobacco', 'Smoky', 'Toasty', 'Malt'
  ]),
  _FlavorCategory('Vegetal', Color(0xFF43A047), [
    'Herbal', 'Grassy', 'Earthy', 'Mushroom'
  ]),
  _FlavorCategory('Sour', Color(0xFFFDD835), [
    'Lemon', 'Green Apple', 'Vinegar', 'Wine'
  ]),
];

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
    final subs = _categories[index].subFlavors;
    return subs.where(widget.selectedFlavors.contains).length;
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

        // Flavor wheel visualization
        SizedBox(
          height: 280,
          child: _FlavorWheel(
            expandedIndex: _expandedIndex,
            selectedFlavors: widget.selectedFlavors,
            onCategoryTap: _tapCategory,
            selectionCounts: List.generate(
              _categories.length,
              _categorySelectionCount,
            ),
          ),
        ),

        // Sub-flavors panel (slides in when category tapped)
        if (_expandedIndex != null)
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) => SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: child,
            ),
            child: _SubFlavorPanel(
              category: _categories[_expandedIndex!],
              selectedFlavors: widget.selectedFlavors,
              onToggle: _toggleFlavor,
            ),
          ),

        const SizedBox(height: 12),

        // Custom flavor input
        _CustomFlavorInput(
          controller: _customController,
          onAdd: _addCustomFlavor,
        ),

        // Selected flavors summary
        if (widget.selectedFlavors.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedFlavors.map((flavor) {
              final categoryColor = _getColorForFlavor(flavor);
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: categoryColor,
                  radius: 6,
                ),
                label: Text(
                  flavor,
                  style: theme.textTheme.bodySmall,
                ),
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

  Color _getColorForFlavor(String flavor) {
    for (final cat in _categories) {
      if (cat.subFlavors.contains(flavor)) return cat.color;
    }
    return Colors.grey;
  }
}

/// A circular flavor wheel that shows categories as colored segments.
class _FlavorWheel extends StatelessWidget {
  const _FlavorWheel({
    required this.expandedIndex,
    required this.selectedFlavors,
    required this.onCategoryTap,
    required this.selectionCounts,
  });

  final int? expandedIndex;
  final List<String> selectedFlavors;
  final ValueChanged<int> onCategoryTap;
  final List<int> selectionCounts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _WheelPainter(
                categories: _categories,
                expandedIndex: expandedIndex,
                selectionCounts: selectionCounts,
              ),
              child: _buildTapTargets(size),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTapTargets(double size) {
    final center = size / 2;
    final categoryCount = _categories.length;
    final sweepAngle = 2 * pi / categoryCount;

    return Stack(
      children: List.generate(categoryCount, (i) {
        final startAngle = -pi / 2 + i * sweepAngle;
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = center * 0.65;
        final x = center + labelRadius * cos(midAngle);
        final y = center + labelRadius * sin(midAngle);

        final isExpanded = expandedIndex == i;
        final hasSelections = selectionCounts[i] > 0;

        return Positioned(
          left: x - 36,
          top: y - 18,
          child: GestureDetector(
            onTap: () => onCategoryTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 72,
              height: 36,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _categories[i].name,
                      style: TextStyle(
                        fontSize: isExpanded ? 11 : 10,
                        fontWeight:
                            isExpanded || hasSelections
                                ? FontWeight.bold
                                : FontWeight.w500,
                        color: isExpanded
                            ? _categories[i].color
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (hasSelections)
                      Text(
                        '${selectionCounts[i]}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.categories,
    required this.expandedIndex,
    required this.selectionCounts,
  });

  final List<_FlavorCategory> categories;
  final int? expandedIndex;
  final List<int> selectionCounts;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 4;
    final innerRadius = outerRadius * 0.3;
    final categoryCount = categories.length;
    final sweepAngle = 2 * pi / categoryCount;

    for (int i = 0; i < categoryCount; i++) {
      final startAngle = -pi / 2 + i * sweepAngle;
      final cat = categories[i];
      final isExpanded = expandedIndex == i;
      final hasSelection = selectionCounts[i] > 0;

      // Draw outer segment
      final segmentPaint = Paint()
        ..color = isExpanded
            ? cat.color
            : hasSelection
                ? cat.color.withValues(alpha: 0.85)
                : cat.color.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(
          center.dx + innerRadius * cos(startAngle),
          center.dy + innerRadius * sin(startAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle,
          sweepAngle - 0.02,
          false,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle + sweepAngle - 0.02,
          -(sweepAngle - 0.02),
          false,
        )
        ..close();

      canvas.drawPath(path, segmentPaint);

      // Draw border for expanded segment
      if (isExpanded) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawPath(path, borderPaint);
      }
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius - 2, centerPaint);

    // Draw center icon (coffee bean)
    final iconPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, innerRadius * 0.5, iconPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      expandedIndex != oldDelegate.expandedIndex ||
      selectionCounts != oldDelegate.selectionCounts;
}

/// Panel showing sub-flavors for the selected category.
class _SubFlavorPanel extends StatelessWidget {
  const _SubFlavorPanel({
    required this.category,
    required this.selectedFlavors,
    required this.onToggle,
  });

  final _FlavorCategory category;
  final List<String> selectedFlavors;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.subFlavors.map((flavor) {
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
                        : category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : category.color.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    flavor,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : category.color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CustomFlavorInput extends StatelessWidget {
  const _CustomFlavorInput({
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
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
              hintText: 'Add custom flavor...',
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

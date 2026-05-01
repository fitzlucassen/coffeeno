import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

/// SCA Coffee Taster's Flavor Wheel — full hierarchy.
class _FlavorCategory {
  const _FlavorCategory(this.name, this.color, this.subCategories);
  final String name;
  final Color color;
  final List<_SubCategory> subCategories;

  List<String> get allFlavors =>
      subCategories.expand((s) => s.flavors).toList();
}

class _SubCategory {
  const _SubCategory(this.name, this.flavors);
  final String name;
  final List<String> flavors;
}

const List<_FlavorCategory> _categories = [
  // 1. Fruity (reds/pinks)
  _FlavorCategory('Fruity', Color(0xFFE53935), [
    _SubCategory('Berry', ['Blackberry', 'Raspberry', 'Blueberry', 'Strawberry']),
    _SubCategory('Dried Fruit', ['Raisin', 'Prune', 'Coconut']),
    _SubCategory('Other Fruit', ['Pomegranate', 'Pineapple', 'Grape', 'Apple', 'Peach', 'Pear']),
    _SubCategory('Citrus Fruit', ['Grapefruit', 'Orange', 'Lemon', 'Lime']),
  ]),

  // 2. Sour/Fermented (olive/yellow-green)
  _FlavorCategory('Sour/Fermented', Color(0xFF9E9D24), [
    _SubCategory('Sour', ['Sour Aromatics', 'Acetic Acid', 'Butyric Acid', 'Citric Acid', 'Malic Acid']),
    _SubCategory('Alcohol/Fermented', ['Winey', 'Whiskey', 'Fermented', 'Overripe']),
  ]),

  // 3. Green/Vegetative (greens)
  _FlavorCategory('Green/Vegetative', Color(0xFF2E7D32), [
    _SubCategory('Olive Oil', ['Olive Oil']),
    _SubCategory('Raw', ['Under-ripe', 'Peapod', 'Fresh', 'Dark Green', 'Vegetative', 'Hay-like']),
    _SubCategory('Beany', ['Beany']),
  ]),

  // 4. Other (grays/blues)
  _FlavorCategory('Other', Color(0xFF78909C), [
    _SubCategory('Papery/Musty', ['Stale', 'Cardboard', 'Papery', 'Woody', 'Moldy/Damp', 'Musty/Dusty', 'Musty/Earthy', 'Animalic', 'Meaty/Brothy', 'Phenolic']),
    _SubCategory('Chemical', ['Bitter', 'Salty', 'Medicinal', 'Petroleum', 'Skunky', 'Rubber']),
  ]),

  // 5. Roasted (browns)
  _FlavorCategory('Roasted', Color(0xFF4E342E), [
    _SubCategory('Pipe Tobacco', ['Pipe Tobacco', 'Tobacco']),
    _SubCategory('Burnt', ['Acrid', 'Ashy', 'Smoky', 'Brown Roast']),
    _SubCategory('Cereal', ['Grain', 'Malt']),
  ]),

  // 6. Spices (dark reds/browns)
  _FlavorCategory('Spices', Color(0xFFBF360C), [
    _SubCategory('Pungent', ['Pepper', 'Anise']),
    _SubCategory('Brown Spice', ['Cinnamon', 'Nutmeg', 'Clove']),
  ]),

  // 7. Nutty/Cocoa (warm browns)
  _FlavorCategory('Nutty/Cocoa', Color(0xFF795548), [
    _SubCategory('Nutty', ['Peanuts', 'Hazelnut', 'Almond']),
    _SubCategory('Cocoa', ['Chocolate', 'Dark Chocolate', 'Cocoa']),
  ]),

  // 8. Sweet (oranges/yellows)
  _FlavorCategory('Sweet', Color(0xFFFF8F00), [
    _SubCategory('Brown Sugar', ['Molasses', 'Maple Syrup', 'Caramelized', 'Honey']),
    _SubCategory('Vanilla', ['Vanilla', 'Vanillin']),
    _SubCategory('Overall Sweet', ['Overall Sweet', 'Sweet Aromatics']),
  ]),

  // 9. Floral (purples/pinks)
  _FlavorCategory('Floral', Color(0xFFAD1457), [
    _SubCategory('Black Tea', ['Black Tea']),
    _SubCategory('Floral', ['Chamomile', 'Rose', 'Jasmine']),
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
    final allFlavors = _categories[index].allFlavors;
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
          child: _FlavorWheel(
            expandedIndex: _expandedIndex,
            onCategoryTap: _tapCategory,
            selectionCounts: List.generate(
              _categories.length,
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
              category: _categories[_expandedIndex!],
              selectedFlavors: widget.selectedFlavors,
              onToggle: _toggleFlavor,
            ),
          ),

        const SizedBox(height: 12),

        // Custom flavor
        _CustomFlavorInput(
          controller: _customController,
          onAdd: _addCustomFlavor,
        ),

        // Selected summary
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

  Color _getColorForFlavor(String flavor) {
    for (final cat in _categories) {
      if (cat.allFlavors.contains(flavor)) return cat.color;
    }
    return Colors.grey;
  }
}

/// Draws a circular flavor wheel with category segments.
class _FlavorWheel extends StatelessWidget {
  const _FlavorWheel({
    required this.expandedIndex,
    required this.onCategoryTap,
    required this.selectionCounts,
  });

  final int? expandedIndex;
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
            child: GestureDetector(
              onTapUp: (details) => _handleTap(details, size),
              child: CustomPaint(
                painter: _WheelPainter(
                  categories: _categories,
                  expandedIndex: expandedIndex,
                  selectionCounts: selectionCounts,
                ),
                child: _buildLabels(size),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapUpDetails details, double size) {
    final center = Offset(size / 2, size / 2);
    final tap = details.localPosition;
    final dx = tap.dx - center.dx;
    final dy = tap.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final outerRadius = size / 2 - 4;
    final innerRadius = outerRadius * 0.35;

    if (distance < innerRadius || distance > outerRadius) return;

    var angle = atan2(dy, dx);
    angle = (angle + pi / 2) % (2 * pi);

    final sweepAngle = 2 * pi / _categories.length;
    final index = (angle / sweepAngle).floor();
    if (index >= 0 && index < _categories.length) {
      onCategoryTap(index);
    }
  }

  Widget _buildLabels(double size) {
    final center = size / 2;
    final categoryCount = _categories.length;
    final sweepAngle = 2 * pi / categoryCount;

    return Stack(
      children: List.generate(categoryCount, (i) {
        final startAngle = -pi / 2 + i * sweepAngle;
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = center * 0.67;
        final x = center + labelRadius * cos(midAngle);
        final y = center + labelRadius * sin(midAngle);

        final isExpanded = expandedIndex == i;
        final hasSelections = selectionCounts[i] > 0;

        return Positioned(
          left: x - 40,
          top: y - 16,
          child: IgnorePointer(
            child: SizedBox(
              width: 80,
              height: 32,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _categories[i].name,
                      style: TextStyle(
                        fontSize: isExpanded ? 10 : 9,
                        fontWeight: isExpanded || hasSelections
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isExpanded
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.9),
                        shadows: const [
                          Shadow(blurRadius: 2, color: Colors.black54),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasSelections)
                      Container(
                        margin: const EdgeInsets.only(top: 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${selectionCounts[i]}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: _categories[i].color,
                          ),
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
    final innerRadius = outerRadius * 0.35;
    final categoryCount = categories.length;
    final sweepAngle = 2 * pi / categoryCount;
    final gapAngle = 0.02;

    for (int i = 0; i < categoryCount; i++) {
      final startAngle = -pi / 2 + i * sweepAngle;
      final cat = categories[i];
      final isExpanded = expandedIndex == i;
      final hasSelection = selectionCounts[i] > 0;

      // Main segment
      final segmentPaint = Paint()
        ..color = isExpanded
            ? cat.color
            : hasSelection
                ? cat.color.withValues(alpha: 0.85)
                : cat.color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(
          center.dx + innerRadius * cos(startAngle + gapAngle / 2),
          center.dy + innerRadius * sin(startAngle + gapAngle / 2),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle + gapAngle / 2,
          sweepAngle - gapAngle,
          false,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle + sweepAngle - gapAngle / 2,
          -(sweepAngle - gapAngle),
          false,
        )
        ..close();

      canvas.drawPath(path, segmentPaint);

      // Highlight border on expanded
      if (isExpanded) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawPath(path, borderPaint);
      }

      // Draw sub-category divisions as lighter arcs in outer ring
      final subCats = cat.subCategories;
      if (subCats.length > 1) {
        final subSweep = (sweepAngle - gapAngle) / subCats.length;
        final midRadius = innerRadius + (outerRadius - innerRadius) * 0.5;

        for (int j = 1; j < subCats.length; j++) {
          final divAngle = startAngle + gapAngle / 2 + j * subSweep;
          final divPaint = Paint()
            ..color = Colors.white.withValues(alpha: isExpanded ? 0.6 : 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

          canvas.drawLine(
            Offset(
              center.dx + midRadius * cos(divAngle),
              center.dy + midRadius * sin(divAngle),
            ),
            Offset(
              center.dx + outerRadius * cos(divAngle),
              center.dy + outerRadius * sin(divAngle),
            ),
            divPaint,
          );
        }
      }
    }

    // Center circle
    final centerPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius - 2, centerPaint);

    // Center ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, innerRadius * 0.6, ringPaint);

    // "Coffee" text in center
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '☕',
        style: TextStyle(fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      expandedIndex != oldDelegate.expandedIndex ||
      selectionCounts != oldDelegate.selectionCounts;
}

/// Panel showing grouped sub-flavors for the tapped category.
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
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.color.withValues(alpha: 0.3),
        ),
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
          ...category.subCategories.map((sub) => Padding(
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
          )),
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

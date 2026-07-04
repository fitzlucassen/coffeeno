import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/flavor_wheel_data.dart';

/// The circular, tappable flavor wheel used by the flavor selector. Renders the
/// nine SCA categories as segments (via [FlavorWheelPainter]) with overlaid
/// labels and per-category selection-count badges, and reports category taps.
class FlavorWheel extends StatelessWidget {
  const FlavorWheel({
    super.key,
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
                painter: FlavorWheelPainter(
                  categories: kFlavorCategories,
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

    final sweepAngle = 2 * pi / kFlavorCategories.length;
    final index = (angle / sweepAngle).floor();
    if (index >= 0 && index < kFlavorCategories.length) {
      onCategoryTap(index);
    }
  }

  Widget _buildLabels(double size) {
    final center = size / 2;
    final categoryCount = kFlavorCategories.length;
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
                      kFlavorCategories[i].name,
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
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${selectionCounts[i]}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: kFlavorCategories[i].color,
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

/// Paints the wheel segments, sub-category dividers and center medallion.
class FlavorWheelPainter extends CustomPainter {
  FlavorWheelPainter({
    required this.categories,
    required this.expandedIndex,
    required this.selectionCounts,
  });

  final List<FlavorCategory> categories;
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
      text: const TextSpan(text: '☕', style: TextStyle(fontSize: 24)),
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
  bool shouldRepaint(covariant FlavorWheelPainter oldDelegate) =>
      expandedIndex != oldDelegate.expandedIndex ||
      selectionCounts != oldDelegate.selectionCounts;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:coffeeno/core/theme/app_colors.dart';

/// A radar/spider chart that visually displays the six tasting scores.
///
/// Each axis represents one cupping dimension (Aroma, Flavor, Acidity, Body,
/// Sweetness, Aftertaste). The axis [labels] are passed in (localized by the
/// caller). Scores range from 0 to [maxScore] (default 5).
///
/// Named `ScoreRadarChart` rather than "FlavorWheel" to avoid confusion with
/// the SCA flavor-selection wheel in [FlavorWheel] (flavor_wheel_painter.dart) —
/// this widget is a score chart, not a flavor picker.
class ScoreRadarChart extends StatelessWidget {
  const ScoreRadarChart({
    super.key,
    required this.aroma,
    required this.flavor,
    required this.acidity,
    required this.body,
    required this.sweetness,
    required this.aftertaste,
    required this.labels,
    this.maxScore = 5,
    this.size = 200,
  });

  final int aroma;
  final int flavor;
  final int acidity;
  final int body;
  final int sweetness;
  final int aftertaste;

  /// The six axis labels, in score order. Use `tastingAxisLabels(l10n)`.
  final List<String> labels;
  final int maxScore;
  final double size;

  List<int> get _scores => [
    aroma,
    flavor,
    acidity,
    body,
    sweetness,
    aftertaste,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScoreRadarPainter(
          scores: _scores,
          maxScore: maxScore,
          labels: labels,
          fillColor: AppColors.terracotta.withValues(alpha: 0.25),
          strokeColor: AppColors.terracotta,
          gridColor: theme.colorScheme.outlineVariant,
          labelColor: theme.colorScheme.onSurface,
          labelFontSize: 10,
        ),
      ),
    );
  }
}

class _ScoreRadarPainter extends CustomPainter {
  _ScoreRadarPainter({
    required this.scores,
    required this.maxScore,
    required this.labels,
    required this.fillColor,
    required this.strokeColor,
    required this.gridColor,
    required this.labelColor,
    required this.labelFontSize,
  });

  final List<int> scores;
  final int maxScore;
  final List<String> labels;
  final Color fillColor;
  final Color strokeColor;
  final Color gridColor;
  final Color labelColor;
  final double labelFontSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 28;
    final sides = scores.length;
    final angle = (2 * math.pi) / sides;

    // Draw grid rings
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int ring = 1; ring <= maxScore; ring++) {
      final ringRadius = radius * (ring / maxScore);
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final a = -math.pi / 2 + angle * i;
        final point = Offset(
          center.dx + ringRadius * math.cos(a),
          center.dy + ringRadius * math.sin(a),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axes
    for (int i = 0; i < sides; i++) {
      final a = -math.pi / 2 + angle * i;
      final end = Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      );
      canvas.drawLine(center, end, gridPaint);
    }

    // Draw data polygon
    final dataPath = Path();
    final dataDots = <Offset>[];
    for (int i = 0; i < sides; i++) {
      final a = -math.pi / 2 + angle * i;
      final value = scores[i].clamp(0, maxScore);
      final r = radius * (value / maxScore);
      final point = Offset(
        center.dx + r * math.cos(a),
        center.dy + r * math.sin(a),
      );
      dataDots.add(point);
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // Fill
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Dots
    final dotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    for (final dot in dataDots) {
      canvas.drawCircle(dot, 3, dotPaint);
    }

    // Labels
    for (int i = 0; i < sides; i++) {
      final a = -math.pi / 2 + angle * i;
      final labelRadius = radius + 18;
      final labelPos = Offset(
        center.dx + labelRadius * math.cos(a),
        center.dy + labelRadius * math.sin(a),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: labelColor,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        labelPos.dx - textPainter.width / 2,
        labelPos.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRadarPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}

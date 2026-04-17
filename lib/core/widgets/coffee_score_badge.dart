import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CoffeeScoreBadge extends StatelessWidget {
  const CoffeeScoreBadge({
    super.key,
    required this.score,
    this.size = CoffeeScoreBadgeSize.medium,
  });

  final double score;
  final CoffeeScoreBadgeSize size;

  Color get _color {
    if (score >= 4.5) return AppColors.terracotta;
    if (score >= 3.5) return AppColors.sage;
    if (score >= 2.5) return AppColors.espressoMuted;
    return AppColors.espressoMuted;
  }

  @override
  Widget build(BuildContext context) {
    final double dimension;
    final TextStyle textStyle;

    switch (size) {
      case CoffeeScoreBadgeSize.small:
        dimension = 32;
        textStyle = AppTypography.labelMedium;
      case CoffeeScoreBadgeSize.medium:
        dimension = 40;
        textStyle = AppTypography.titleSmall;
      case CoffeeScoreBadgeSize.large:
        dimension = 52;
        textStyle = AppTypography.titleLarge;
    }

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(dimension / 3),
      ),
      alignment: Alignment.center,
      child: Text(
        score.toStringAsFixed(1),
        style: textStyle.copyWith(color: Colors.white),
      ),
    );
  }
}

enum CoffeeScoreBadgeSize { small, medium, large }

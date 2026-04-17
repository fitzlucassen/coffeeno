import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 24,
    this.maxRating = 5,
    this.allowHalf = true,
  });

  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double size;
  final int maxRating;
  final bool allowHalf;

  bool get _interactive => onRatingChanged != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1.0;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (allowHalf && rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }

        final star = Icon(
          icon,
          size: size,
          color: rating >= starValue - 0.5
              ? AppColors.starFilled
              : AppColors.starEmpty,
        );

        if (!_interactive) return star;

        return GestureDetector(
          onTapDown: (details) {
            HapticFeedback.selectionClick();
            final half = details.localPosition.dx < size / 2;
            final value = allowHalf && half ? starValue - 0.5 : starValue;
            onRatingChanged!(value);
          },
          child: star,
        );
      }),
    );
  }
}

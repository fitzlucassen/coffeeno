import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/widgets/star_rating.dart';

/// A reusable section for capturing all six tasting scores plus overall rating.
class TastingNotesInput extends StatelessWidget {
  const TastingNotesInput({
    super.key,
    required this.aroma,
    required this.flavor,
    required this.acidity,
    required this.body,
    required this.sweetness,
    required this.aftertaste,
    required this.overallRating,
    required this.onAromaChanged,
    required this.onFlavorChanged,
    required this.onAcidityChanged,
    required this.onBodyChanged,
    required this.onSweetnessChanged,
    required this.onAftertasteChanged,
    required this.onOverallRatingChanged,
  });

  final int aroma;
  final int flavor;
  final int acidity;
  final int body;
  final int sweetness;
  final int aftertaste;
  final double overallRating;
  final ValueChanged<int> onAromaChanged;
  final ValueChanged<int> onFlavorChanged;
  final ValueChanged<int> onAcidityChanged;
  final ValueChanged<int> onBodyChanged;
  final ValueChanged<int> onSweetnessChanged;
  final ValueChanged<int> onAftertasteChanged;
  final ValueChanged<double> onOverallRatingChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tastings, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),

        // Individual scores
        _ScoreRow(
          label: l10n.aroma,
          icon: Icons.air_rounded,
          score: aroma,
          onChanged: onAromaChanged,
        ),
        _ScoreRow(
          label: l10n.flavor,
          icon: Icons.restaurant_rounded,
          score: flavor,
          onChanged: onFlavorChanged,
        ),
        _ScoreRow(
          label: l10n.acidity,
          icon: Icons.bolt_rounded,
          score: acidity,
          onChanged: onAcidityChanged,
        ),
        _ScoreRow(
          label: l10n.body,
          icon: Icons.fitness_center_rounded,
          score: body,
          onChanged: onBodyChanged,
        ),
        _ScoreRow(
          label: l10n.sweetness,
          icon: Icons.cake_rounded,
          score: sweetness,
          onChanged: onSweetnessChanged,
        ),
        _ScoreRow(
          label: l10n.aftertaste,
          icon: Icons.timelapse_rounded,
          score: aftertaste,
          onChanged: onAftertasteChanged,
        ),

        const Divider(height: 32),

        // Overall rating (larger)
        Text(l10n.overallRating, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              StarRating(
                rating: overallRating,
                size: 40,
                onRatingChanged: onOverallRatingChanged,
              ),
              const SizedBox(height: 8),
              Text(
                overallRating.toStringAsFixed(1),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.icon,
    required this.score,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: StarRating(
              rating: score.toDouble(),
              size: 28,
              allowHalf: false,
              onRatingChanged: (v) => onChanged(v.toInt()),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$score',
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../../domain/gamification.dart';

/// Maps an [ExpertTier] to its localized display title.
String expertTierTitle(AppLocalizations l10n, ExpertTier tier) {
  switch (tier) {
    case ExpertTier.beanSprout:
      return l10n.levelBeanSprout;
    case ExpertTier.homeBrewer:
      return l10n.levelHomeBrewer;
    case ExpertTier.enthusiast:
      return l10n.levelEnthusiast;
    case ExpertTier.cupper:
      return l10n.levelCupper;
    case ExpertTier.connoisseur:
      return l10n.levelConnoisseur;
    case ExpertTier.masterTaster:
      return l10n.levelMasterTaster;
  }
}

/// A compact badge showing the user's expert tier title and, optionally, a
/// progress bar toward the next tier. Derives everything from a point total.
class ExpertBadge extends StatelessWidget {
  const ExpertBadge({
    super.key,
    required this.points,
    this.showProgress = true,
  });

  final int points;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final level = ExpertLevel.fromPoints(points);
    final title = expertTierTitle(l10n, level.tier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.pointsLabel(level.points),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer
                      .withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (showProgress && level.nextTier != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: level.progressToNextTier,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.pointsToNextLevel(
              level.pointsToNextTier,
              expertTierTitle(l10n, level.nextTier!),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

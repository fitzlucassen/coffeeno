import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/features/social/domain/leaderboard_entry.dart';
import 'package:coffeeno/features/social/presentation/widgets/leaderboard_tile.dart';

/// A ranked list of coffees for a given origin, reusable in both
/// [OriginDetailScreen] and other contexts.
class OriginRankingList extends StatelessWidget {
  const OriginRankingList({
    super.key,
    required this.entries,
    this.onTap,
  });

  final List<LeaderboardEntry> entries;
  final void Function(LeaderboardEntry entry)? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.coffee_outlined,
                size: 48,
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).noCoffeesFromOrigin,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return LeaderboardTile(
          rank: index + 1,
          entry: entry,
          onTap: onTap != null ? () => onTap!(entry) : null,
        );
      },
    );
  }
}

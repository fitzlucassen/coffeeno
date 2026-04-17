import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/widgets/star_rating.dart';
import 'package:coffeeno/features/social/domain/leaderboard_entry.dart';

/// A single row in the leaderboard, showing rank, coffee photo, name, roaster,
/// average rating, and total ratings count.
class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.entry,
    this.onTap,
  });

  final int rank;
  final LeaderboardEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Rank number.
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: textTheme.titleMedium?.copyWith(
                  color: rank <= 3
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: rank <= 3 ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Coffee photo.
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: entry.photoUrl != null && entry.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: entry.photoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 48,
                        height: 48,
                        color: colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.coffee,
                          color: colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.coffee,
                          color: colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.coffee,
                        color: colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Name and roaster.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.coffeeName,
                    style: textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.roasterName,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Rating + count.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StarRating(rating: entry.avgRating, size: 16),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).ratingsCount(entry.ratingsCount),
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

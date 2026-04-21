import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/widgets/app_card.dart';
import 'package:coffeeno/core/widgets/coffee_score_badge.dart';
import '../../domain/coffee.dart';

class CoffeeCard extends StatelessWidget {
  const CoffeeCard({super.key, required this.coffee});

  final Coffee coffee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      onTap: () => context.push('/coffee/${coffee.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo / placeholder
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: coffee.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: coffee.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _Placeholder(colorScheme),
                      errorWidget: (_, __, ___) => _Placeholder(colorScheme),
                    )
                  : _Placeholder(colorScheme),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          coffee.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (coffee.ratingsCount > 0)
                        CoffeeScoreBadge(
                          score: coffee.avgRating,
                          size: CoffeeScoreBadgeSize.small,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coffee.roaster,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coffee.originCountry,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (coffee.flavorNotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Flexible(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        clipBehavior: Clip.hardEdge,
                        children: coffee.flavorNotes
                            .take(3)
                            .map(
                              (note) => Chip(
                                label: Text(note),
                                visualDensity: VisualDensity.compact,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                labelStyle: theme.textTheme.labelSmall,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.colorScheme);
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Icons.coffee_rounded,
          size: 48,
          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

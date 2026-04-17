import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:coffeeno/core/widgets/app_card.dart';
import 'package:coffeeno/core/widgets/coffee_score_badge.dart';
import 'package:coffeeno/core/widgets/star_rating.dart';
import '../providers/tasting_provider.dart';
import '../widgets/flavor_wheel.dart';

class TastingDetailScreen extends ConsumerWidget {
  const TastingDetailScreen({super.key, required this.tastingId});

  final String tastingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tastingAsync = ref.watch(tastingDetailProvider(tastingId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tastings),
      ),
      body: tastingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.error)),
        data: (tasting) {
          if (tasting == null) {
            return Center(child: Text(l10n.error));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coffee info
                AppCard(
                  onTap: () => context.push('/coffee/${tasting.coffeeId}'),
                  child: Row(
                    children: [
                      // Coffee photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: tasting.coffeePhotoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: tasting.coffeePhotoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      _CoffeeThumbnail(colorScheme),
                                  errorWidget: (_, __, ___) =>
                                      _CoffeeThumbnail(colorScheme),
                                )
                              : _CoffeeThumbnail(colorScheme),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tasting.coffeeName,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              tasting.roasterName,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Brew parameters card
                Text(l10n.brewMethod, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    children: [
                      _ParamRow(
                        icon: Icons.coffee_maker_rounded,
                        label: l10n.brewMethod,
                        value: tasting.brewMethod,
                      ),
                      _ParamRow(
                        icon: Icons.grain_rounded,
                        label: l10n.grindSize,
                        value: tasting.grindSize,
                      ),
                      _ParamRow(
                        icon: Icons.scale_rounded,
                        label: l10n.dose,
                        value: '${tasting.doseGrams.toStringAsFixed(1)}g',
                      ),
                      _ParamRow(
                        icon: Icons.water_drop_rounded,
                        label: l10n.waterAmount,
                        value: '${tasting.waterMl.toStringAsFixed(0)}ml',
                      ),
                      if (tasting.ratio.isNotEmpty)
                        _ParamRow(
                          icon: Icons.compare_arrows_rounded,
                          label: l10n.ratio,
                          value: tasting.ratio,
                        ),
                      _ParamRow(
                        icon: Icons.timer_rounded,
                        label: l10n.brewTime,
                        value: _formatBrewTime(tasting.brewTimeSec),
                      ),
                      if (tasting.waterTempC != null)
                        _ParamRow(
                          icon: Icons.thermostat_rounded,
                          label: l10n.waterTemperature,
                          value: '${tasting.waterTempC}\u00b0C',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Flavor wheel
                Center(
                  child: FlavorWheel(
                    aroma: tasting.aroma,
                    flavor: tasting.flavor,
                    acidity: tasting.acidity,
                    body: tasting.body,
                    sweetness: tasting.sweetness,
                    aftertaste: tasting.aftertaste,
                  ),
                ),
                const SizedBox(height: 24),

                // Overall rating
                Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.overallRating,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      CoffeeScoreBadge(
                        score: tasting.overallRating,
                        size: CoffeeScoreBadgeSize.large,
                      ),
                      const SizedBox(height: 8),
                      StarRating(
                        rating: tasting.overallRating,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notes
                if (tasting.notes != null &&
                    tasting.notes!.isNotEmpty) ...[
                  Text(l10n.notes, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Text(
                      tasting.notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Like & comment row
                Row(
                  children: [
                    IconButton.outlined(
                      onPressed: () {
                        // TODO: implement like toggle
                      },
                      icon: const Icon(Icons.favorite_border_rounded),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tasting.likesCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.comment_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tasting.commentsCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Text(
                      DateFormat.yMMMd().format(tasting.tastingDate),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatBrewTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
}

class _ParamRow extends StatelessWidget {
  const _ParamRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodySmall),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoffeeThumbnail extends StatelessWidget {
  const _CoffeeThumbnail(this.colorScheme);
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Icons.coffee_rounded,
          size: 28,
          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

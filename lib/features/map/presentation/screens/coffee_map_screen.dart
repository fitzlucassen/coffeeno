import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/features/map/presentation/providers/map_provider.dart';
import 'package:coffeeno/features/map/presentation/widgets/world_map.dart';

/// The map screen showing coffee-producing countries on a world map.
/// Markers are sized by coffee count and colored by average rating.
class CoffeeMapScreen extends ConsumerWidget {
  const CoffeeMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final originsAsync = ref.watch(originStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final scope = ref.watch(mapScopeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coffeeOrigins),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<MapScope>(
              segments: [
                ButtonSegment(
                  value: MapScope.mine,
                  label: Text(l10n.mapScopeMine),
                  icon: const Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: MapScope.global,
                  label: Text(l10n.mapScopeGlobal),
                  icon: const Icon(Icons.public_outlined),
                ),
              ],
              selected: {scope},
              onSelectionChanged: (s) =>
                  ref.read(mapScopeProvider.notifier).set(s.first),
            ),
          ),
        ),
      ),
      body: originsAsync.when(
        data: (origins) {
          if (origins.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noOriginsYet,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.addCoffeesForMap,
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return WorldMap(
            origins: origins,
            onMarkerTap: (origin) {
              context.push('/origin/${Uri.encodeComponent(origin.country)}');
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(l10n.error, style: textTheme.titleMedium),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(originStatsProvider),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

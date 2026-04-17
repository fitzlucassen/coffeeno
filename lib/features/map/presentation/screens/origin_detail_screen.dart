import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/features/map/presentation/providers/map_provider.dart';
import 'package:coffeeno/features/map/presentation/widgets/origin_ranking_list.dart';

/// Detail screen for a single coffee origin country, showing the top-rated
/// coffees from that country.
class OriginDetailScreen extends ConsumerWidget {
  const OriginDetailScreen({
    super.key,
    required this.country,
  });

  final String country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decodedCountry = Uri.decodeComponent(country);
    final coffeesAsync = ref.watch(coffeesByOriginProvider(decodedCountry));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mostLovedFrom(decodedCountry)),
      ),
      body: coffeesAsync.when(
        data: (entries) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            child: OriginRankingList(
              entries: entries,
              onTap: (entry) => context.push('/coffee/${entry.coffeeId}'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
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
                onPressed: () => ref.invalidate(
                  coffeesByOriginProvider(decodedCountry),
                ),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/l10n/app_localizations.dart';
import '../../../coffee/domain/coffee.dart';
import '../../../roaster/domain/roaster.dart';
import '../providers/explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploreTab)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingCoffeesProvider);
          ref.invalidate(recentlyAddedProvider);
          ref.invalidate(topRatedProvider);
          ref.invalidate(newRoastersProvider);
          ref.invalidate(popularNearMeProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            _PopularNearMeSection(),
            _Section(
              title: l10n.exploreTrending,
              child: _CoffeeHorizontalList(
                provider: trendingCoffeesProvider,
              ),
            ),
            _Section(
              title: l10n.exploreRecentlyAdded,
              child: _CoffeeHorizontalList(
                provider: recentlyAddedProvider,
              ),
            ),
            _Section(
              title: l10n.exploreTopRated,
              child: _CoffeeHorizontalList(
                provider: topRatedProvider,
              ),
            ),
            _Section(
              title: l10n.exploreNewRoasters,
              child: _RoasterHorizontalList(
                provider: newRoastersProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        child,
      ],
    );
  }
}

class _CoffeeHorizontalList extends ConsumerWidget {
  const _CoffeeHorizontalList({required this.provider});
  final FutureProvider<List<Coffee>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);

    return async.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(AppLocalizations.of(context).error),
      ),
      data: (coffees) {
        if (coffees.isEmpty) {
          return const SizedBox(height: 60);
        }
        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: coffees.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _ExploreCoffeeCard(coffee: coffees[index]),
          ),
        );
      },
    );
  }
}

class _ExploreCoffeeCard extends StatelessWidget {
  const _ExploreCoffeeCard({required this.coffee});
  final Coffee coffee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.push('/coffee/${coffee.id}'),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: coffee.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: coffee.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            _CoffeePlaceholder(colorScheme),
                        errorWidget: (_, _, _) =>
                            _CoffeePlaceholder(colorScheme),
                      )
                    : _CoffeePlaceholder(colorScheme),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffee.name,
                      style: theme.textTheme.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coffee.roaster,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (coffee.avgRating > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            coffee.avgRating.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoasterHorizontalList extends ConsumerWidget {
  const _RoasterHorizontalList({required this.provider});
  final FutureProvider<List<Roaster>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);

    return async.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(AppLocalizations.of(context).error),
      ),
      data: (roasters) {
        if (roasters.isEmpty) {
          return const SizedBox(height: 60);
        }
        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: roasters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _ExploreRoasterCard(roaster: roasters[index]),
          ),
        );
      },
    );
  }
}

class _ExploreRoasterCard extends StatelessWidget {
  const _ExploreRoasterCard({required this.roaster});
  final Roaster roaster;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.push('/roaster/${roaster.id}'),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              roaster.name,
              style: theme.textTheme.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (roaster.city != null || roaster.country != null) ...[
              const SizedBox(height: 2),
              Text(
                [roaster.city, roaster.country]
                    .whereType<String>()
                    .join(', '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PopularNearMeSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCoffees = ref.watch(popularNearMeProvider);

    return asyncCoffees.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (coffees) {
        // Hide the section entirely when user has no country or no results.
        if (coffees == null || coffees.isEmpty) return const SizedBox.shrink();

        return _Section(
          title: AppLocalizations.of(context).exploreNearYou,
          child: SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: coffees.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _ExploreCoffeeCard(coffee: coffees[index]),
            ),
          ),
        );
      },
    );
  }
}

class _CoffeePlaceholder extends StatelessWidget {
  const _CoffeePlaceholder(this.colorScheme);
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Icons.coffee_rounded,
          size: 32,
          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

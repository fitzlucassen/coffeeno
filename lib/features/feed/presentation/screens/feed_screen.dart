import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/router/app_router.dart';
import 'package:coffeeno/features/feed/domain/feed_entry.dart';
import 'package:coffeeno/features/feed/presentation/providers/feed_provider.dart';
import 'package:coffeeno/features/feed/presentation/widgets/feed_roaster_post_card.dart';
import 'package:coffeeno/features/feed/presentation/widgets/feed_tasting_card.dart';

/// The social feed screen showing recent tastings from all users.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final feedAsync = ref.watch(mergedFeedProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () => context.push(AppRoutes.userSearch),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: l10n.leaderboard,
            onPressed: () => context.push(AppRoutes.leaderboard),
          ),
        ],
      ),
      body: feedAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return _EmptyFeed(
              colorScheme: colorScheme,
              textTheme: textTheme,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(feedProvider),
            color: colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final entry = items[index];
                return switch (entry) {
                  TastingFeedEntry(:final tasting) =>
                    FeedTastingCard(item: tasting),
                  RoasterPostFeedEntry(:final post) =>
                    FeedRoasterPostCard(post: post),
                };
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.error,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(feedProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).emptyFeed,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.userSearch),
              icon: const Icon(Icons.person_search),
              label: Text(AppLocalizations.of(context).findPeople),
            ),
          ],
        ),
      ),
    );
  }
}

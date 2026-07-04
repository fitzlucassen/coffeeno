import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/widgets/empty_state_view.dart';
import 'package:coffeeno/core/widgets/error_retry_view.dart';
import 'package:coffeeno/features/social/presentation/providers/leaderboard_provider.dart';
import 'package:coffeeno/features/social/presentation/widgets/leaderboard_tile.dart';

/// Leaderboard screen showing the top-rated coffees globally and by origin.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.global),
            Tab(text: l10n.byOrigin),
          ],
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GlobalTab(ref: ref, l10n: l10n),
          _ByOriginTab(
            ref: ref,
            l10n: l10n,
            selectedCountry: _selectedCountry,
            onCountryChanged: (country) {
              setState(() => _selectedCountry = country);
            },
          ),
        ],
      ),
    );
  }
}

class _GlobalTab extends StatelessWidget {
  const _GlobalTab({required this.ref, required this.l10n});

  final WidgetRef ref;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return EmptyStateView(
            icon: Icons.emoji_events_outlined,
            message: l10n.noRatedCoffeesYet,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return LeaderboardTile(
              rank: index + 1,
              entry: entry,
              onTap: () => context.push('/coffee/${entry.coffeeId}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const ErrorRetryView(),
    );
  }
}

class _ByOriginTab extends StatelessWidget {
  const _ByOriginTab({
    required this.ref,
    required this.l10n,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  final WidgetRef ref;
  final AppLocalizations l10n;
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final originsAsync = ref.watch(leaderboardOriginsProvider);

    return Column(
      children: [
        // Country picker. The options are the origins actually present in the
        // corpus, so a selection always maps to real, queryable coffees.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: DropdownButtonFormField<String>(
            initialValue: selectedCountry,
            isExpanded: true, // Prevent horizontal overflow on long names.
            decoration: InputDecoration(
              labelText: l10n.originCountry,
              prefixIcon: const Icon(Icons.public),
            ),
            items:
                originsAsync.asData?.value
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList() ??
                const [],
            onChanged: onCountryChanged,
          ),
        ),

        // Results.
        Expanded(
          child: selectedCountry == null
              ? Center(
                  child: Text(
                    l10n.selectCountry,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : _OriginLeaderboard(
                  ref: ref,
                  country: selectedCountry!,
                  l10n: l10n,
                ),
        ),
      ],
    );
  }
}

class _OriginLeaderboard extends StatelessWidget {
  const _OriginLeaderboard({
    required this.ref,
    required this.country,
    required this.l10n,
  });

  final WidgetRef ref;
  final String country;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(leaderboardByOriginProvider(country));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              l10n.noRatedCoffeesFrom(country),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return LeaderboardTile(
              rank: index + 1,
              entry: entry,
              onTap: () => context.push('/coffee/${entry.coffeeId}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const ErrorRetryView(),
    );
  }
}

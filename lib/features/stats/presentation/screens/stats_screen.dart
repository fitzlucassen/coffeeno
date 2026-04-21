import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:coffeeno/core/widgets/app_card.dart';
import 'package:coffeeno/features/coffee/domain/coffee.dart';
import 'package:coffeeno/features/coffee/presentation/providers/coffee_provider.dart';
import 'package:coffeeno/features/stats/presentation/providers/stats_provider.dart';
import 'package:coffeeno/features/tasting/domain/tasting.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

/// Stats & Insights screen showing the user's coffee tasting statistics.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.insights)),
        body: Center(
          child: Text(
            l10n.error,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final coffeesAsync = ref.watch(userCoffeesProvider(userId));
    final tastingsAsync = ref.watch(userAllTastingsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insights)),
      body: coffeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          colorScheme: colorScheme,
          textTheme: textTheme,
          message: l10n.error,
        ),
        data: (coffees) => tastingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            colorScheme: colorScheme,
            textTheme: textTheme,
            message: l10n.error,
          ),
          data: (tastings) => _StatsBody(
            coffees: coffees,
            tastings: tastings,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.colorScheme,
    required this.textTheme,
    required this.message,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              message,
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({
    required this.coffees,
    required this.tastings,
  });

  final List<Coffee> coffees;
  final List<Tasting> tastings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // --- Summary cards row ---
        _SummaryRow(
          coffeeCount: coffees.length,
          tastingCount: tastings.length,
          avgScore: _computeAvgScore(tastings),
        ),
        const SizedBox(height: 20),

        // --- Top Origins ---
        _SectionTitle(title: l10n.topOrigins),
        const SizedBox(height: 8),
        AppCard(
          child: _HorizontalBarList(
            entries: _topEntries(
              coffees
                  .where((c) => c.originCountry.isNotEmpty)
                  .map((c) => c.originCountry),
            ),
            barColor: colorScheme.primary,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(height: 20),

        // --- Top Processing Methods ---
        _SectionTitle(title: l10n.topProcessing),
        const SizedBox(height: 8),
        AppCard(
          child: _HorizontalBarList(
            entries: _topEntries(
              coffees
                  .where((c) =>
                      c.processingMethod != null &&
                      c.processingMethod!.isNotEmpty)
                  .map((c) => c.processingMethod!),
            ),
            barColor: colorScheme.primary,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(height: 20),

        // --- Flavor Profile ---
        _SectionTitle(title: l10n.flavorProfile),
        const SizedBox(height: 8),
        AppCard(
          child: _FlavorProfileSection(
            tastings: tastings,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(height: 20),

        // --- Tasting Timeline ---
        _SectionTitle(title: l10n.tastingTimeline),
        const SizedBox(height: 8),
        AppCard(
          child: _TastingTimelineSection(
            tastings: tastings.take(10).toList(),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  double _computeAvgScore(List<Tasting> tastings) {
    if (tastings.isEmpty) return 0;
    final sum =
        tastings.fold<double>(0, (prev, t) => prev + t.overallRating);
    return sum / tastings.length;
  }

  /// Returns the top 5 entries by frequency from the given values.
  List<MapEntry<String, int>> _topEntries(Iterable<String> values) {
    final counts = <String, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.coffeeCount,
    required this.tastingCount,
    required this.avgScore,
  });

  final int coffeeCount;
  final int tastingCount;
  final double avgScore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: l10n.totalCoffees,
            value: coffeeCount.toString(),
            icon: Icons.coffee_outlined,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: l10n.totalTastings,
            value: tastingCount.toString(),
            icon: Icons.rate_review_outlined,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: l10n.avgScore,
            value: avgScore > 0 ? avgScore.toStringAsFixed(1) : '--',
            icon: Icons.star_outline,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final IconData icon;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 24, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal bar list (for Top Origins / Top Processing)
// ---------------------------------------------------------------------------

class _HorizontalBarList extends StatelessWidget {
  const _HorizontalBarList({
    required this.entries,
    required this.barColor,
    required this.textTheme,
  });

  final List<MapEntry<String, int>> entries;
  final Color barColor;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '--',
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final maxCount = entries.first.value;

    return Column(
      children: entries.map((entry) {
        final fraction = maxCount > 0 ? entry.value / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  entry.key,
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 18,
                        width: constraints.maxWidth * fraction,
                        decoration: BoxDecoration(
                          color: barColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.value.toString(),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Flavor Profile
// ---------------------------------------------------------------------------

class _FlavorProfileSection extends StatelessWidget {
  const _FlavorProfileSection({
    required this.tastings,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<Tasting> tastings;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (tastings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '--',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final count = tastings.length;
    final avgAroma =
        tastings.fold<int>(0, (s, t) => s + t.aroma) / count;
    final avgFlavor =
        tastings.fold<int>(0, (s, t) => s + t.flavor) / count;
    final avgAcidity =
        tastings.fold<int>(0, (s, t) => s + t.acidity) / count;
    final avgBody =
        tastings.fold<int>(0, (s, t) => s + t.body) / count;
    final avgSweetness =
        tastings.fold<int>(0, (s, t) => s + t.sweetness) / count;
    final avgAftertaste =
        tastings.fold<int>(0, (s, t) => s + t.aftertaste) / count;

    final dimensions = <String, double>{
      l10n.aroma: avgAroma,
      l10n.flavor: avgFlavor,
      l10n.acidity: avgAcidity,
      l10n.body: avgBody,
      l10n.sweetness: avgSweetness,
      l10n.aftertaste: avgAftertaste,
    };

    return Column(
      children: dimensions.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  entry.key,
                  style: textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value / 5,
                  backgroundColor:
                      colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  entry.value.toStringAsFixed(1),
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Tasting Timeline
// ---------------------------------------------------------------------------

class _TastingTimelineSection extends StatelessWidget {
  const _TastingTimelineSection({
    required this.tastings,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<Tasting> tastings;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (tastings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '--',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final dateFormat = DateFormat.yMMMd();

    return Column(
      children: tastings.map((tasting) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tasting.coffeeName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateFormat.format(tasting.tastingDate),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tasting.overallRating.toStringAsFixed(1),
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

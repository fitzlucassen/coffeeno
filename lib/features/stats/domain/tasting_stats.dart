import 'package:coffeeno/features/coffee/domain/coffee.dart';
import 'package:coffeeno/features/tasting/domain/tasting.dart';

/// A labeled frequency count, e.g. an origin country or processing method and
/// how many of the user's coffees use it. Used by the "Top Origins" and
/// "Top Processing" bar lists on the stats screen.
class StatCount {
  const StatCount({required this.label, required this.count});

  final String label;
  final int count;
}

/// Average score (1–5) for each of the six tasting flavor dimensions across all
/// of the user's tastings. Null on [TastingStats] when there are no tastings.
class FlavorProfile {
  const FlavorProfile({
    required this.aroma,
    required this.flavor,
    required this.acidity,
    required this.body,
    required this.sweetness,
    required this.aftertaste,
  });

  final double aroma;
  final double flavor;
  final double acidity;
  final double body;
  final double sweetness;
  final double aftertaste;
}

/// A single entry in the tasting timeline (the 10 most recent tastings).
class TimelineEntry {
  const TimelineEntry({
    required this.coffeeName,
    required this.tastingDate,
    required this.overallRating,
  });

  final String coffeeName;
  final DateTime tastingDate;
  final double overallRating;
}

/// Immutable, precomputed statistics rendered by the Stats & Insights screen.
///
/// Everything the screen needs is aggregated once (via [TastingStats.from])
/// rather than recomputed on every widget rebuild. Localized labels are left to
/// the presentation layer; this value object only carries numbers and raw
/// (non-localized) strings such as country names and processing methods.
class TastingStats {
  const TastingStats({
    required this.totalCoffees,
    required this.totalTastings,
    required this.avgScore,
    required this.topOrigins,
    required this.topProcessing,
    required this.flavorProfile,
    required this.timeline,
  });

  /// Total number of coffees in the user's library.
  final int totalCoffees;

  /// Total number of tastings the user has logged.
  final int totalTastings;

  /// Average `overallRating` across all tastings, or 0 when there are none.
  final double avgScore;

  /// Top 5 origin countries by coffee count, most frequent first.
  final List<StatCount> topOrigins;

  /// Top 5 processing methods by coffee count, most frequent first.
  final List<StatCount> topProcessing;

  /// Average per-dimension flavor scores, or null when there are no tastings.
  final FlavorProfile? flavorProfile;

  /// The 10 most recent tastings, newest first.
  final List<TimelineEntry> timeline;

  static const empty = TastingStats(
    totalCoffees: 0,
    totalTastings: 0,
    avgScore: 0,
    topOrigins: [],
    topProcessing: [],
    flavorProfile: null,
    timeline: [],
  );

  /// Computes the stats from the user's raw [coffees] and [tastings].
  ///
  /// [tastings] is expected to be ordered newest-first (as the repository
  /// returns it) so the timeline reflects the most recent tastings.
  factory TastingStats.from({
    required List<Coffee> coffees,
    required List<Tasting> tastings,
  }) {
    return TastingStats(
      totalCoffees: coffees.length,
      totalTastings: tastings.length,
      avgScore: _avgScore(tastings),
      topOrigins: _topEntries(
        coffees
            .where((c) => c.originCountry.isNotEmpty)
            .map((c) => c.originCountry),
      ),
      topProcessing: _topEntries(
        coffees
            .where(
              (c) =>
                  c.processingMethod != null && c.processingMethod!.isNotEmpty,
            )
            .map((c) => c.processingMethod!),
      ),
      flavorProfile: _flavorProfile(tastings),
      timeline: tastings
          .take(10)
          .map(
            (t) => TimelineEntry(
              coffeeName: t.coffeeName,
              tastingDate: t.tastingDate,
              overallRating: t.overallRating,
            ),
          )
          .toList(),
    );
  }

  static double _avgScore(List<Tasting> tastings) {
    if (tastings.isEmpty) return 0;
    final sum = tastings.fold<double>(0, (prev, t) => prev + t.overallRating);
    return sum / tastings.length;
  }

  /// Returns the top 5 entries by frequency from the given values.
  static List<StatCount> _topEntries(Iterable<String> values) {
    final counts = <String, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(5)
        .map((e) => StatCount(label: e.key, count: e.value))
        .toList();
  }

  static FlavorProfile? _flavorProfile(List<Tasting> tastings) {
    if (tastings.isEmpty) return null;
    final count = tastings.length;
    return FlavorProfile(
      aroma: tastings.fold<int>(0, (s, t) => s + t.aroma) / count,
      flavor: tastings.fold<int>(0, (s, t) => s + t.flavor) / count,
      acidity: tastings.fold<int>(0, (s, t) => s + t.acidity) / count,
      body: tastings.fold<int>(0, (s, t) => s + t.body) / count,
      sweetness: tastings.fold<int>(0, (s, t) => s + t.sweetness) / count,
      aftertaste: tastings.fold<int>(0, (s, t) => s + t.aftertaste) / count,
    );
  }
}

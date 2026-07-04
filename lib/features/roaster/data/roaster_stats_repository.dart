import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../coffee/domain/coffee.dart';
import '../../tasting/domain/tasting.dart';
import '../domain/roaster_stats.dart';

class RoasterStatsRepository {
  RoasterStatsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore caps `whereIn` at 30 values, so all coffee-id → tastings lookups
  /// batch the ids. See [_coffeeIdsForRoaster] and [_queryTastingsByCoffeeIds].
  static const int _whereInLimit = 30;

  /// Returns the document ids of every coffee that references [roasterId].
  Future<List<String>> _coffeeIdsForRoaster(String roasterId) async {
    final snapshot = await _firestore
        .collection('coffees')
        .where('roasterId', isEqualTo: roasterId)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Runs [buildQuery] once per 30-id batch of [coffeeIds] and concatenates the
  /// resulting tasting docs. [buildQuery] receives a `whereIn`-filtered query it
  /// can further constrain (date range, ordering, limit).
  Future<List<Tasting>> _queryTastingsByCoffeeIds(
    List<String> coffeeIds,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> base)
    buildQuery,
  ) async {
    final all = <Tasting>[];
    for (var i = 0; i < coffeeIds.length; i += _whereInLimit) {
      final batch = coffeeIds.sublist(
        i,
        i + _whereInLimit > coffeeIds.length
            ? coffeeIds.length
            : i + _whereInLimit,
      );
      final base = _firestore
          .collection('tastings')
          .where('coffeeId', whereIn: batch);
      final snapshot = await buildQuery(base).get();
      all.addAll(snapshot.docs.map(Tasting.fromFirestore));
    }
    return all;
  }

  /// Fetches aggregated stats for a roaster by querying all coffees
  /// that reference the given [roasterId].
  Future<RoasterStats> getStatsForRoaster(String roasterId) async {
    // 1. Get all coffees for this roaster
    final coffeesSnapshot = await _firestore
        .collection('coffees')
        .where('roasterId', isEqualTo: roasterId)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('coffees query timed out'),
        );

    final coffees = coffeesSnapshot.docs
        .map((doc) => Coffee.fromFirestore(doc))
        .toList();

    if (coffees.isEmpty) return RoasterStats.empty;

    // 2. Gather coffee IDs for tasting queries
    final coffeeIds = coffees.map((c) => c.id).toList();

    // 3. Count all tastings for these coffees (batched whereIn).
    final allTastings = await _queryTastingsByCoffeeIds(
      coffeeIds,
      (base) => base,
    );
    final totalTastings = allTastings.length;

    // 4. Compute average rating across coffees that have ratings
    final ratedCoffees = coffees.where((c) => c.ratingsCount > 0).toList();
    final ratingsCount = ratedCoffees.fold<int>(
      0,
      (acc, c) => acc + c.ratingsCount,
    );
    final avgRating = ratedCoffees.isEmpty
        ? 0.0
        : ratedCoffees.fold<double>(
                0,
                (acc, c) => acc + c.avgRating * c.ratingsCount,
              ) /
              ratingsCount;

    // 5. Top coffees by average rating (only those with at least 1 rating)
    ratedCoffees.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    final topCoffees = ratedCoffees.take(10).map((c) {
      return TopCoffeeEntry(
        name: c.name,
        avgRating: c.avgRating,
        tastingsCount: c.ratingsCount,
      );
    }).toList();

    // 6. Recent tastings (last 30 days)
    final recentTastings = await getRecentTastingCount(roasterId);

    return RoasterStats(
      totalCoffees: coffees.length,
      totalTastings: totalTastings,
      avgRating: avgRating,
      ratingsCount: ratingsCount,
      topCoffees: topCoffees,
      recentTastings: recentTastings,
    );
  }

  /// Counts tastings in the last [days] days for coffees from this roaster.
  Future<int> getRecentTastingCount(String roasterId, {int days = 30}) async {
    final coffeeIds = await _coffeeIdsForRoaster(roasterId);
    if (coffeeIds.isEmpty) return 0;

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final tastings = await _queryTastingsByCoffeeIds(
      coffeeIds,
      (base) => base.where(
        'tastingDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff),
      ),
    );
    return tastings.length;
  }

  /// Returns the most recent tastings across all of this roaster's coffees,
  /// newest first. Used by the Roaster Pro dashboard's "Dégustations" tab so
  /// the roaster can read qualitative feedback from their customers.
  Future<List<Tasting>> getRecentTastingsForRoaster(
    String roasterId, {
    int limit = 50,
  }) async {
    final coffeeIds = await _coffeeIdsForRoaster(roasterId);
    if (coffeeIds.isEmpty) return [];

    final all = await _queryTastingsByCoffeeIds(
      coffeeIds,
      (base) => base.orderBy('createdAt', descending: true).limit(limit),
    );

    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }

  /// Builds a timeseries of tastings for this roaster's coffees, bucketed by
  /// the granularity implied by [period]:
  ///   - last30Days  → daily buckets (30 points)
  ///   - last3Months → weekly buckets (~13 points)
  ///   - last12Months → monthly buckets (12 points)
  Future<List<TimeseriesPoint>> getTimeseriesForRoaster(
    String roasterId, {
    required StatsPeriod period,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final cutoff = reference.subtract(Duration(days: period.durationInDays));

    final coffeeIds = await _coffeeIdsForRoaster(roasterId);
    if (coffeeIds.isEmpty) {
      return _buildEmptyBuckets(period, reference);
    }

    final tastings = await _queryTastingsByCoffeeIds(
      coffeeIds,
      (base) => base.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff),
      ),
    );

    return _bucketize(tastings, period, reference);
  }

  List<TimeseriesPoint> _buildEmptyBuckets(StatsPeriod period, DateTime now) {
    // Keep the chart visually stable even when there are no tastings yet.
    return _bucketize(const [], period, now);
  }

  List<TimeseriesPoint> _bucketize(
    List<Tasting> tastings,
    StatsPeriod period,
    DateTime reference,
  ) {
    switch (period) {
      case StatsPeriod.last30Days:
        return _bucketsByDay(tastings, reference, 30);
      case StatsPeriod.last3Months:
        return _bucketsByWeek(tastings, reference, 13);
      case StatsPeriod.last12Months:
        return _bucketsByMonth(tastings, reference, 12);
    }
  }

  List<TimeseriesPoint> _bucketsByDay(
    List<Tasting> tastings,
    DateTime reference,
    int count,
  ) {
    final buckets = <DateTime, List<double>>{};
    for (var i = count - 1; i >= 0; i--) {
      final day = DateTime(
        reference.year,
        reference.month,
        reference.day,
      ).subtract(Duration(days: i));
      buckets[day] = [];
    }
    for (final t in tastings) {
      final day = DateTime(
        t.createdAt.year,
        t.createdAt.month,
        t.createdAt.day,
      );
      buckets[day]?.add(t.overallRating);
    }
    return buckets.entries.map(_toPoint).toList();
  }

  List<TimeseriesPoint> _bucketsByWeek(
    List<Tasting> tastings,
    DateTime reference,
    int count,
  ) {
    // Start of the week containing `reference` (Monday as first day).
    final refWeekStart = reference
        .subtract(Duration(days: reference.weekday - 1))
        .copyWithZeroTime();

    final buckets = <DateTime, List<double>>{};
    for (var i = count - 1; i >= 0; i--) {
      final weekStart = refWeekStart.subtract(Duration(days: 7 * i));
      buckets[weekStart] = [];
    }
    for (final t in tastings) {
      final weekStart = t.createdAt
          .subtract(Duration(days: t.createdAt.weekday - 1))
          .copyWithZeroTime();
      buckets[weekStart]?.add(t.overallRating);
    }
    return buckets.entries.map(_toPoint).toList();
  }

  List<TimeseriesPoint> _bucketsByMonth(
    List<Tasting> tastings,
    DateTime reference,
    int count,
  ) {
    final buckets = <DateTime, List<double>>{};
    for (var i = count - 1; i >= 0; i--) {
      final month = DateTime(reference.year, reference.month - i, 1);
      buckets[month] = [];
    }
    for (final t in tastings) {
      final month = DateTime(t.createdAt.year, t.createdAt.month, 1);
      buckets[month]?.add(t.overallRating);
    }
    return buckets.entries.map(_toPoint).toList();
  }

  TimeseriesPoint _toPoint(MapEntry<DateTime, List<double>> e) {
    final ratings = e.value;
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;
    return TimeseriesPoint(
      date: e.key,
      tastingsCount: ratings.length,
      avgRating: avg,
    );
  }

  /// Builds a CSV string of all of this roaster's coffees and their tastings
  /// for the user to export. Columns: coffee name, tasting date, overall
  /// rating, method, grind, dose, water, ratio, brew time, author.
  Future<String> buildRoasterExportCsv(String roasterId) async {
    final coffeesSnapshot = await _firestore
        .collection('coffees')
        .where('roasterId', isEqualTo: roasterId)
        .get();
    final coffees = {
      for (final doc in coffeesSnapshot.docs) doc.id: Coffee.fromFirestore(doc),
    };
    if (coffees.isEmpty) {
      return 'coffee,date,rating,method,grind,dose_g,water_ml,ratio,brew_time_sec,author\n';
    }

    final tastings = await _queryTastingsByCoffeeIds(
      coffees.keys.toList(),
      (base) => base.orderBy('createdAt', descending: true),
    );

    final buffer = StringBuffer()
      ..writeln(
        'coffee,date,rating,method,grind,dose_g,water_ml,ratio,brew_time_sec,author',
      );
    for (final t in tastings) {
      final coffee = coffees[t.coffeeId];
      final name = _csvEscape(coffee?.name ?? t.coffeeName);
      buffer.writeln(
        [
          name,
          t.tastingDate.toIso8601String(),
          t.overallRating.toStringAsFixed(2),
          _csvEscape(t.brewMethod),
          _csvEscape(t.grindSize),
          t.doseGrams,
          t.waterMl,
          _csvEscape(t.ratio),
          t.brewTimeSec,
          _csvEscape(t.authorName ?? ''),
        ].join(','),
      );
    }
    return buffer.toString();
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}

extension on DateTime {
  DateTime copyWithZeroTime() => DateTime(year, month, day);
}

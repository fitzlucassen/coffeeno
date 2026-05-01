import 'package:cloud_firestore/cloud_firestore.dart';

import '../../coffee/domain/coffee.dart';
import '../domain/roaster_stats.dart';

class RoasterStatsRepository {
  RoasterStatsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Fetches aggregated stats for a roaster by querying all coffees
  /// that reference the given [roasterId].
  Future<RoasterStats> getStatsForRoaster(String roasterId) async {
    // 1. Get all coffees for this roaster
    final coffeesSnapshot = await _firestore
        .collection('coffees')
        .where('roasterId', isEqualTo: roasterId)
        .get();

    final coffees =
        coffeesSnapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList();

    if (coffees.isEmpty) return RoasterStats.empty;

    // 2. Gather coffee IDs for tasting queries
    final coffeeIds = coffees.map((c) => c.id).toList();

    // 3. Count all tastings for these coffees (batch in groups of 30
    //    because Firestore whereIn is limited to 30 values)
    int totalTastings = 0;
    for (var i = 0; i < coffeeIds.length; i += 30) {
      final batch = coffeeIds.sublist(
        i,
        i + 30 > coffeeIds.length ? coffeeIds.length : i + 30,
      );
      final tastingsSnapshot = await _firestore
          .collection('tastings')
          .where('coffeeId', whereIn: batch)
          .count()
          .get();
      totalTastings += tastingsSnapshot.count ?? 0;
    }

    // 4. Compute average rating across coffees that have ratings
    final ratedCoffees = coffees.where((c) => c.ratingsCount > 0).toList();
    final ratingsCount =
        ratedCoffees.fold<int>(0, (acc, c) => acc + c.ratingsCount);
    final avgRating = ratedCoffees.isEmpty
        ? 0.0
        : ratedCoffees.fold<double>(
                0, (acc, c) => acc + c.avgRating * c.ratingsCount) /
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
    // First get coffee IDs for this roaster
    final coffeesSnapshot = await _firestore
        .collection('coffees')
        .where('roasterId', isEqualTo: roasterId)
        .get();

    final coffeeIds = coffeesSnapshot.docs.map((doc) => doc.id).toList();
    if (coffeeIds.isEmpty) return 0;

    final cutoff = DateTime.now().subtract(Duration(days: days));
    int count = 0;

    for (var i = 0; i < coffeeIds.length; i += 30) {
      final batch = coffeeIds.sublist(
        i,
        i + 30 > coffeeIds.length ? coffeeIds.length : i + 30,
      );
      final snapshot = await _firestore
          .collection('tastings')
          .where('coffeeId', whereIn: batch)
          .where('tastingDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
          .count()
          .get();
      count += snapshot.count ?? 0;
    }

    return count;
  }
}

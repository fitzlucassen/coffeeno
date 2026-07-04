import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/origin_stats.dart';
import '../../social/domain/leaderboard_entry.dart';

class MapRepository {
  MapRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coffees =>
      _firestore.collection('coffees');

  /// Aggregates coffees by originCountry to compute per-country stats.
  ///
  /// When [uid] is non-null, only that user's coffees are counted; otherwise
  /// the global (all-users) aggregate is returned.
  Stream<List<OriginStats>> getOriginStats({String? uid}) {
    // For the global aggregate we read the whole collection and filter
    // out missing/empty origins per-document below. A server-side
    // `isNotEqualTo: ''` filter would *also* drop docs where the field is
    // absent entirely (legacy/partial coffees), silently undercounting.
    final base = uid == null ? _coffees : _coffees.where('uid', isEqualTo: uid);
    return base.snapshots().map((snapshot) {
      final grouped = <String, _OriginAccumulator>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final country = data['originCountry'] as String?;
        if (country == null || country.isEmpty) continue;

        final acc = grouped.putIfAbsent(country, _OriginAccumulator.new);
        acc.coffeeCount++;

        // Only rated coffees contribute to the average, otherwise a never-rated
        // coffee (avgRating 0) would drag the origin's score toward zero. This
        // mirrors RoasterStatsRepository, which also averages over rated docs.
        final ratingsCount = (data['ratingsCount'] as num?)?.toInt() ?? 0;
        if (ratingsCount > 0) {
          acc.ratedCount++;
          acc.ratingSum += (data['avgRating'] as num?)?.toDouble() ?? 0;
        }
      }

      return grouped.entries.map((entry) {
        final acc = entry.value;
        final avgRating = acc.ratedCount == 0
            ? 0.0
            : acc.ratingSum / acc.ratedCount;

        return OriginStats.fromAggregation(
          country: entry.key,
          coffeeCount: acc.coffeeCount,
          avgRating: avgRating,
        );
      }).toList()..sort((a, b) => b.coffeeCount.compareTo(a.coffeeCount));
    });
  }

  // (Origin aggregation helper lives at the bottom of this file.)

  /// Queries coffees by a specific country, ordered by avgRating DESC.
  Stream<List<LeaderboardEntry>> getCoffeesByOrigin(String country) {
    return _coffees
        .where('originCountry', isEqualTo: country)
        .orderBy('avgRating', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaderboardEntry.fromFirestore(doc))
              .toList(),
        );
  }
}

/// Mutable per-country tally used while folding the coffee snapshot into
/// [OriginStats]. Tracks the total coffee count separately from the rated
/// subset so the average is computed only over coffees that have ratings.
class _OriginAccumulator {
  int coffeeCount = 0;
  int ratedCount = 0;
  double ratingSum = 0;
}

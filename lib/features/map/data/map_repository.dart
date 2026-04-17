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
  /// We fetch all coffees that have an originCountry set, group them locally,
  /// and compute count + average rating per country.
  Stream<List<OriginStats>> getOriginStats() {
    return _coffees
        .where('originCountry', isNotEqualTo: '')
        .snapshots()
        .map((snapshot) {
      final grouped = <String, List<double>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final country = data['originCountry'] as String?;
        if (country == null || country.isEmpty) continue;

        final rating = (data['avgRating'] as num?)?.toDouble() ?? 0;
        grouped.putIfAbsent(country, () => []).add(rating);
      }

      return grouped.entries.map((entry) {
        final ratings = entry.value;
        final avgRating = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;

        return OriginStats.fromAggregation(
          country: entry.key,
          coffeeCount: ratings.length,
          avgRating: avgRating,
        );
      }).toList()
        ..sort((a, b) => b.coffeeCount.compareTo(a.coffeeCount));
    });
  }

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

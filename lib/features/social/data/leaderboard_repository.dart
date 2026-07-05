import 'package:cloud_firestore/cloud_firestore.dart';

import '../../social/domain/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coffees =>
      _firestore.collection('coffees');

  /// Minimum number of ratings for the Bayesian prior weight.
  static const int _bayesianMinVotes = 3;

  /// How many candidates to pull from Firestore before applying the Bayesian
  /// sort client-side. The server orders by `avgRating` (which reuses indexes
  /// that already exist — see firestore.indexes.json), and we over-fetch a
  /// wider window so the client-side Bayesian re-rank still has enough context
  /// to surface genuinely popular coffees rather than a cluster of 1-vote 5.0s.
  /// Trimmed back to the requested limit afterwards.
  static const int _candidateMultiplier = 4;

  /// Sorts entries using a Bayesian average so that coffees with very few
  /// ratings don't dominate the leaderboard.
  ///
  /// Formula: score = (C * m + avgRating * ratingsCount) / (m + ratingsCount)
  /// where C = global average rating across the fetched set,
  ///       m = minimum votes threshold ([_bayesianMinVotes]).
  List<LeaderboardEntry> _applyBayesianSort(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) return entries;

    // Compute the global average rating C across all entries.
    final totalWeightedRating = entries.fold<double>(
      0,
      (acc, e) => acc + e.avgRating * e.ratingsCount,
    );
    final totalRatings = entries.fold<int>(0, (acc, e) => acc + e.ratingsCount);
    final double globalAvg = totalRatings > 0
        ? totalWeightedRating / totalRatings
        : 0;

    final m = _bayesianMinVotes;

    entries.sort((a, b) {
      final scoreA =
          (globalAvg * m + a.avgRating * a.ratingsCount) / (m + a.ratingsCount);
      final scoreB =
          (globalAvg * m + b.avgRating * b.ratingsCount) / (m + b.ratingsCount);
      return scoreB.compareTo(scoreA); // descending
    });

    return entries;
  }

  /// Streams the global leaderboard: coffees ranked by Bayesian average,
  /// filtered to those with at least 1 rating.
  Stream<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) {
    return _coffees
        .where('ratingsCount', isGreaterThanOrEqualTo: 1)
        // Order by avgRating (reuses the existing ratingsCount+avgRating index,
        // so no new index build is required). The Bayesian sort below produces
        // the final ranking; over-fetching via [_candidateMultiplier] keeps
        // popular coffees from being cut before the re-rank.
        .orderBy('avgRating', descending: true)
        .limit(limit * _candidateMultiplier)
        .snapshots()
        .map(
          (snapshot) => _applyBayesianSort(
            snapshot.docs
                .map((doc) => LeaderboardEntry.fromFirestore(doc))
                .toList(),
          ).take(limit).toList(),
        );
  }

  /// Streams the leaderboard for a specific origin country, ranked by
  /// Bayesian average.
  Stream<List<LeaderboardEntry>> getLeaderboardByOrigin({
    required String originCountry,
    int limit = 50,
  }) {
    return _coffees
        .where('originCountry', isEqualTo: originCountry)
        .where('ratingsCount', isGreaterThanOrEqualTo: 1)
        // Order by avgRating so this reuses the pre-existing
        // originCountry+ratingsCount+avgRating index (no new index build).
        .orderBy('avgRating', descending: true)
        .limit(limit * _candidateMultiplier)
        .snapshots()
        .map(
          (snapshot) => _applyBayesianSort(
            snapshot.docs
                .map((doc) => LeaderboardEntry.fromFirestore(doc))
                .toList(),
          ).take(limit).toList(),
        );
  }
}

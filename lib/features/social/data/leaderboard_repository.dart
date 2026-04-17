import 'package:cloud_firestore/cloud_firestore.dart';

import '../../social/domain/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coffees =>
      _firestore.collection('coffees');

  /// Streams the global leaderboard: coffees ordered by avgRating DESC,
  /// filtered to those with at least 1 rating.
  Stream<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) {
    return _coffees
        .where('ratingsCount', isGreaterThanOrEqualTo: 1)
        .orderBy('avgRating', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaderboardEntry.fromFirestore(doc))
              .toList(),
        );
  }

  /// Streams the leaderboard for a specific origin country.
  Stream<List<LeaderboardEntry>> getLeaderboardByOrigin({
    required String originCountry,
    int limit = 50,
  }) {
    return _coffees
        .where('originCountry', isEqualTo: originCountry)
        .where('ratingsCount', isGreaterThanOrEqualTo: 1)
        .orderBy('avgRating', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaderboardEntry.fromFirestore(doc))
              .toList(),
        );
  }
}

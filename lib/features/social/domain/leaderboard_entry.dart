import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.coffeeId,
    required this.coffeeName,
    required this.roasterName,
    this.photoUrl,
    required this.avgRating,
    required this.ratingsCount,
  });

  final String coffeeId;
  final String coffeeName;
  final String roasterName;
  final String? photoUrl;
  final double avgRating;
  final int ratingsCount;

  factory LeaderboardEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    // Null-tolerant casts (like Coffee.fromFirestore): a single legacy/partial
    // doc missing `name` or `avgRating` must not throw and take down the whole
    // leaderboard/origin stream — it just renders with empty/zero fallbacks.
    return LeaderboardEntry(
      coffeeId: doc.id,
      coffeeName: data['name'] as String? ?? '',
      roasterName: (data['roasterName'] ?? data['roaster'] ?? '') as String,
      photoUrl: data['photoUrl'] as String?,
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: (data['ratingsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

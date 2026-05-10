import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/roaster_post.dart';

class RoasterPostRepository {
  RoasterPostRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('roaster_posts');

  /// Creates a new post. Server-assigned document id is returned.
  Future<String> createPost(RoasterPost post) async {
    final ref = await _collection.add(post.toFirestore());
    return ref.id;
  }

  Future<void> deletePost(String postId) => _collection.doc(postId).delete();

  /// Streams posts authored for [roasterId], newest first. Includes expired
  /// posts so the roaster can see and prune their own history.
  Stream<List<RoasterPost>> watchPostsForRoaster(String roasterId) {
    return _collection
        .where('roasterId', isEqualTo: roasterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => RoasterPost.fromFirestore(doc)).toList(),
        );
  }

  /// Returns non-expired posts for any of the given [roasterIds], useful for
  /// fan-in on the consumer feed where the client already knows which
  /// roasters are relevant (from the user's library).
  ///
  /// Firestore's `whereIn` caps at 30 values; callers with more roasters
  /// should chunk the input. [limit] applies *per chunk*.
  Future<List<RoasterPost>> getActivePostsForRoasters(
    List<String> roasterIds, {
    int limit = 20,
    DateTime? now,
  }) async {
    if (roasterIds.isEmpty) return const [];
    final cutoff = now ?? DateTime.now();

    final results = <RoasterPost>[];
    for (var i = 0; i < roasterIds.length; i += 30) {
      final batch = roasterIds.sublist(
        i,
        i + 30 > roasterIds.length ? roasterIds.length : i + 30,
      );
      final snap = await _collection
          .where('roasterId', whereIn: batch)
          .where('expiresAt',
              isGreaterThan: Timestamp.fromDate(cutoff))
          .orderBy('expiresAt', descending: true)
          .limit(limit)
          .get();
      results.addAll(snap.docs.map(RoasterPost.fromFirestore));
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }
}

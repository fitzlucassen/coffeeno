import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/feed_item.dart';

class FeedRepository {
  FeedRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tastings =>
      _firestore.collection('tastings');

  /// Streams the global feed of recent tastings, paginated.
  ///
  /// For MVP we query all recent tastings ordered by createdAt DESC.
  /// Later this could use a fan-out feed collection per user.
  Stream<List<FeedItem>> getFeed({int limit = 20}) {
    return _tastings
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => FeedItem.fromFirestore(doc)).toList(),
        );
  }

  /// Adds a like from [userId] on tasting [tastingId] and increments the count.
  Future<void> likeTasting({
    required String tastingId,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    final likeRef = _tastings.doc(tastingId).collection('likes').doc(userId);
    batch.set(likeRef, {
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_tastings.doc(tastingId), {
      'likesCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Removes a like from [userId] on tasting [tastingId] and decrements the count.
  Future<void> unlikeTasting({
    required String tastingId,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    final likeRef = _tastings.doc(tastingId).collection('likes').doc(userId);
    batch.delete(likeRef);

    batch.update(_tastings.doc(tastingId), {
      'likesCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Checks whether [userId] has liked tasting [tastingId].
  Future<bool> hasUserLiked({
    required String tastingId,
    required String userId,
  }) async {
    final doc =
        await _tastings.doc(tastingId).collection('likes').doc(userId).get();
    return doc.exists;
  }

  /// Adds a comment to a tasting.
  Future<void> addComment({
    required String tastingId,
    required FeedComment comment,
  }) async {
    final batch = _firestore.batch();

    final commentRef = _tastings.doc(tastingId).collection('comments').doc();
    batch.set(commentRef, comment.toFirestore());

    batch.update(_tastings.doc(tastingId), {
      'commentsCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Streams comments for a tasting, ordered oldest-first.
  Stream<List<FeedComment>> getComments(String tastingId) {
    return _tastings
        .doc(tastingId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedComment.fromFirestore(doc))
              .toList(),
        );
  }
}

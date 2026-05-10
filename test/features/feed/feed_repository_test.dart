import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/feed/data/feed_repository.dart';
import 'package:coffeeno/features/feed/domain/feed_item.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FeedRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = FeedRepository(firestore: firestore);
  });

  test('deleteComment removes the doc and decrements commentsCount',
      () async {
    await firestore.collection('tastings').doc('t1').set({
      'commentsCount': 2,
    });
    final commentRef = await firestore
        .collection('tastings')
        .doc('t1')
        .collection('comments')
        .add({
      'authorId': 'u1',
      'authorName': 'Alice',
      'text': 'hi',
      'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
    });

    await repo.deleteComment(tastingId: 't1', commentId: commentRef.id);

    final tasting = await firestore.collection('tastings').doc('t1').get();
    expect(tasting.data()!['commentsCount'], 1);

    final comment = await firestore
        .collection('tastings')
        .doc('t1')
        .collection('comments')
        .doc(commentRef.id)
        .get();
    expect(comment.exists, isFalse);
  });

  test('addComment then deleteComment leaves counter at starting value',
      () async {
    await firestore.collection('tastings').doc('t1').set({
      'commentsCount': 0,
    });

    await repo.addComment(
      tastingId: 't1',
      comment: FeedComment(
        id: '',
        authorId: 'u1',
        authorName: 'Alice',
        text: 'hello',
        createdAt: DateTime(2026, 5, 1),
      ),
    );

    // Find the comment we just wrote.
    final comments = await firestore
        .collection('tastings')
        .doc('t1')
        .collection('comments')
        .get();
    expect(comments.docs.length, 1);

    await repo.deleteComment(
      tastingId: 't1',
      commentId: comments.docs.single.id,
    );

    final tasting = await firestore.collection('tastings').doc('t1').get();
    expect(tasting.data()!['commentsCount'], 0);
  });
}

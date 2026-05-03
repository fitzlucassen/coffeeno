import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/feed/domain/feed_item.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedItem', () {
    late FakeFirebaseFirestore firestore;

    setUp(() => firestore = FakeFirebaseFirestore());

    test('round-trips through Firestore', () async {
      final item = FeedItem(
        tastingId: '',
        authorId: 'u1',
        authorName: 'Alice',
        coffeeName: 'Sidama',
        roasterName: 'Blue Bottle',
        overallRating: 4.5,
        brewMethod: 'V60',
        likesCount: 3,
        commentsCount: 1,
        createdAt: DateTime(2026, 4, 1),
      );

      final ref = await firestore.collection('feed').add(item.toFirestore());
      final round = FeedItem.fromFirestore(await ref.get());

      expect(round.authorName, 'Alice');
      expect(round.overallRating, 4.5);
      expect(round.likesCount, 3);
    });

    test('copyWith updates counts only', () {
      final item = FeedItem(
        tastingId: 't',
        authorId: 'u',
        authorName: 'A',
        coffeeName: 'C',
        roasterName: 'R',
        overallRating: 4.0,
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(item.copyWith(likesCount: 10).likesCount, 10);
      expect(item.copyWith(commentsCount: 5).commentsCount, 5);
    });
  });

  group('FeedComment', () {
    test('round-trips through Firestore', () async {
      final firestore = FakeFirebaseFirestore();
      final comment = FeedComment(
        id: '',
        authorId: 'u1',
        authorName: 'Alice',
        text: 'Nice roast!',
        createdAt: DateTime(2026, 4, 1),
      );
      final ref = await firestore
          .collection('tastings')
          .doc('t1')
          .collection('comments')
          .add(comment.toFirestore());
      final round = FeedComment.fromFirestore(await ref.get());

      expect(round.authorName, 'Alice');
      expect(round.text, 'Nice roast!');
    });

    test('tolerates a doc with missing optional fields', () async {
      final firestore = FakeFirebaseFirestore();
      final ref = await firestore.collection('comments').add({
        'authorId': 'u1',
        'authorName': 'Alice',
        'text': 'hi',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      final round = FeedComment.fromFirestore(await ref.get());
      expect(round.authorAvatar, isNull);
    });
  });
}

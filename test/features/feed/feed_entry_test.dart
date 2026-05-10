import 'package:coffeeno/features/feed/domain/feed_entry.dart';
import 'package:coffeeno/features/feed/domain/feed_item.dart';
import 'package:coffeeno/features/roaster/domain/roaster_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedEntry.createdAt', () {
    test('TastingFeedEntry exposes the tasting\'s createdAt', () {
      final created = DateTime(2026, 5, 1);
      final entry = TastingFeedEntry(FeedItem(
        tastingId: 't1',
        authorId: 'u1',
        authorName: 'Alice',
        coffeeName: 'Sidama',
        roasterName: 'ACME',
        overallRating: 4,
        likesCount: 0,
        commentsCount: 0,
        createdAt: created,
      ));
      expect(entry.createdAt, created);
    });

    test('RoasterPostFeedEntry exposes the post\'s createdAt', () {
      final created = DateTime(2026, 5, 2);
      final entry = RoasterPostFeedEntry(RoasterPost(
        id: 'p1',
        roasterId: 'r1',
        authorUid: 'u1',
        roasterName: 'ACME',
        title: 'T',
        body: 'B',
        createdAt: created,
        expiresAt: created.add(const Duration(days: 30)),
      ));
      expect(entry.createdAt, created);
    });
  });

  test('pattern matching on FeedEntry covers both variants', () {
    final FeedEntry t = TastingFeedEntry(FeedItem(
      tastingId: 't1',
      authorId: 'u1',
      authorName: 'A',
      coffeeName: 'C',
      roasterName: 'R',
      overallRating: 4,
      likesCount: 0,
      commentsCount: 0,
      createdAt: DateTime(2026, 5, 1),
    ));
    final FeedEntry p = RoasterPostFeedEntry(RoasterPost(
      id: 'p1',
      roasterId: 'r1',
      authorUid: 'u1',
      roasterName: 'ACME',
      title: 'T',
      body: 'B',
      createdAt: DateTime(2026, 5, 2),
      expiresAt: DateTime(2026, 6, 2),
    ));

    String label(FeedEntry e) => switch (e) {
          TastingFeedEntry() => 'tasting',
          RoasterPostFeedEntry() => 'post',
        };

    expect(label(t), 'tasting');
    expect(label(p), 'post');
  });
}

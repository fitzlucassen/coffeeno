import '../../roaster/domain/roaster_post.dart';
import '../domain/feed_entry.dart';
import '../domain/feed_item.dart';

/// Pure merge logic for the unified consumer feed: interleaves tastings with
/// targeted roaster posts, drops anything authored by a blocked user, and sorts
/// by recency. Kept as a free function (no I/O) so it is trivially testable and
/// so the provider layer only wires data sources together.
List<FeedEntry> mergeFeedEntries({
  required List<FeedItem> tastings,
  required List<RoasterPost> roasterPosts,
  required Set<String> blockedUids,
}) {
  return <FeedEntry>[
    ...tastings
        .where((t) => !blockedUids.contains(t.authorId))
        .map(TastingFeedEntry.new),
    ...roasterPosts
        .where((p) => !blockedUids.contains(p.authorUid))
        .map(RoasterPostFeedEntry.new),
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

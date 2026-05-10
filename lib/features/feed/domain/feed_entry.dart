import '../../roaster/domain/roaster_post.dart';
import 'feed_item.dart';

/// A unified entry that appears in the consumer feed. Either a real user's
/// tasting (default), or a curated message from a roaster the user has
/// recently engaged with.
sealed class FeedEntry {
  const FeedEntry();

  DateTime get createdAt;
}

class TastingFeedEntry extends FeedEntry {
  const TastingFeedEntry(this.tasting);
  final FeedItem tasting;

  @override
  DateTime get createdAt => tasting.createdAt;
}

class RoasterPostFeedEntry extends FeedEntry {
  const RoasterPostFeedEntry(this.post);
  final RoasterPost post;

  @override
  DateTime get createdAt => post.createdAt;
}

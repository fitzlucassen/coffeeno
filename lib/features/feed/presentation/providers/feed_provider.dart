import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/feed_repository.dart';
import '../../domain/feed_item.dart';

/// Provides the singleton FeedRepository instance.
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// Streams the global feed of recent tastings.
final feedProvider = StreamProvider<List<FeedItem>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getFeed();
});

/// Checks whether the current user has liked a specific tasting.
///
/// Takes a record of (tastingId, userId).
final tastingLikedProvider =
    FutureProvider.family<bool, ({String tastingId, String userId})>(
  (ref, params) {
    final repository = ref.watch(feedRepositoryProvider);
    return repository.hasUserLiked(
      tastingId: params.tastingId,
      userId: params.userId,
    );
  },
);

/// Streams comments for a tasting.
final tastingCommentsProvider =
    StreamProvider.family<List<FeedComment>, String>((ref, tastingId) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getComments(tastingId);
});

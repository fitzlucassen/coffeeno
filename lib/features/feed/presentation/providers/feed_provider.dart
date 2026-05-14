import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../roaster/domain/roaster_post.dart';
import '../../../roaster/presentation/providers/roaster_post_provider.dart';
import '../../../social/presentation/providers/block_provider.dart';
import '../../data/feed_repository.dart';
import '../../domain/feed_entry.dart';
import '../../domain/feed_item.dart';

/// Provides the singleton FeedRepository instance.
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// Streams the raw tastings feed (unchanged from before). Still used by
/// [feedProvider]-based consumers; new code should use [mergedFeedProvider].
final feedProvider = StreamProvider<List<FeedItem>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getFeed();
});

/// Computes which roasters the current user has recently engaged with —
/// defined as "the user added a coffee from that roaster in the last 90
/// days". Used by [mergedFeedProvider] to target roaster posts.
final _recentlyEngagedRoastersProvider =
    FutureProvider<Set<String>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const <String>{};

  final cutoff = DateTime.now().subtract(const Duration(days: 90));
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('coffees')
        .where('uid', isEqualTo: uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .get();

    final ids = {
      for (final doc in snapshot.docs)
        if (doc.data()['roasterId'] is String)
          doc.data()['roasterId'] as String,
    };
    debugPrint(
      '[FEED] recentlyEngagedRoasters uid=$uid coffees=${snapshot.docs.length} '
      'roasterIds=${ids.length} ids=$ids',
    );
    return ids;
  } catch (e, st) {
    debugPrint('[FEED] recentlyEngagedRoasters FAILED: $e\n$st');
    rethrow;
  }
});

/// Active roaster posts relevant to the current user. Empty for signed-out
/// users or users with no recent engagement.
final _targetedRoasterPostsProvider =
    FutureProvider<List<RoasterPost>>((ref) async {
  final roasterIds = await ref.watch(_recentlyEngagedRoastersProvider.future);
  if (roasterIds.isEmpty) {
    debugPrint('[FEED] targetedRoasterPosts: no engaged roasters, returning []');
    return const <RoasterPost>[];
  }
  final repo = ref.watch(roasterPostRepositoryProvider);
  try {
    final posts = await repo.getActivePostsForRoasters(roasterIds.toList());
    debugPrint(
      '[FEED] targetedRoasterPosts roasterIds=$roasterIds posts=${posts.length}',
    );
    return posts;
  } catch (e, st) {
    debugPrint('[FEED] targetedRoasterPosts FAILED: $e\n$st');
    rethrow;
  }
});

/// Unified consumer feed: recent tastings interleaved with active
/// "Message du torréfacteur" posts from roasters the user has engaged with
/// in the last 90 days, sorted by createdAt DESC.
///
/// Roaster posts are best-effort — if that query fails (missing index,
/// permissions, offline), we still yield the tastings so the user never
/// stares at an infinite spinner because of a secondary data source.
final mergedFeedProvider = StreamProvider<List<FeedEntry>>((ref) async* {
  final tastingsStream = ref.watch(feedRepositoryProvider).getFeed();

  await for (final tastings in tastingsStream) {
    List<RoasterPost> posts;
    try {
      posts = await ref.read(_targetedRoasterPostsProvider.future);
    } catch (e) {
      debugPrint('[FEED] mergedFeed: falling back to empty roaster posts — $e');
      posts = const <RoasterPost>[];
    }
    // Re-read on every emission so updates to blocks take effect immediately.
    final blocked = ref.read(blockedUidsProvider);

    final entries = <FeedEntry>[
      ...tastings
          .where((t) => !blocked.contains(t.authorId))
          .map(TastingFeedEntry.new),
      ...posts
          .where((p) => !blocked.contains(p.authorUid))
          .map(RoasterPostFeedEntry.new),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    yield entries;
  }
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

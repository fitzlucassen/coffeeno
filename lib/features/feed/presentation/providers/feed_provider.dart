import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../roaster/domain/roaster_post.dart';
import '../../../roaster/presentation/providers/roaster_post_provider.dart';
import '../../../social/presentation/providers/block_provider.dart';
import '../../data/feed_merge.dart';
import '../../data/feed_repository.dart';
import '../../domain/feed_entry.dart';
import '../../domain/feed_item.dart';

/// Provides the singleton FeedRepository instance.
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// Computes which roasters the current user has recently engaged with —
/// defined as "the user added a coffee from that roaster in the last 90
/// days". Used by [mergedFeedProvider] to target roaster posts.
final _recentlyEngagedRoastersProvider = FutureProvider<Set<String>>((
  ref,
) async {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const <String>{};

  final cutoff = DateTime.now().subtract(const Duration(days: 90));
  final snapshot = await FirebaseFirestore.instance
      .collection('coffees')
      .where('uid', isEqualTo: uid)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
      .get();

  return {
    for (final doc in snapshot.docs)
      if (doc.data()['roasterId'] is String) doc.data()['roasterId'] as String,
  };
});

/// Active roaster posts relevant to the current user. Empty for signed-out
/// users or users with no recent engagement.
final _targetedRoasterPostsProvider = FutureProvider<List<RoasterPost>>((
  ref,
) async {
  final roasterIds = await ref.watch(_recentlyEngagedRoastersProvider.future);
  if (roasterIds.isEmpty) return const <RoasterPost>[];
  final repo = ref.watch(roasterPostRepositoryProvider);
  return repo.getActivePostsForRoasters(roasterIds.toList());
});

/// Unified consumer feed: recent tastings interleaved with active
/// "Message du torréfacteur" posts from roasters the user has engaged with
/// in the last 90 days, sorted by createdAt DESC, with blocked users removed.
///
/// Watches [blockedUidsProvider] at the top so blocking/unblocking someone
/// re-runs the merge immediately rather than only on the next tastings
/// emission. Roaster posts are best-effort — if that query fails (missing
/// index, permissions, offline), we still yield the tastings so the user never
/// stares at an infinite spinner because of a secondary data source.
final mergedFeedProvider = StreamProvider<List<FeedEntry>>((ref) async* {
  final blocked = ref.watch(blockedUidsProvider);
  final tastingsStream = ref.watch(feedRepositoryProvider).getFeed();

  await for (final tastings in tastingsStream) {
    List<RoasterPost> posts;
    try {
      posts = await ref.read(_targetedRoasterPostsProvider.future);
    } catch (e) {
      debugPrint('[FEED] mergedFeed: falling back to empty roaster posts — $e');
      posts = const <RoasterPost>[];
    }

    yield mergeFeedEntries(
      tastings: tastings,
      roasterPosts: posts,
      blockedUids: blocked,
    );
  }
});

/// Checks whether the current user has liked a specific tasting.
///
/// Takes a record of (tastingId, userId).
final tastingLikedProvider =
    FutureProvider.family<bool, ({String tastingId, String userId})>((
      ref,
      params,
    ) {
      final repository = ref.watch(feedRepositoryProvider);
      return repository.hasUserLiked(
        tastingId: params.tastingId,
        userId: params.userId,
      );
    });

/// Streams comments for a tasting.
final tastingCommentsProvider =
    StreamProvider.family<List<FeedComment>, String>((ref, tastingId) {
      final repository = ref.watch(feedRepositoryProvider);
      return repository.getComments(tastingId);
    });

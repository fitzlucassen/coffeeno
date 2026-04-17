import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/social_repository.dart';
import '../../domain/follow.dart';

/// Provides the singleton SocialRepository instance.
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository();
});

/// Checks whether [userId] is following [targetId].
final isFollowingProvider =
    FutureProvider.family<bool, ({String userId, String targetId})>(
  (ref, params) {
    final repository = ref.watch(socialRepositoryProvider);
    return repository.isFollowing(
      userId: params.userId,
      targetId: params.targetId,
    );
  },
);

/// Streams the followers of a user.
final followersProvider =
    StreamProvider.family<List<Follow>, String>((ref, userId) {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowers(userId);
});

/// Streams the users that a user is following.
final followingProvider =
    StreamProvider.family<List<Follow>, String>((ref, userId) {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowing(userId);
});

/// Streams user search results.
final userSearchResultsProvider =
    FutureProvider.family<List<UserSearchResult>, String>((ref, query) {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.searchUsers(query);
});

/// Streams a single user profile.
final userProfileProvider =
    StreamProvider.family<UserSearchResult?, String>((ref, userId) {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getUserProfileStream(userId);
});

/// Streams a user's tastings.
final userTastingsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getUserTastings(userId);
});

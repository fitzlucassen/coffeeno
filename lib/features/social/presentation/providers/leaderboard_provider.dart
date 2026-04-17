import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/leaderboard_repository.dart';
import '../../domain/leaderboard_entry.dart';

/// Provides the singleton LeaderboardRepository instance.
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

/// Streams the global leaderboard.
final globalLeaderboardProvider =
    StreamProvider<List<LeaderboardEntry>>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getGlobalLeaderboard();
});

/// Streams the leaderboard filtered by origin country.
final leaderboardByOriginProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>(
  (ref, originCountry) {
    final repository = ref.watch(leaderboardRepositoryProvider);
    return repository.getLeaderboardByOrigin(originCountry: originCountry);
  },
);

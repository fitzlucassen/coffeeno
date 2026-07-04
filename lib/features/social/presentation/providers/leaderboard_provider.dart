import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../map/presentation/providers/map_provider.dart';
import '../../data/leaderboard_repository.dart';
import '../../domain/leaderboard_entry.dart';

/// Provides the singleton LeaderboardRepository instance.
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

/// Distinct origin countries that actually appear in the global coffee corpus,
/// sorted alphabetically.
///
/// The "by origin" picker must offer exactly the values stored on coffee docs:
/// [getLeaderboardByOrigin] matches `originCountry` by strict equality, so a
/// hardcoded/canonical list (e.g. lowercase `ethiopia` vs the stored
/// `Ethiopia`) would never match. Reusing the map's aggregation keeps the two
/// features consistent and guarantees every offered country has results.
final leaderboardOriginsProvider = StreamProvider<List<String>>((ref) {
  final mapRepository = ref.watch(mapRepositoryProvider);
  return mapRepository.getOriginStats().map(
    (stats) => stats.map((s) => s.country).toList()..sort(),
  );
});

/// Streams the global leaderboard.
final globalLeaderboardProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getGlobalLeaderboard();
});

/// Streams the leaderboard filtered by origin country.
final leaderboardByOriginProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>((ref, originCountry) {
      final repository = ref.watch(leaderboardRepositoryProvider);
      return repository.getLeaderboardByOrigin(originCountry: originCountry);
    });

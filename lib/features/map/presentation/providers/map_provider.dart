import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/map_repository.dart';
import '../../domain/origin_stats.dart';
import '../../../social/domain/leaderboard_entry.dart';

/// Provides the singleton MapRepository instance.
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository();
});

/// Streams the aggregated origin statistics for the world map.
final originStatsProvider = StreamProvider<List<OriginStats>>((ref) {
  final repository = ref.watch(mapRepositoryProvider);
  return repository.getOriginStats();
});

/// Streams coffees for a specific origin country.
final coffeesByOriginProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>(
  (ref, country) {
    final repository = ref.watch(mapRepositoryProvider);
    return repository.getCoffeesByOrigin(country);
  },
);

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/map_repository.dart';
import '../../domain/origin_stats.dart';
import '../../../social/domain/leaderboard_entry.dart';

/// Provides the singleton MapRepository instance.
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository();
});

/// Which corpus of coffees the map shows. `mine` limits to the current user;
/// `global` aggregates across all users.
enum MapScope { mine, global }

class MapScopeNotifier extends Notifier<MapScope> {
  @override
  MapScope build() => MapScope.mine;

  void set(MapScope scope) => state = scope;
}

/// Currently selected map scope. Defaults to the user's own coffees so the
/// map functions as a passport; the user can switch to Global.
final mapScopeProvider =
    NotifierProvider<MapScopeNotifier, MapScope>(MapScopeNotifier.new);

/// Streams the aggregated origin statistics for the world map, honoring the
/// current [mapScopeProvider] selection.
final originStatsProvider = StreamProvider<List<OriginStats>>((ref) {
  final repository = ref.watch(mapRepositoryProvider);
  final scope = ref.watch(mapScopeProvider);
  final uid = scope == MapScope.mine
      ? FirebaseAuth.instance.currentUser?.uid
      : null;
  // Signed-out users fall through to the global feed.
  return repository.getOriginStats(uid: scope == MapScope.mine ? uid : null);
});

/// Streams coffees for a specific origin country.
final coffeesByOriginProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>(
  (ref, country) {
    final repository = ref.watch(mapRepositoryProvider);
    return repository.getCoffeesByOrigin(country);
  },
);

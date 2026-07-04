import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffeeno/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffeeno/features/stats/data/stats_repository.dart';
import 'package:coffeeno/features/stats/domain/tasting_stats.dart';

/// Provides the singleton [StatsRepository].
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});

/// Streams the current user's precomputed [TastingStats].
///
/// Resolves the uid from the auth state (rather than `FirebaseAuth.instance`)
/// so the presentation layer stays decoupled from Firebase. Emits
/// [TastingStats.empty] when no user is signed in.
final statsProvider = StreamProvider<TastingStats>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(TastingStats.empty);

  final repository = ref.watch(statsRepositoryProvider);
  return repository.watchStats(uid);
});

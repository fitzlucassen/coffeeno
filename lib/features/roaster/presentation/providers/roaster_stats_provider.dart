import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/roaster_stats_repository.dart';
import '../../domain/roaster_stats.dart';

final roasterStatsRepositoryProvider =
    Provider<RoasterStatsRepository>((ref) {
  return RoasterStatsRepository();
});

final roasterStatsProvider =
    FutureProvider.family<RoasterStats, String>((ref, roasterId) {
  final repository = ref.watch(roasterStatsRepositoryProvider);
  return repository.getStatsForRoaster(roasterId);
});

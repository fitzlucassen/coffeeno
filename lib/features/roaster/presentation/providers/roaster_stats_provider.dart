import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasting/domain/tasting.dart';
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

final roasterRecentTastingsProvider =
    FutureProvider.family<List<Tasting>, String>((ref, roasterId) {
  final repository = ref.watch(roasterStatsRepositoryProvider);
  return repository.getRecentTastingsForRoaster(roasterId);
});

/// Parameter for the timeseries provider. Families need an Equatable key.
class RoasterTimeseriesParams {
  const RoasterTimeseriesParams(this.roasterId, this.period);
  final String roasterId;
  final StatsPeriod period;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoasterTimeseriesParams &&
          other.roasterId == roasterId &&
          other.period == period;

  @override
  int get hashCode => Object.hash(roasterId, period);
}

final roasterTimeseriesProvider = FutureProvider.family<List<TimeseriesPoint>,
    RoasterTimeseriesParams>((ref, params) {
  final repository = ref.watch(roasterStatsRepositoryProvider);
  return repository.getTimeseriesForRoaster(
    params.roasterId,
    period: params.period,
  );
});

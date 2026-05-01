import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../coffee/domain/coffee.dart';
import '../../../roaster/domain/roaster.dart';
import '../../data/explore_repository.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository();
});

final trendingCoffeesProvider = FutureProvider<List<Coffee>>((ref) {
  return ref.watch(exploreRepositoryProvider).getTrendingCoffees();
});

final recentlyAddedProvider = FutureProvider<List<Coffee>>((ref) {
  return ref.watch(exploreRepositoryProvider).getRecentlyAdded();
});

final topRatedProvider = FutureProvider<List<Coffee>>((ref) {
  return ref.watch(exploreRepositoryProvider).getTopRated();
});

final newRoastersProvider = FutureProvider<List<Roaster>>((ref) {
  return ref.watch(exploreRepositoryProvider).getNewRoasters();
});

/// Fetches popular coffees from the current user's country.
/// Returns null when the user has no country set (the section is hidden).
final popularNearMeProvider = FutureProvider<List<Coffee>?>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return null;

  final country = user.country;
  if (country == null || country.isEmpty) return null;

  return ref.watch(exploreRepositoryProvider).getPopularNearMe(country);
});

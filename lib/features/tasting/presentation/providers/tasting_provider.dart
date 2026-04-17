import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/tasting_repository.dart';
import '../../domain/tasting.dart';

/// Provides the singleton [TastingRepository].
final tastingRepositoryProvider = Provider<TastingRepository>((ref) {
  return TastingRepository();
});

/// Streams tastings for a specific coffee, keyed by [coffeeId].
final coffeeTastingsProvider =
    StreamProvider.family<List<Tasting>, String>((ref, coffeeId) {
  final repository = ref.watch(tastingRepositoryProvider);
  return repository.getTastingsForCoffee(coffeeId);
});

/// Streams a user's tastings, keyed by [userId].
final userTastingsProvider =
    StreamProvider.family<List<Tasting>, String>((ref, userId) {
  final repository = ref.watch(tastingRepositoryProvider);
  return repository.getUserTastings(userId);
});

/// Fetches a single tasting by its [tastingId].
final tastingDetailProvider =
    FutureProvider.family<Tasting?, String>((ref, tastingId) {
  final repository = ref.watch(tastingRepositoryProvider);
  return repository.getTasting(tastingId);
});

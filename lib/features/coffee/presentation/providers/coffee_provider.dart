import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/coffee_enrichment_service.dart';
import '../../data/coffee_repository.dart';
import '../../domain/coffee.dart';

/// Provides the singleton [CoffeeRepository].
final coffeeRepositoryProvider = Provider<CoffeeRepository>((ref) {
  return CoffeeRepository();
});

/// Provides the singleton [CoffeeEnrichmentService].
final coffeeEnrichmentProvider = Provider<CoffeeEnrichmentService>((ref) {
  return CoffeeEnrichmentService();
});

/// Streams the current user's coffees, keyed by [userId].
final userCoffeesProvider =
    StreamProvider.family<List<Coffee>, String>((ref, userId) {
  final repository = ref.watch(coffeeRepositoryProvider);
  return repository.getUserCoffees(userId);
});

/// Fetches a single coffee by its [coffeeId].
final coffeeDetailProvider =
    FutureProvider.family<Coffee?, String>((ref, coffeeId) {
  final repository = ref.watch(coffeeRepositoryProvider);
  return repository.getCoffee(coffeeId);
});

/// Streams coffees from a specific origin [country].
final coffeesByOriginProvider =
    StreamProvider.family<List<Coffee>, String>((ref, country) {
  final repository = ref.watch(coffeeRepositoryProvider);
  return repository.getCoffeesByOrigin(country);
});

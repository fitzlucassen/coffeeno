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

/// Streams a single coffee by its [coffeeId] for real-time updates.
final coffeeDetailProvider =
    StreamProvider.family<Coffee?, String>((ref, coffeeId) {
  final repository = ref.watch(coffeeRepositoryProvider);
  return repository.watchCoffee(coffeeId);
});

/// Streams coffees from a specific origin [country].
final coffeesByOriginProvider =
    StreamProvider.family<List<Coffee>, String>((ref, country) {
  final repository = ref.watch(coffeeRepositoryProvider);
  return repository.getCoffeesByOrigin(country);
});

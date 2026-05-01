import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/freshness_notification_service.dart';
import 'coffee_provider.dart';

/// Provides the singleton [FreshnessNotificationService].
///
/// Depends on [coffeeRepositoryProvider] so the service can mark coffees
/// as notified in Firestore after scheduling.
final freshnessNotificationProvider =
    Provider<FreshnessNotificationService>((ref) {
  final coffeeRepository = ref.watch(coffeeRepositoryProvider);
  return FreshnessNotificationService(coffeeRepository: coffeeRepository);
});

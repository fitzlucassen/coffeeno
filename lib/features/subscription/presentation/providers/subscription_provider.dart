import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/subscription_repository.dart';
import '../../domain/subscription_status.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.watchStatus();
});

final isPremiumProvider = Provider<bool>((ref) {
  final status = ref.watch(subscriptionStatusProvider).value;
  return status?.isPremium ?? false;
});

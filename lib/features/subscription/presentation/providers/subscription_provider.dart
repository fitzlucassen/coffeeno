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
  final asyncStatus = ref.watch(subscriptionStatusProvider);
  return asyncStatus.when(
    data: (status) => status.isPremium,
    loading: () => true,
    error: (_, __) => false,
  );
});

final isRoasterProProvider = Provider<bool>((ref) {
  final asyncStatus = ref.watch(roasterProStatusProvider);
  return asyncStatus.when(
    data: (status) => status.isRoasterPro,
    loading: () => false,
    error: (_, __) => false,
  );
});

final roasterProStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.watchRoasterProStatus();
});

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
  final status = asyncStatus.value;
  final result = status?.isPremium ?? false;
  print('[SUB] isPremiumProvider: asyncStatus=${asyncStatus.runtimeType}, '
      'hasValue=${asyncStatus.hasValue}, tier=${status?.tier}, result=$result');
  return result;
});

final isRoasterProProvider = Provider<bool>((ref) {
  final status = ref.watch(roasterProStatusProvider).value;
  return status?.isRoasterPro ?? false;
});

final roasterProStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.watchRoasterProStatus();
});

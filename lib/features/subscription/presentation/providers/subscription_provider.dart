import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/subscription_repository.dart';
import '../../domain/subscription_status.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    return Stream.value(const SubscriptionStatus());
  }

  final controller = StreamController<SubscriptionStatus>();

  repo.loginUser(uid).then((_) {
    final stream = repo.watchStatus();
    controller.addStream(stream);
  });

  ref.onDispose(controller.close);
  return controller.stream;
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
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    return Stream.value(const SubscriptionStatus());
  }

  final controller = StreamController<SubscriptionStatus>();

  repo.loginUser(uid).then((_) {
    final stream = repo.watchRoasterProStatus();
    controller.addStream(stream);
  });

  ref.onDispose(controller.close);
  return controller.stream;
});

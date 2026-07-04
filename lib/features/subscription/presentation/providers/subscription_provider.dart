import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/subscription_repository.dart';
import '../../domain/subscription_status.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

/// Unified subscription stream — single source of truth. Emits a
/// [SubscriptionStatus] combining Pro and Roaster Pro entitlements.
///
/// Keyed on [authStateProvider] so it re-runs on login/logout rather than
/// reading a one-shot `FirebaseAuth.instance.currentUser`.
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((
  ref,
) async* {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;

  if (uid == null) {
    yield const SubscriptionStatus();
    return;
  }

  try {
    await repo.loginUser(uid);
  } catch (e) {
    debugPrint('RevenueCat loginUser failed: $e');
  }

  yield* repo.watchStatus();
});

/// True when the user has access to Pro features. Because Roaster Pro implies
/// Pro, this returns true for holders of either entitlement.
///
/// Conservative on loading/error: returns `false` so free-tier users never
/// see premium UI flicker on cold start.
final isPremiumProvider = Provider<bool>((ref) {
  final asyncStatus = ref.watch(subscriptionStatusProvider);
  return asyncStatus.maybeWhen(
    data: (status) => status.isPremium,
    orElse: () => false,
  );
});

/// True when the user has the Roaster Pro entitlement specifically.
/// A user who only has standard Pro returns `false` here.
final isRoasterProProvider = Provider<bool>((ref) {
  final asyncStatus = ref.watch(subscriptionStatusProvider);
  return asyncStatus.maybeWhen(
    data: (status) => status.isRoasterPro,
    orElse: () => false,
  );
});

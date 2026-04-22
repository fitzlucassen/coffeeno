import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/app_user.dart';
import '../../../subscription/data/subscription_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  try {
    final authRepo = ref.watch(authRepositoryProvider);
    return authRepo.authStateChanges();
  } catch (e) {
    debugPrint('Firebase not initialized, auth unavailable: $e');
    return Stream.value(null);
  }
});

final _authUidProvider = Provider<String?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;

  final subRepo = SubscriptionRepository();
  if (uid != null) {
    subRepo.loginUser(uid);
  } else {
    subRepo.logoutUser();
  }

  return uid;
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(_authUidProvider);
  if (uid == null) return Stream.value(null);

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.watchUser(uid);
});

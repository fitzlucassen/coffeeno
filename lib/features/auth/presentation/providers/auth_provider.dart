import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/app_user.dart';

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

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return null;

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUser(user.uid);
});

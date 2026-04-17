import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/app_user.dart';

/// Provides the [AuthRepository] singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provides the [UserRepository] singleton.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Streams the Firebase Auth state (signed in / signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});

/// Fetches the Firestore user document whenever the auth state changes.
///
/// Returns `null` when the user is signed out or the document does not exist.
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return null;

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUser(user.uid);
});

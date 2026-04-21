import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/claim_repository.dart';
import '../../domain/claim.dart';

final claimRepositoryProvider = Provider<ClaimRepository>((ref) {
  return ClaimRepository();
});

final pendingClaimsProvider = StreamProvider<List<Claim>>((ref) {
  final repository = ref.watch(claimRepositoryProvider);
  return repository.getPendingClaims();
});

final userClaimsProvider =
    StreamProvider.family<List<Claim>, String>((ref, userId) {
  final repository = ref.watch(claimRepositoryProvider);
  return repository.getUserClaims(userId);
});

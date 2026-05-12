import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/scan_quota_repository.dart';

final scanQuotaRepositoryProvider = Provider<ScanQuotaRepository>((ref) {
  return ScanQuotaRepository();
});

/// Remaining free scans this month for the current user. Returns
/// [kFreeMonthlyScanQuota] when signed out so the caller can still render
/// the full quota in the UI.
final remainingFreeScansProvider = FutureProvider<int>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return kFreeMonthlyScanQuota;
  return ref.watch(scanQuotaRepositoryProvider).remainingFreeScans(uid);
});

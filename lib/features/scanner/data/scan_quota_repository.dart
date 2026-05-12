import 'package:cloud_firestore/cloud_firestore.dart';

/// How many free scans a non-premium user gets per calendar month.
const int kFreeMonthlyScanQuota = 3;

/// Tracks how many coffee bag scans a free-tier user has spent this month.
///
/// State lives on the user's Firestore document so the quota follows the
/// account across devices and reinstalls. The counter auto-resets when the
/// stored [scanMonthKey] no longer matches the current month.
class ScanQuotaRepository {
  ScanQuotaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  /// The effective number of scans used this month, taking month rollover
  /// into account. Returns 0 for a new month, a signed-out user, or a user
  /// doc with no counter fields yet.
  Future<int> scansUsedThisMonth(String uid) async {
    final doc = await _userRef(uid).get();
    final data = doc.data();
    if (data == null) return 0;

    final storedKey = data['scanMonthKey'] as String?;
    if (storedKey != _currentMonthKey()) return 0;

    return (data['scansThisMonth'] as num?)?.toInt() ?? 0;
  }

  /// Remaining free scans this month for a free-tier user. Never negative.
  Future<int> remainingFreeScans(String uid) async {
    final used = await scansUsedThisMonth(uid);
    final remaining = kFreeMonthlyScanQuota - used;
    return remaining < 0 ? 0 : remaining;
  }

  /// Transactionally increments the scan counter, rolling the month over if
  /// the stored key is stale. Safe to call for premium users too — callers
  /// decide whether to record the scan at all.
  Future<void> recordScan(String uid) async {
    final ref = _userRef(uid);
    final currentKey = _currentMonthKey();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};
      final storedKey = data['scanMonthKey'] as String?;
      final current = (data['scansThisMonth'] as num?)?.toInt() ?? 0;

      final next = storedKey == currentKey ? current + 1 : 1;
      tx.set(
        ref,
        {'scansThisMonth': next, 'scanMonthKey': currentKey},
        SetOptions(merge: true),
      );
    });
  }

  String _currentMonthKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }
}

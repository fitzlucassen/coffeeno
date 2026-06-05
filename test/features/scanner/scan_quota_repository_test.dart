import 'package:coffeeno/features/scanner/data/scan_quota_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// The month key the repository uses internally, computed for "now" so tests
/// stay correct regardless of the calendar date they run on.
String _currentMonthKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ScanQuotaRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = ScanQuotaRepository(firestore: firestore);
  });

  group('scansUsedThisMonth', () {
    test('returns 0 when the user doc does not exist', () async {
      expect(await repo.scansUsedThisMonth('ghost'), 0);
    });

    test('returns 0 when the stored month key is stale', () async {
      await firestore.collection('users').doc('u').set({
        'scanMonthKey': '2000-01',
        'scansThisMonth': 2,
      });
      expect(await repo.scansUsedThisMonth('u'), 0);
    });

    test('returns the stored count for the current month', () async {
      await firestore.collection('users').doc('u').set({
        'scanMonthKey': _currentMonthKey(),
        'scansThisMonth': 2,
      });
      expect(await repo.scansUsedThisMonth('u'), 2);
    });
  });

  group('remainingFreeScans', () {
    test('returns the full quota for a fresh user', () async {
      expect(await repo.remainingFreeScans('u'), kFreeMonthlyScanQuota);
    });

    test('never goes negative when over quota', () async {
      await firestore.collection('users').doc('u').set({
        'scanMonthKey': _currentMonthKey(),
        'scansThisMonth': kFreeMonthlyScanQuota + 5,
      });
      expect(await repo.remainingFreeScans('u'), 0);
    });
  });

  group('recordScan', () {
    test('increments from zero and stamps the current month', () async {
      await repo.recordScan('u');

      final data = (await firestore.collection('users').doc('u').get()).data();
      expect(data!['scansThisMonth'], 1);
      expect(data['scanMonthKey'], _currentMonthKey());
    });

    test('accumulates across multiple scans in the same month', () async {
      await repo.recordScan('u');
      await repo.recordScan('u');
      await repo.recordScan('u');
      expect(await repo.scansUsedThisMonth('u'), 3);
    });

    test('resets the counter when the stored month is stale', () async {
      await firestore.collection('users').doc('u').set({
        'scanMonthKey': '2000-01',
        'scansThisMonth': 99,
      });

      await repo.recordScan('u');

      final data = (await firestore.collection('users').doc('u').get()).data();
      expect(data!['scansThisMonth'], 1);
      expect(data['scanMonthKey'], _currentMonthKey());
    });
  });
}

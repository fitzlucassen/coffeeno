import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/subscription_status.dart';

const _revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: 'YOUR_REVENUECAT_API_KEY',
);

const _entitlementId = 'Coffeeno Pro';
const _roasterProEntitlementId = 'Coffeeno Roaster Pro';

class SubscriptionRepository {
  SubscriptionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    if (_revenueCatApiKey == 'YOUR_REVENUECAT_API_KEY') {
      debugPrint(
        'REVENUECAT_API_KEY is not set. '
        'Pass it at build time with --dart-define=REVENUECAT_API_KEY=<key>',
      );
      return;
    }

    await Purchases.configure(
      PurchasesConfiguration(_revenueCatApiKey),
    );
    _initialized = true;
  }

  Future<void> loginUser(String uid) async {
    if (!_initialized) return;
    await Purchases.logIn(uid);
  }

  Future<void> logoutUser() async {
    if (!_initialized) return;
    try {
      await Purchases.logOut();
    } on PlatformException catch (_) {
      // RevenueCat throws if the user is already anonymous
    }
  }

  Stream<SubscriptionStatus> watchStatus() {
    if (!_initialized) {
      return _watchStatusFromFirestore();
    }

    final controller = StreamController<SubscriptionStatus>.broadcast();

    void listener(CustomerInfo info) {
      final entitlement = info.entitlements.all[_entitlementId];
      final isActive = entitlement?.isActive ?? false;
      final expirationDate = entitlement?.expirationDate != null
          ? DateTime.tryParse(entitlement!.expirationDate!)
          : null;

      debugPrint(
        '[SUB] RevenueCat status: active=$isActive, '
        'entitlementId=$_entitlementId, '
        'expiration=$expirationDate, '
        'allEntitlements=${info.entitlements.all.keys.toList()}',
      );

      controller.add(SubscriptionStatus(
        tier: isActive ? SubscriptionTier.premium : SubscriptionTier.free,
        premiumUntil: expirationDate,
      ));

      _syncToFirestore(isActive, expirationDate);
    }

    Purchases.getCustomerInfo().then(listener).catchError((e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      controller.add(const SubscriptionStatus());
    });

    Purchases.addCustomerInfoUpdateListener(listener);

    controller.onCancel = () {
      Purchases.removeCustomerInfoUpdateListener(listener);
    };

    return controller.stream;
  }

  Stream<SubscriptionStatus> _watchStatusFromFirestore() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const SubscriptionStatus());

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return const SubscriptionStatus();

      final premium = data['premium'] as bool? ?? false;
      final premiumUntil = (data['premiumUntil'] as Timestamp?)?.toDate();

      return SubscriptionStatus(
        tier: premium ? SubscriptionTier.premium : SubscriptionTier.free,
        premiumUntil: premiumUntil,
      );
    });
  }

  Future<void> _syncToFirestore(bool isPremium, DateTime? premiumUntil) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'premium': isPremium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil) : null,
    });
  }

  Future<bool> purchase() async {
    if (!_initialized) return false;

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        debugPrint('No current offering found');
        return false;
      }

      final package = offering.monthly;
      if (package == null) {
        debugPrint('No monthly package found in current offering');
        return false;
      }

      final result = await Purchases.purchase(PurchaseParams.package(package));
      final entitlement = result.customerInfo.entitlements.all[_entitlementId];

      debugPrint(
        '[SUB] purchase result: '
        'entitlement=$entitlement, '
        'isActive=${entitlement?.isActive}, '
        'allKeys=${result.customerInfo.entitlements.all.keys.toList()}',
      );

      // If purchase didn't throw, it succeeded. The entitlement might not
      // be immediately populated in the result — verify with a fresh fetch.
      if (entitlement?.isActive ?? false) return true;

      final info = await Purchases.getCustomerInfo();
      final freshEntitlement = info.entitlements.all[_entitlementId];
      return freshEntitlement?.isActive ?? false;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> restore() async {
    if (!_initialized) return false;

    final info = await Purchases.restorePurchases();
    final entitlement = info.entitlements.all[_entitlementId];
    return entitlement?.isActive ?? false;
  }

  Stream<SubscriptionStatus> watchRoasterProStatus() {
    if (!_initialized) {
      return _watchRoasterProStatusFromFirestore();
    }

    final controller = StreamController<SubscriptionStatus>.broadcast();

    void update(CustomerInfo info) {
      final entitlement = info.entitlements.all[_roasterProEntitlementId];
      final isActive = entitlement?.isActive ?? false;
      final expirationDate = entitlement?.expirationDate != null
          ? DateTime.tryParse(entitlement!.expirationDate!)
          : null;

      controller.add(SubscriptionStatus(
        roasterPro: isActive,
        roasterProUntil: expirationDate,
      ));

      _syncRoasterProToFirestore(isActive, expirationDate);
    }

    Purchases.getCustomerInfo().then(update).catchError((e) {
      debugPrint('RevenueCat getCustomerInfo error (Roaster Pro): $e');
      controller.add(const SubscriptionStatus());
    });

    Purchases.addCustomerInfoUpdateListener(update);

    controller.onCancel = () {
      Purchases.removeCustomerInfoUpdateListener(update);
    };

    return controller.stream;
  }

  Stream<SubscriptionStatus> _watchRoasterProStatusFromFirestore() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const SubscriptionStatus());

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return const SubscriptionStatus();

      final roasterPro = data['roasterPro'] as bool? ?? false;
      final roasterProUntil =
          (data['roasterProUntil'] as Timestamp?)?.toDate();

      return SubscriptionStatus(
        roasterPro: roasterPro,
        roasterProUntil: roasterProUntil,
      );
    });
  }

  Future<void> _syncRoasterProToFirestore(
      bool isRoasterPro, DateTime? roasterProUntil) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'roasterPro': isRoasterPro,
      'roasterProUntil': roasterProUntil != null
          ? Timestamp.fromDate(roasterProUntil)
          : null,
    });
  }

  Future<bool> purchaseRoasterPro() async {
    if (!_initialized) return false;

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.all['roaster_pro'];
      if (offering == null) {
        debugPrint('No roaster_pro offering found');
        return false;
      }

      final package = offering.monthly;
      if (package == null) {
        debugPrint('No monthly package found in roaster_pro offering');
        return false;
      }

      final result = await Purchases.purchase(PurchaseParams.package(package));
      final entitlement =
          result.customerInfo.entitlements.all[_roasterProEntitlementId];
      return entitlement?.isActive ?? false;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    }
  }

  Future<int> getUserCoffeeCount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final snapshot = await _firestore
        .collection('coffees')
        .where('uid', isEqualTo: uid)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getUserTastingsThisMonth() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _firestore
        .collection('tastings')
        .where('userId', isEqualTo: uid)
        .where('tastingDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}

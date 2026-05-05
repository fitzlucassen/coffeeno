import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/subscription_status.dart';
import 'subscription_constants.dart';

const _revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: 'YOUR_REVENUECAT_API_KEY',
);

/// Single source of truth for the user's subscription state.
///
/// Emits a unified [SubscriptionStatus] combining both the Pro and
/// Roaster Pro entitlements. When RevenueCat is not configured (e.g. local
/// dev without `--dart-define=REVENUECAT_API_KEY=…`), falls back to reading
/// mirrored state from the user's Firestore document.
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

  @visibleForTesting
  static void resetForTests() {
    _initialized = false;
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
      // RevenueCat throws if the user is already anonymous.
    }
  }

  /// Streams a single unified subscription status. Prefer this over calling
  /// RevenueCat or Firestore directly — all callers read the same state.
  Stream<SubscriptionStatus> watchStatus() {
    if (!_initialized) {
      return _watchFromFirestore();
    }

    final controller = StreamController<SubscriptionStatus>.broadcast();

    void listener(CustomerInfo info) {
      final status = _buildStatus(info);
      controller.add(status);
      _syncToFirestore(status);
    }

    Purchases.getCustomerInfo().then(listener).catchError((Object e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      controller.add(const SubscriptionStatus());
    });

    Purchases.addCustomerInfoUpdateListener(listener);

    controller.onCancel = () {
      Purchases.removeCustomerInfoUpdateListener(listener);
    };

    return controller.stream;
  }

  SubscriptionStatus _buildStatus(CustomerInfo info) {
    final premiumEntitlement =
        _firstActiveEntitlement(info, kPremiumEntitlementAliases);
    final roasterProEntitlement =
        _firstActiveEntitlement(info, kRoasterProEntitlementAliases);

    final premiumUntil = _parseExpiration(premiumEntitlement);
    final roasterProUntil = _parseExpiration(roasterProEntitlement);

    final hasPremium = premiumEntitlement?.isActive ?? false;
    final hasRoasterPro = roasterProEntitlement?.isActive ?? false;

    debugPrint(
      '[SUB] premium=$hasPremium roasterPro=$hasRoasterPro '
      'expirations(premium=$premiumUntil, roasterPro=$roasterProUntil)',
    );

    return SubscriptionStatus(
      tier:
          hasPremium ? SubscriptionTier.premium : SubscriptionTier.free,
      premiumUntil: premiumUntil,
      roasterPro: hasRoasterPro,
      roasterProUntil: roasterProUntil,
    );
  }

  EntitlementInfo? _firstActiveEntitlement(
    CustomerInfo info,
    List<String> aliases,
  ) {
    for (final alias in aliases) {
      final entitlement = info.entitlements.all[alias];
      if (entitlement != null) return entitlement;
    }
    return null;
  }

  DateTime? _parseExpiration(EntitlementInfo? entitlement) {
    final raw = entitlement?.expirationDate;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Stream<SubscriptionStatus> _watchFromFirestore() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const SubscriptionStatus());

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return const SubscriptionStatus();

      final now = DateTime.now();
      final premiumFlag = data['premium'] as bool? ?? false;
      final premiumUntil = (data['premiumUntil'] as Timestamp?)?.toDate();
      final roasterProFlag = data['roasterPro'] as bool? ?? false;
      final roasterProUntil =
          (data['roasterProUntil'] as Timestamp?)?.toDate();

      final premiumActive = premiumFlag &&
          (premiumUntil == null || premiumUntil.isAfter(now));
      final roasterProActive = roasterProFlag &&
          (roasterProUntil == null || roasterProUntil.isAfter(now));

      return SubscriptionStatus(
        tier: premiumActive
            ? SubscriptionTier.premium
            : SubscriptionTier.free,
        premiumUntil: premiumUntil,
        roasterPro: roasterProActive,
        roasterProUntil: roasterProUntil,
      );
    });
  }

  Future<void> _syncToFirestore(SubscriptionStatus status) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // `set` + merge rather than `update` so the call works on docs that
    // don't yet have the premium/roasterPro fields — avoids a silent
    // "not-found" when migrating existing users.
    try {
      await _firestore.collection('users').doc(uid).set({
        'premium': status.tier == SubscriptionTier.premium,
        'premiumUntil': status.premiumUntil != null
            ? Timestamp.fromDate(status.premiumUntil!)
            : null,
        'roasterPro': status.roasterPro,
        'roasterProUntil': status.roasterProUntil != null
            ? Timestamp.fromDate(status.roasterProUntil!)
            : null,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[SUB] _syncToFirestore failed: $e');
    }
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
      if (_isEitherEntitlementActive(
          result.customerInfo, kPremiumEntitlementAliases)) {
        return true;
      }

      // The entitlement may not be immediately populated in the purchase
      // result — re-fetch to be sure.
      final info = await Purchases.getCustomerInfo();
      return _isEitherEntitlementActive(info, kPremiumEntitlementAliases);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> purchaseRoasterPro() async {
    if (!_initialized) return false;

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.all[kRoasterOfferingId];
      if (offering == null) {
        debugPrint('No $kRoasterOfferingId offering found');
        return false;
      }

      final package = offering.monthly;
      if (package == null) {
        debugPrint('No monthly package found in $kRoasterOfferingId offering');
        return false;
      }

      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _isEitherEntitlementActive(
          result.customerInfo, kRoasterProEntitlementAliases);
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
    return _isEitherEntitlementActive(info, kPremiumEntitlementAliases) ||
        _isEitherEntitlementActive(info, kRoasterProEntitlementAliases);
  }

  bool _isEitherEntitlementActive(CustomerInfo info, List<String> aliases) {
    for (final alias in aliases) {
      if (info.entitlements.all[alias]?.isActive ?? false) return true;
    }
    return false;
  }
}

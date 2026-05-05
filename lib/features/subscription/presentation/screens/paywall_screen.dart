import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      // Don't trust purchase()'s boolean return value — it can report false
      // even on a successful purchase because RevenueCat's entitlement flag
      // flips active asynchronously via the customer-info update listener.
      // Instead, kick off the purchase and then wait for the provider to
      // reflect the new state.
      debugPrint('[PAYWALL] starting purchase()');
      await repo.purchase();
      debugPrint('[PAYWALL] purchase() returned, polling isPremium...');

      for (var i = 0; i < 30; i++) {
        if (ref.read(isPremiumProvider)) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      debugPrint('[PAYWALL] poll done, isPremium=${ref.read(isPremiumProvider)}');

      if (!mounted) return;
      if (ref.read(isPremiumProvider)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).premium)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.restore();

      for (var i = 0; i < 30; i++) {
        if (ref.read(isPremiumProvider)) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (ref.read(isPremiumProvider)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.premium)),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Keep the subscription stream alive for the lifetime of this screen.
    // Without this, `ref.read(isPremiumProvider)` inside `_subscribe`'s poll
    // loop reads the initial `false` and never sees the RevenueCat update
    // because Riverpod disposes a StreamProvider that has no listeners.
    ref.listen(subscriptionStatusProvider, (_, _) {});

    final features = [
      (Icons.coffee_rounded, l10n.unlimitedCoffees),
      (Icons.rate_review_rounded, l10n.unlimitedTastings),
      (Icons.auto_awesome, l10n.aiFeatures),
      (Icons.photo_camera_rounded, l10n.photoUploads),
      (Icons.share_rounded, l10n.shareCards),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.premium)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Icon(Icons.workspace_premium_rounded,
                size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.upgradeToPremium,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(l10n.premiumFeatures,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(f.$1, size: 24, color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Text(f.$2, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                )),
            const Spacer(),
            Text(l10n.premiumPrice,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _subscribe,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.subscribe),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading ? null : _restore,
              child: Text(l10n.restorePurchases),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

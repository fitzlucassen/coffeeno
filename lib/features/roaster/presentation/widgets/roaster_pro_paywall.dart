import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/features/subscription/presentation/providers/subscription_provider.dart';

/// Paywall shown when a non-Roaster-Pro user tries to open the dashboard.
/// Identical to the old inline paywall; extracted so the dashboard screen
/// itself stays short.
class RoasterProPaywall extends ConsumerStatefulWidget {
  const RoasterProPaywall({super.key, required this.roasterId});

  final String roasterId;

  @override
  ConsumerState<RoasterProPaywall> createState() => _RoasterProPaywallState();
}

class _RoasterProPaywallState extends ConsumerState<RoasterProPaywall> {
  bool _isLoading = false;

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.purchaseRoasterPro();
      for (var i = 0; i < 30; i++) {
        if (ref.read(isRoasterProProvider)) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
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
      final success = await repo.restore();
      if (mounted && !success) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error)),
        );
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

    // Keep the subscription stream alive while the paywall is on screen.
    ref.listen(subscriptionStatusProvider, (_, _) {});

    return Scaffold(
      appBar: AppBar(title: Text(l10n.roasterDashboard)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.analytics_rounded,
                size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.roasterProRequired,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.roasterProDesc,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              l10n.roasterProPrice,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
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
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

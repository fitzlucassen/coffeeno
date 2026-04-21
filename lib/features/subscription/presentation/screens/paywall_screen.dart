import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                onPressed: () {
                  // RevenueCat purchase will be wired here
                },
                child: Text(l10n.subscribe),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // RevenueCat restore will be wired here
              },
              child: Text(l10n.restorePurchases),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

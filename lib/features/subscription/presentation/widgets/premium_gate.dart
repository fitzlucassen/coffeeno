import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/router/app_router.dart';
import '../providers/subscription_provider.dart';

class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) return child;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_rounded,
                size: 48, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(l10n.premiumRequired,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.premiumRequiredDesc,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push(AppRoutes.paywall),
              child: Text(l10n.upgradeToPremium),
            ),
          ],
        ),
      ),
    );
  }
}

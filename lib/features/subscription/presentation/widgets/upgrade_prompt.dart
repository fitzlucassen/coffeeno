import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/router/app_router.dart';

void showUpgradePrompt(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
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
            Text(message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push(AppRoutes.paywall);
                },
                child: Text(l10n.upgradeToPremium),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

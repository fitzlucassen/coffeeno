import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/router/app_router.dart';
import '../providers/subscription_provider.dart';
import 'premium_upsell_content.dart';

class PremiumGate extends ConsumerWidget {
  const PremiumGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) return child;

    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: PremiumUpsellContent(
          description: l10n.premiumRequiredDesc,
          onUpgrade: () => context.push(AppRoutes.paywall),
        ),
      ),
    );
  }
}

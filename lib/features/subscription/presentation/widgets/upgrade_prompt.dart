import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/router/app_router.dart';
import 'premium_upsell_content.dart';

void showUpgradePrompt(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumUpsellContent(
              description: message,
              onUpgrade: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.paywall);
              },
              fullWidthButton: true,
              buttonSpacing: 20,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

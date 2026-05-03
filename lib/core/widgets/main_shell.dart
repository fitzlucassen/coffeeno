import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../router/app_router.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.feed)) return 0;
    if (location.startsWith(AppRoutes.explore)) return 1;
    if (location.startsWith(AppRoutes.library)) return 2;
    if (location.startsWith(AppRoutes.map)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go(AppRoutes.feed);
      case 1:
        context.go(AppRoutes.explore);
      case 2:
        context.go(AppRoutes.library);
      case 3:
        context.go(AppRoutes.map);
      case 4:
        context.go(AppRoutes.profile);
    }
  }

  void _showAddCoffeeSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    final l10n = AppLocalizations.of(context);
    final isPremium = ref.read(isPremiumProvider);

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.addCoffeeTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(l10n.scanABag),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (isPremium) {
                    context.push(AppRoutes.scan);
                  } else {
                    context.push(AppRoutes.paywall);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: Text(l10n.addManually),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(AppRoutes.addCoffee);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex(context),
        onTap: (i) => _onTabTapped(context, i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dynamic_feed_outlined),
            activeIcon: const Icon(Icons.dynamic_feed),
            label: l10n.feedTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: l10n.exploreTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.coffee_outlined),
            activeIcon: const Icon(Icons.coffee),
            label: l10n.libraryTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.mapTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profileTab,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCoffeeSheet(context, ref),
        tooltip: l10n.addCoffeeTitle,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

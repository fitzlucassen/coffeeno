import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import '../router/app_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.feed)) return 0;
    if (location.startsWith(AppRoutes.library)) return 1;
    if (location.startsWith(AppRoutes.map)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go(AppRoutes.feed);
      case 1:
        context.go(AppRoutes.library);
      case 2:
        context.go(AppRoutes.map);
      case 3:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => _onTabTapped(context, i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dynamic_feed_outlined),
            activeIcon: const Icon(Icons.dynamic_feed),
            label: l10n.feedTab,
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
        onPressed: () => context.push(AppRoutes.scan),
        tooltip: l10n.scanCoffee,
        child: const Icon(Icons.camera_alt_rounded),
      ),
    );
  }
}

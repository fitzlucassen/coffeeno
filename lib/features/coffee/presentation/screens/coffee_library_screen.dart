import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/constants/app_constants.dart';
import 'package:coffeeno/core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/freshness_notification_service.dart';
import '../providers/coffee_provider.dart';
import '../providers/freshness_notification_provider.dart';
import '../widgets/coffee_card.dart';
import '../widgets/coffee_filter_bar.dart';
import '../../domain/coffee.dart';

class CoffeeLibraryScreen extends ConsumerStatefulWidget {
  const CoffeeLibraryScreen({super.key});

  @override
  ConsumerState<CoffeeLibraryScreen> createState() =>
      _CoffeeLibraryScreenState();
}

class _CoffeeLibraryScreenState extends ConsumerState<CoffeeLibraryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCountry;
  RoastLevel? _selectedRoastLevel;
  ProcessingMethod? _selectedProcessingMethod;
  CoffeeSortOption _sortOption = CoffeeSortOption.dateAdded;
  bool _freshnessSynced = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Coffee> _filterAndSort(List<Coffee> coffees) {
    var filtered = coffees.where((coffee) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!coffee.name.toLowerCase().contains(query) &&
            !coffee.roaster.toLowerCase().contains(query)) {
          return false;
        }
      }
      // Country filter
      if (_selectedCountry != null &&
          coffee.originCountry != _selectedCountry) {
        return false;
      }
      // Roast level filter. Compare via the enum so both new (key) and legacy
      // (English label) stored values match the selected option; a coffee with
      // no roast level set never matches a specific filter.
      if (_selectedRoastLevel != null &&
          (coffee.roastLevel == null ||
              RoastLevel.fromStored(coffee.roastLevel) !=
                  _selectedRoastLevel)) {
        return false;
      }
      // Processing method filter (same key/label-tolerant comparison).
      if (_selectedProcessingMethod != null &&
          (coffee.processingMethod == null ||
              ProcessingMethod.fromStored(coffee.processingMethod) !=
                  _selectedProcessingMethod)) {
        return false;
      }
      return true;
    }).toList();

    // Sort
    switch (_sortOption) {
      case CoffeeSortOption.rating:
        filtered.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      case CoffeeSortOption.dateAdded:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case CoffeeSortOption.name:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final coffeesAsync = ref.watch(userCoffeesProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myCoffees)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addCoffee),
        tooltip: l10n.addCoffee,
        child: const Icon(Icons.add),
      ),
      body: coffeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          debugPrint('[COFFEENO] Library error: $error');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.error,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        data: (coffees) {
          // Schedule freshness notifications for any coffee that needs one.
          if (!_freshnessSynced) {
            _freshnessSynced = true;
            final notificationTitle = l10n.freshnessNotificationTitle;
            final notificationService = ref.read(freshnessNotificationProvider);
            notificationService.init().then((_) {
              notificationService
                  .rescheduleAll(
                    coffees,
                    title: notificationTitle,
                    body: (c) => freshnessNotificationBody(l10n, c),
                  )
                  .catchError((e) {
                    debugPrint('[COFFEENO] Freshness reschedule failed: $e');
                  });
            });
          }

          // Collect available countries for filter
          final countries =
              coffees
                  .map((c) => c.originCountry)
                  .where((c) => c.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

          final filtered = _filterAndSort(coffees);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '${l10n.search}...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 4),

              // Filter bar
              CoffeeFilterBar(
                selectedCountry: _selectedCountry,
                selectedRoastLevel: _selectedRoastLevel,
                selectedProcessingMethod: _selectedProcessingMethod,
                selectedSort: _sortOption,
                availableCountries: countries,
                onCountryChanged: (v) => setState(() => _selectedCountry = v),
                onRoastLevelChanged: (v) =>
                    setState(() => _selectedRoastLevel = v),
                onProcessingMethodChanged: (v) =>
                    setState(() => _selectedProcessingMethod = v),
                onSortChanged: (v) => setState(() => _sortOption = v),
              ),
              const SizedBox(height: 8),

              // Coffee grid or empty state
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(
                        hasFilters:
                            _searchQuery.isNotEmpty ||
                            _selectedCountry != null ||
                            _selectedRoastLevel != null ||
                            _selectedProcessingMethod != null,
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            CoffeeCard(coffee: filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.hasFilters = false});
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.coffee_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching coffees' : l10n.noCoffeesYet,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters'
                  : l10n.noCoffeesYetSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

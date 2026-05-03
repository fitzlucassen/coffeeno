import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:coffeeno/core/widgets/app_card.dart';
import 'package:coffeeno/features/subscription/presentation/providers/subscription_provider.dart';
import '../providers/roaster_provider.dart';
import '../providers/roaster_stats_provider.dart';

class RoasterDashboardScreen extends ConsumerWidget {
  const RoasterDashboardScreen({super.key, required this.roasterId});

  final String roasterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isRoasterPro = ref.watch(isRoasterProProvider);

    if (!isRoasterPro) {
      return _RoasterProPaywall(roasterId: roasterId);
    }

    final roasterAsync = ref.watch(roasterDetailProvider(roasterId));
    final statsAsync = ref.watch(roasterStatsProvider(roasterId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roasterDashboard),
      ),
      body: roasterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.error)),
        data: (roaster) {
          if (roaster == null) return Center(child: Text(l10n.error));

          return statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.error)),
            data: (stats) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(roasterStatsProvider(roasterId));
                },
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Roaster name header
                    Text(
                      roaster.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

                    // Stats grid
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.coffee_rounded,
                            label: l10n.totalCoffees,
                            value: stats.totalCoffees.toString(),
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.rate_review_rounded,
                            label: l10n.totalTastings,
                            value: stats.totalTastings.toString(),
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_rounded,
                            label: l10n.avgScore,
                            value: stats.ratingsCount > 0
                                ? stats.avgRating.toStringAsFixed(1)
                                : '-',
                            color: colorScheme.secondary,
                            subtitle: stats.ratingsCount > 0
                                ? l10n.ratingsCount(stats.ratingsCount)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up_rounded,
                            label: l10n.recentTastings30d,
                            value: stats.recentTastings.toString(),
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Top coffees section
                    if (stats.topCoffees.isNotEmpty) ...[
                      Text(
                        l10n.topCoffeesByRating,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...stats.topCoffees.map((coffee) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.coffee_rounded,
                                      size: 20,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          coffee.name,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          l10n.tastingsCount(
                                              coffee.tastingsCount),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star_rounded,
                                          size: 18,
                                          color: colorScheme.secondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        coffee.avgRating.toStringAsFixed(1),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoasterProPaywall extends ConsumerStatefulWidget {
  const _RoasterProPaywall({required this.roasterId});

  final String roasterId;

  @override
  ConsumerState<_RoasterProPaywall> createState() =>
      _RoasterProPaywallState();
}

class _RoasterProPaywallState extends ConsumerState<_RoasterProPaywall> {
  bool _isLoading = false;

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final success = await repo.purchaseRoasterPro();
      if (success && mounted) {
        ref.invalidate(roasterProStatusProvider);
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
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (!success) {
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.roasterDashboard)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.analytics_rounded, size: 64, color: colorScheme.primary),
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

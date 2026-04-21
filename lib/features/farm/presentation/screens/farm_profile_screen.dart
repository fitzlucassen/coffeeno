import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:coffeeno/core/widgets/app_card.dart';
import 'package:coffeeno/features/coffee/domain/coffee.dart';
import 'package:coffeeno/features/coffee/presentation/providers/coffee_provider.dart';
import 'package:coffeeno/features/auth/presentation/providers/auth_provider.dart';
import '../providers/farm_provider.dart';

class FarmProfileScreen extends ConsumerWidget {
  const FarmProfileScreen({super.key, required this.farmId});

  final String farmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final farmAsync = ref.watch(farmDetailProvider(farmId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.farmProfile)),
      body: farmAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.error)),
        data: (farm) {
          if (farm == null) return Center(child: Text(l10n.error));

          final coffeeRepo = ref.watch(coffeeRepositoryProvider);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo + name header
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: farm.photoUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: farm.photoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: colorScheme.secondaryContainer,
                                      child: Icon(Icons.agriculture_rounded,
                                          size: 40,
                                          color: colorScheme
                                              .onSecondaryContainer
                                              .withValues(alpha: 0.5)),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(farm.name,
                                          style:
                                              theme.textTheme.headlineSmall),
                                    ),
                                    if (farm.claimStatus == 'approved')
                                      Chip(
                                        label: Text(l10n.approvedClaim),
                                        avatar: Icon(Icons.verified,
                                            size: 16,
                                            color: colorScheme.primary),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                                if (farm.country != null ||
                                    farm.region != null)
                                  Text(
                                    [farm.region, farm.country]
                                        .where((s) => s != null && s.isNotEmpty)
                                        .join(', '),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      if (farm.description != null) ...[
                        AppCard(
                          child: Text(farm.description!,
                              style: theme.textTheme.bodyMedium),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Farmer + altitude info
                      if (farm.farmerName != null ||
                          farm.altitude != null) ...[
                        AppCard(
                          child: Column(
                            children: [
                              if (farm.farmerName != null)
                                _InfoRow(
                                  icon: Icons.person_rounded,
                                  label: l10n.farmerName,
                                  value: farm.farmerName!,
                                  theme: theme,
                                ),
                              if (farm.altitude != null)
                                _InfoRow(
                                  icon: Icons.terrain_rounded,
                                  label: l10n.altitude,
                                  value: farm.altitude!,
                                  theme: theme,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Website
                      if (farm.url != null) ...[
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse(farm.url!),
                              mode: LaunchMode.externalApplication),
                          child: AppCard(
                            child: Row(
                              children: [
                                Icon(Icons.language,
                                    size: 20, color: colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.visitWebsite,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Icon(Icons.open_in_new,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Claim / Edit actions
                      Builder(builder: (context) {
                        final currentUser =
                            ref.watch(currentUserProvider).valueOrNull;
                        if (currentUser == null) return const SizedBox.shrink();

                        final isOwner =
                            farm.claimedBy == currentUser.uid;
                        final isAdmin = currentUser.isAdmin;

                        if (isOwner || isAdmin) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.push('/farm/$farmId/edit'),
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(l10n.editProfileInfo),
                            ),
                          );
                        }

                        if (farm.claimStatus == 'pending') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Chip(
                              label: Text(l10n.pendingClaim),
                              avatar: Icon(Icons.hourglass_top,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          );
                        }

                        if (farm.claimedBy == null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/claim/farm/$farmId?name=${Uri.encodeComponent(farm.name)}',
                              ),
                              icon: const Icon(Icons.verified_outlined,
                                  size: 18),
                              label: Text(l10n.claimProfile),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      }),

                      // Coffees section
                      Text(l10n.coffeesFromFarm(farm.name),
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Coffees list
              StreamBuilder<List<Coffee>>(
                stream: coffeeRepo.getCoffeesForFarm(farmId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final coffees = snapshot.data ?? [];
                  if (coffees.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(l10n.noCoffeesFromOrigin,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final coffee = coffees[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          child: Card(
                            child: ListTile(
                              onTap: () =>
                                  context.push('/coffee/${coffee.id}'),
                              leading: CircleAvatar(
                                backgroundColor:
                                    colorScheme.primaryContainer,
                                child: Icon(Icons.coffee_rounded,
                                    color:
                                        colorScheme.onPrimaryContainer),
                              ),
                              title: Text(coffee.name),
                              subtitle: Text(coffee.roaster),
                            ),
                          ),
                        );
                      },
                      childCount: coffees.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

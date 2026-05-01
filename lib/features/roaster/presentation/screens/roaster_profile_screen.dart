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
import '../providers/roaster_provider.dart';

class RoasterProfileScreen extends ConsumerWidget {
  const RoasterProfileScreen({super.key, required this.roasterId});

  final String roasterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final roasterAsync = ref.watch(roasterDetailProvider(roasterId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.roasterProfile)),
      body: roasterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.error)),
        data: (roaster) {
          if (roaster == null) return Center(child: Text(l10n.error));

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
                              child: roaster.photoUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: roaster.photoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: colorScheme.secondaryContainer,
                                      child: Icon(Icons.store_rounded,
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
                                      child: Text(roaster.name,
                                          style:
                                              theme.textTheme.headlineSmall),
                                    ),
                                    if (roaster.claimStatus == 'approved')
                                      Chip(
                                        label: Text(l10n.approvedClaim),
                                        avatar: Icon(Icons.verified,
                                            size: 16,
                                            color: colorScheme.primary),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                                if (roaster.country != null ||
                                    roaster.city != null)
                                  Text(
                                    [roaster.city, roaster.country]
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
                      if (roaster.description != null) ...[
                        AppCard(
                          child: Text(roaster.description!,
                              style: theme.textTheme.bodyMedium),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Key people
                      if (roaster.keyPeople != null &&
                          roaster.keyPeople!.isNotEmpty) ...[
                        Text(l10n.keyPeople,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        AppCard(
                          child: Row(
                            children: [
                              Icon(Icons.people_outline,
                                  size: 20, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(roaster.keyPeople!,
                                    style: theme.textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Website
                      if (roaster.url != null) ...[
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse(roaster.url!),
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
                            ref.watch(currentUserProvider).value;
                        if (currentUser == null) return const SizedBox.shrink();

                        final isOwner =
                            roaster.claimedBy == currentUser.uid;
                        final isAdmin = currentUser.isAdmin;

                        if (isOwner || isAdmin) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push('/roaster/$roasterId/edit'),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: Text(l10n.editProfileInfo),
                                ),
                                if (isOwner)
                                  FilledButton.icon(
                                    onPressed: () => context.push(
                                        '/roaster/$roasterId/dashboard'),
                                    icon: const Icon(
                                        Icons.analytics_rounded, size: 18),
                                    label: Text(l10n.roasterDashboard),
                                  ),
                              ],
                            ),
                          );
                        }

                        if (roaster.claimStatus == 'pending') {
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

                        if (roaster.claimedBy == null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/claim/roaster/$roasterId?name=${Uri.encodeComponent(roaster.name)}',
                              ),
                              icon: const Icon(Icons.verified_outlined,
                                  size: 18),
                              label: Text(l10n.claimProfile),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      }),

                      // Coffees section title
                      Text(l10n.coffeesFromRoaster(roaster.name),
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Coffees list
              StreamBuilder<List<Coffee>>(
                stream: coffeeRepo.getCoffeesForRoaster(roasterId),
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
                              subtitle: Text(coffee.originCountry),
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

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:coffeeno/core/router/app_router.dart';
import 'package:coffeeno/core/widgets/app_card.dart';
import 'package:coffeeno/core/widgets/app_button.dart';
import 'package:coffeeno/core/widgets/coffee_score_badge.dart';
import 'package:coffeeno/core/widgets/star_rating.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/coffee_provider.dart';
import '../providers/freshness_notification_provider.dart';
import '../widgets/coffee_metadata_section.dart';
import '../../../tasting/presentation/providers/tasting_provider.dart';

class CoffeeDetailScreen extends ConsumerWidget {
  const CoffeeDetailScreen({super.key, required this.coffeeId});

  final String coffeeId;

  Future<void> _deleteCoffee(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteCoffeeConfirm),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text(l10n.delete,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Cancel any pending freshness notification before deleting.
    final notificationService = ref.read(freshnessNotificationProvider);
    await notificationService.init();
    await notificationService.cancelForCoffee(coffeeId);

    final repository = ref.read(coffeeRepositoryProvider);
    await repository.deleteCoffee(coffeeId);
    if (context.mounted) context.go(AppRoutes.library);
  }

  Future<void> _updatePhoto(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final file = File(image.path);
      final fileName = '${const Uuid().v4()}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref('users/$userId/coffees/$fileName');
      await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final photoUrl = await storageRef.getDownloadURL();

      final repository = ref.read(coffeeRepositoryProvider);
      final coffee = await repository.getCoffee(coffeeId);
      if (coffee != null) {
        await repository.updateCoffee(coffee.copyWith(photoUrl: photoUrl));
        ref.invalidate(coffeeDetailProvider(coffeeId));
      }
    } catch (e) {
      debugPrint('[COFFEENO] Photo update failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final coffeeAsync = ref.watch(coffeeDetailProvider(coffeeId));
    final tastingsAsync = ref.watch(coffeeTastingsProvider(coffeeId));

    return Scaffold(
      body: coffeeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.error)),
        data: (coffee) {
          if (coffee == null) {
            return Center(child: Text(l10n.error));
          }

          return CustomScrollView(
            slivers: [
              // Hero image
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                actions: [
                  if (ref.watch(isPremiumProvider))
                    IconButton(
                      icon: const Icon(Icons.add_a_photo_outlined),
                      tooltip: 'Update photo',
                      onPressed: () => _updatePhoto(context, ref),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: l10n.delete,
                    onPressed: () => _deleteCoffee(context, ref),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: ref.watch(isPremiumProvider)
                        ? () => _updatePhoto(context, ref)
                        : null,
                    child: coffee.photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: coffee.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                _ImagePlaceholder(colorScheme),
                            errorWidget: (_, _, _) =>
                                _ImagePlaceholder(colorScheme),
                          )
                        : _ImagePlaceholder(colorScheme),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + score badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coffee.name,
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  coffee.roaster,
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (coffee.ratingsCount > 0) ...[
                            const SizedBox(width: 16),
                            Column(
                              children: [
                                CoffeeScoreBadge(
                                  score: coffee.avgRating,
                                  size: CoffeeScoreBadgeSize.large,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.ratingsCount(coffee.ratingsCount),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Metadata section
                      CoffeeMetadataSection(coffee: coffee),
                      const SizedBox(height: 20),

                      // Community rating
                      _CommunityRatingSection(
                        roaster: coffee.roaster,
                        name: coffee.name,
                      ),

                      // Flavor notes
                      if (coffee.flavorNotes.isNotEmpty) ...[
                        Text(
                          l10n.flavorNotes,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: coffee.flavorNotes
                              .map((note) => Chip(label: Text(note)))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Roaster info
                      if (coffee.roasterId != null) ...[
                        Text(l10n.aboutRoaster,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context
                              .push('/roaster/${coffee.roasterId}'),
                          child: AppCard(
                            child: Row(
                              children: [
                                Icon(Icons.store_rounded,
                                    size: 20, color: colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    coffee.roaster,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else if (coffee.roasterDescription != null) ...[
                        Text(l10n.aboutRoaster,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(coffee.roasterDescription!,
                                  style: theme.textTheme.bodyMedium),
                              if (coffee.roasterUrl != null) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => launchUrl(
                                      Uri.parse(coffee.roasterUrl!),
                                      mode: LaunchMode.externalApplication),
                                  child: Text(
                                    l10n.visitWebsite,
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else if (coffee.roaster.isNotEmpty) ...[
                        Text(l10n.aboutRoaster,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        AppCard(
                          child: Row(
                            children: [
                              Icon(Icons.store_rounded,
                                  size: 20, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(coffee.roaster,
                                  style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Farm info
                      if (coffee.farmId != null) ...[
                        Text(l10n.aboutFarm,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () =>
                              context.push('/farm/${coffee.farmId}'),
                          child: AppCard(
                            child: Row(
                              children: [
                                Icon(Icons.agriculture_rounded,
                                    size: 20, color: colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    coffee.farmName ?? coffee.originRegion ?? l10n.aboutFarm,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else if (coffee.farmDescription != null) ...[
                        Text(l10n.aboutFarm,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(coffee.farmDescription!,
                                  style: theme.textTheme.bodyMedium),
                              if (coffee.farmUrl != null) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => launchUrl(
                                      Uri.parse(coffee.farmUrl!),
                                      mode: LaunchMode.externalApplication),
                                  child: Text(
                                    l10n.visitWebsite,
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Add Tasting button
                      AppButton(
                        label: l10n.addTasting,
                        icon: Icons.rate_review_rounded,
                        onPressed: () =>
                            context.push('/tasting/add/${coffee.id}'),
                      ),
                      const SizedBox(height: 32),

                      // Tastings section
                      Text(
                        l10n.tastings,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Tastings list
              tastingsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => SliverToBoxAdapter(
                  child: Center(child: Text(l10n.error)),
                ),
                data: (tastings) {
                  if (tastings.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Icon(
                              Icons.rate_review_outlined,
                              size: 48,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noTastingsYet,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              l10n.noTastingsYetSubtitle,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tasting = tastings[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          child: Card(
                            child: ListTile(
                              onTap: () =>
                                  context.push('/tasting/${tasting.id}'),
                              leading: CircleAvatar(
                                backgroundColor:
                                    colorScheme.primaryContainer,
                                child: Text(
                                  tasting.overallRating.toStringAsFixed(1),
                                  style:
                                      theme.textTheme.labelMedium?.copyWith(
                                    color:
                                        colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(tasting.brewMethod),
                              subtitle: Text(
                                DateFormat.yMMMd()
                                    .format(tasting.tastingDate),
                              ),
                              trailing: StarRating(
                                rating: tasting.overallRating,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: tastings.length,
                    ),
                  );
                },
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _CommunityRatingSection extends ConsumerWidget {
  const _CommunityRatingSection({
    required this.roaster,
    required this.name,
  });

  final String roaster;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final ratingAsync = ref.watch(
      communityRatingProvider((roaster: roaster, name: name)),
    );

    return ratingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (result) {
        if (result == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.communityRating,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            AppCard(
              child: Row(
                children: [
                  Icon(Icons.people_rounded,
                      size: 20, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  StarRating(rating: result.average, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.communityRatingValue(
                      result.average.toStringAsFixed(1),
                      result.count,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder(this.colorScheme);
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Icons.coffee_rounded,
          size: 80,
          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

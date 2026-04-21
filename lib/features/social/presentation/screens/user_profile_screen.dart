import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:coffeeno/core/widgets/star_rating.dart';
import 'package:coffeeno/core/router/app_router.dart';
import 'package:coffeeno/features/social/presentation/providers/social_provider.dart';
import 'package:coffeeno/features/social/presentation/widgets/follow_button.dart';
import 'package:coffeeno/features/social/presentation/widgets/user_avatar.dart';

void _showSettingsSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final colorScheme = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(l10n.signOut,
                style: TextStyle(color: colorScheme.error)),
            onTap: () async {
              Navigator.of(ctx).pop();
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    final profileUserId = userId ?? firebaseUser?.uid;
    final isOwnProfile =
        userId == null || profileUserId == firebaseUser?.uid;

    if (profileUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileTab)),
        body: Center(
          child: Text(l10n.error, style: textTheme.bodyLarge),
        ),
      );
    }

    final profileAsync = ref.watch(userProfileProvider(profileUserId));
    final tastingsAsync = ref.watch(userTastingsProvider(profileUserId));

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? l10n.profileTab : ''),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n.settings,
                  onPressed: () => _showSettingsSheet(context),
                ),
              ]
            : null,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text(
                l10n.userNotFound,
                style: textTheme.bodyLarge,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProfileProvider(profileUserId));
              ref.invalidate(userTastingsProvider(profileUserId));
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                const SizedBox(height: 16),

                Center(
                  child: UserAvatar(
                    imageUrl: profile.avatarUrl,
                    displayName: profile.displayName,
                    size: UserAvatarSize.large,
                  ),
                ),
                const SizedBox(height: 12),

                Center(
                  child: Text(
                    profile.displayName,
                    style: textTheme.headlineSmall,
                  ),
                ),

                if (profile.username != null &&
                    profile.username!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Center(
                    child: Text(
                      '@${profile.username}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],

                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      profile.bio!,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                _StatsRow(
                  userId: profileUserId,
                  tastingsCount: profile.tastingsCount,
                  followersCount: profile.followersCount,
                  followingCount: profile.followingCount,
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: isOwnProfile
                      ? _OwnProfileActions(l10n: l10n)
                      : Center(
                          child:
                              FollowButton(targetUserId: profileUserId),
                        ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(l10n.tastings, style: textTheme.titleMedium),
                ),
                const SizedBox(height: 8),

                tastingsAsync.when(
                  data: (tastings) {
                    if (tastings.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            l10n.noTastingsYet,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: tastings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tasting = tastings[index];
                        return _TastingTile(
                          tasting: tasting,
                          onTap: () {
                            final id = tasting['id'] as String;
                            context.push('/tasting/$id');
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, __) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: SelectableText(
                        error.toString(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              error.toString(),
              style: textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.userId,
    required this.tastingsCount,
    required this.followersCount,
    required this.followingCount,
  });

  final String userId;
  final int tastingsCount;
  final int followersCount;
  final int followingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatItem(
          count: tastingsCount,
          label: l10n.tastings,
        ),
        Container(
          width: 1,
          height: 32,
          color: colorScheme.outlineVariant,
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
        _StatItem(
          count: followersCount,
          label: l10n.followers,
          onTap: () => context.push('/user/$userId/followers'),
        ),
        Container(
          width: 1,
          height: 32,
          color: colorScheme.outlineVariant,
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
        _StatItem(
          count: followingCount,
          label: l10n.following,
          onTap: () => context.push('/user/$userId/following'),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.count,
    required this.label,
    this.onTap,
  });

  final int count;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelSmall,
        ),
      ],
    );

    if (onTap == null) return child;

    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}

class _OwnProfileActions extends StatelessWidget {
  const _OwnProfileActions({
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.editProfile),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.editProfile, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.stats),
            icon: const Icon(Icons.insights_rounded, size: 18),
            label: Text(l10n.statsTab, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _TastingTile extends StatelessWidget {
  const _TastingTile({
    required this.tasting,
    this.onTap,
  });

  final Map<String, dynamic> tasting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final coffeeName = tasting['coffeeName'] as String? ?? 'Unknown Coffee';
    final roasterName = tasting['roasterName'] as String? ?? '';
    final overallRating = (tasting['overallRating'] as num?)?.toDouble() ?? 0;
    final brewMethod = tasting['brewMethod'] as String?;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffeeName,
                      style: textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (roasterName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        roasterName,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (brewMethod != null && brewMethod.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        brewMethod,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StarRating(rating: overallRating, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

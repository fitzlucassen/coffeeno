import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/features/social/presentation/providers/social_provider.dart';
import 'package:coffeeno/features/social/presentation/widgets/follow_button.dart';
import 'package:coffeeno/features/social/presentation/widgets/user_avatar.dart';

/// Shows the followers or following list for a given user.
class FollowersScreen extends ConsumerWidget {
  const FollowersScreen({
    super.key,
    required this.userId,
    required this.showFollowers,
  });

  final String userId;
  final bool showFollowers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = showFollowers ? l10n.followers : l10n.following;
    final listAsync = showFollowers
        ? ref.watch(followersProvider(userId))
        : ref.watch(followingProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: listAsync.when(
        data: (follows) {
          if (follows.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    showFollowers
                        ? l10n.noFollowersYet
                        : l10n.notFollowingAnyone,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: follows.length,
            itemBuilder: (context, index) {
              final follow = follows[index];
              return _FollowUserTile(
                userId: follow.userId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            l10n.error,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          ),
        ),
      ),
    );
  }
}

/// A single tile in the followers/following list that fetches the user profile
/// and displays their avatar, name, and a follow button.
class _FollowUserTile extends ConsumerWidget {
  const _FollowUserTile({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final profileAsync = ref.watch(userProfileProvider(userId));

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 4,
          ),
          leading: UserAvatar(
            imageUrl: profile.avatarUrl,
            displayName: profile.displayName,
          ),
          title: Text(
            profile.displayName,
            style: textTheme.titleSmall,
          ),
          subtitle: profile.username != null && profile.username!.isNotEmpty
              ? Text(
                  '@${profile.username}',
                  style: textTheme.bodySmall,
                )
              : null,
          trailing: FollowButton(
            targetUserId: userId,
            compact: true,
          ),
          onTap: () => context.push('/user/$userId'),
        );
      },
      loading: () => const ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: CircleAvatar(radius: 20),
        title: SizedBox(
          height: 14,
          width: 100,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

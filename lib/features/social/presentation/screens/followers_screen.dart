import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/widgets/empty_state_view.dart';
import 'package:coffeeno/core/widgets/error_retry_view.dart';
import 'package:coffeeno/features/social/presentation/providers/social_provider.dart';
import 'package:coffeeno/features/social/presentation/widgets/user_list_tile.dart';

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

    final title = showFollowers ? l10n.followers : l10n.following;
    final listAsync = showFollowers
        ? ref.watch(followersProvider(userId))
        : ref.watch(followingProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: listAsync.when(
        data: (follows) {
          if (follows.isEmpty) {
            return EmptyStateView(
              icon: Icons.people_outline,
              message: showFollowers
                  ? l10n.noFollowersYet
                  : l10n.notFollowingAnyone,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: follows.length,
            itemBuilder: (context, index) {
              final follow = follows[index];
              return _FollowUserTile(userId: follow.userId);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const ErrorRetryView(),
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
    final profileAsync = ref.watch(userProfileProvider(userId));

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        return UserListTile(
          userId: userId,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
          username: profile.username,
        );
      },
      loading: () => const ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: CircleAvatar(radius: 20),
        title: SizedBox(height: 14, width: 100),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

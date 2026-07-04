import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/features/social/presentation/widgets/follow_button.dart';
import 'package:coffeeno/features/social/presentation/widgets/user_avatar.dart';

/// A single user row showing their avatar, display name and `@username`, with a
/// compact follow button and navigation to their profile.
///
/// Shared by the followers/following list and the user search results, which
/// previously duplicated this exact structure.
class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.username,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? username;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: UserAvatar(imageUrl: avatarUrl, displayName: displayName),
      title: Text(displayName, style: textTheme.titleSmall),
      subtitle: username != null && username!.isNotEmpty
          ? Text('@$username', style: textTheme.bodySmall)
          : null,
      trailing: FollowButton(targetUserId: userId, compact: true),
      onTap: () => context.push('/user/$userId'),
    );
  }
}

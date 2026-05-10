import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../providers/block_provider.dart';
import '../providers/social_provider.dart';
import '../widgets/user_avatar.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final blockedIds = ref.watch(outgoingBlocksProvider).value ?? const {};
    final actor = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.blockedUsers)),
      body: blockedIds.isEmpty
          ? Center(
              child: Text(
                l10n.noBlockedUsers,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView(
              children: [
                for (final uid in blockedIds)
                  _BlockedUserTile(
                    uid: uid,
                    onUnblock: actor == null
                        ? null
                        : () => ref
                            .read(blockRepositoryProvider)
                            .unblock(actor: actor, target: uid),
                    l10n: l10n,
                  ),
              ],
            ),
    );
  }
}

class _BlockedUserTile extends ConsumerWidget {
  const _BlockedUserTile({
    required this.uid,
    required this.onUnblock,
    required this.l10n,
  });

  final String uid;
  final Future<void> Function()? onUnblock;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(uid));

    return profileAsync.when(
      loading: () => const ListTile(
        title: LinearProgressIndicator(),
      ),
      error: (_, _) => ListTile(title: Text(uid)),
      data: (user) => ListTile(
        leading: UserAvatar(
          imageUrl: user?.avatarUrl,
          displayName: user?.displayName ?? uid,
        ),
        title: Text(user?.displayName ?? uid),
        subtitle: user?.username != null ? Text('@${user!.username}') : null,
        trailing: TextButton(
          onPressed: onUnblock == null ? null : () => onUnblock!(),
          child: Text(l10n.unblockUser),
        ),
      ),
    );
  }
}

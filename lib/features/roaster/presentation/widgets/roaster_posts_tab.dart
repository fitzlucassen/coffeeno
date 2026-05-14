import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/widgets/app_card.dart';
import '../../domain/roaster_post.dart';
import '../providers/roaster_post_provider.dart';

class RoasterPostsTab extends ConsumerWidget {
  const RoasterPostsTab({super.key, required this.roasterId});

  final String roasterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final postsAsync = ref.watch(roasterPostsProvider(roasterId));

    return Stack(
      children: [
        postsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l10n.error}: $e')),
          data: (posts) {
            if (posts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.campaign_outlined,
                          size: 48, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noPostsYet,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            // Bottom padding leaves room for the floating action button so
            // the last post isn't obscured.
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: posts.length,
              itemBuilder: (context, i) => _PostTile(
                post: posts[i],
                onDelete: () => _confirmDelete(context, ref, posts[i]),
                l10n: l10n,
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.edit_rounded),
            label: Text(l10n.newPost),
            onPressed: () =>
                context.push('/roaster/$roasterId/dashboard/compose-post'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, RoasterPost post) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deletePostConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(roasterPostRepositoryProvider).deletePost(post.id);
    }
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({
    required this.post,
    required this.onDelete,
    required this.l10n,
  });

  final RoasterPost post;
  final VoidCallback onDelete;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final remainingDays = post.expiresAt.difference(now).inDays;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(post.title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (post.coffeeName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    l10n.feedAboutCoffee(post.coffeeName!),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.primary),
                  ),
                ),
              const SizedBox(height: 8),
              Text(post.body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                post.isExpired
                    ? l10n.postExpired
                    : l10n.postExpiresIn(remainingDays),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: post.isExpired
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

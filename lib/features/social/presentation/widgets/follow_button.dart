import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffeeno/features/social/presentation/providers/social_provider.dart';

/// A follow / unfollow toggle button that reads follow state from Riverpod
/// and performs the follow/unfollow operation optimistically.
class FollowButton extends ConsumerStatefulWidget {
  const FollowButton({
    super.key,
    required this.targetUserId,
    this.compact = false,
  });

  final String targetUserId;
  final bool compact;

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool _isLoading = false;

  Future<void> _toggle(bool currentlyFollowing, String currentUserId) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final repository = ref.read(socialRepositoryProvider);
      if (currentlyFollowing) {
        await repository.unfollowUser(
          userId: currentUserId,
          targetId: widget.targetUserId,
        );
      } else {
        await repository.followUser(
          userId: currentUserId,
          targetId: widget.targetUserId,
        );
      }
      ref.invalidate(isFollowingProvider(
        (userId: currentUserId, targetId: widget.targetUserId),
      ));
    } catch (_) {
      // Silently fail; state will revert on next read.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) return const SizedBox.shrink();

    final currentUserId = currentUser.uid;

    // Don't show follow button for own profile.
    if (currentUserId == widget.targetUserId) return const SizedBox.shrink();

    final isFollowingAsync = ref.watch(
      isFollowingProvider(
        (userId: currentUserId, targetId: widget.targetUserId),
      ),
    );

    final isFollowing = isFollowingAsync.value ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.compact) {
      return SizedBox(
        height: 32,
        child: OutlinedButton(
          onPressed:
              _isLoading ? null : () => _toggle(isFollowing, currentUserId),
          style: OutlinedButton.styleFrom(
            backgroundColor:
                isFollowing ? Colors.transparent : colorScheme.primary,
            foregroundColor:
                isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
            side: BorderSide(
              color: isFollowing
                  ? colorScheme.outline
                  : colorScheme.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isFollowing
                  ? AppLocalizations.of(context).unfollow
                  : AppLocalizations.of(context).follow),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    return FilledButton.tonal(
      onPressed:
          _isLoading ? null : () => _toggle(isFollowing, currentUserId),
      style: FilledButton.styleFrom(
        backgroundColor:
            isFollowing ? colorScheme.surfaceContainerHighest : colorScheme.primary,
        foregroundColor:
            isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(isFollowing ? l10n.unfollow : l10n.follow),
    );
  }
}

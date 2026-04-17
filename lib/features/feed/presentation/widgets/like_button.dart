import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffeeno/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffeeno/features/feed/presentation/providers/feed_provider.dart';

/// An animated like button with a heart icon that toggles between
/// filled and outlined states. Performs optimistic updates and reverts
/// on error. Shows the current like count beside the icon.
class LikeButton extends ConsumerStatefulWidget {
  const LikeButton({
    super.key,
    required this.tastingId,
    required this.likesCount,
  });

  final String tastingId;
  final int likesCount;

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool? _optimisticLiked;
  int? _optimisticCount;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle(bool currentlyLiked, String userId) async {
    if (_isProcessing) return;

    HapticFeedback.lightImpact();
    _controller.forward(from: 0);

    final newLiked = !currentlyLiked;
    final newCount =
        widget.likesCount + (newLiked ? 1 : -1);

    setState(() {
      _optimisticLiked = newLiked;
      _optimisticCount = newCount;
      _isProcessing = true;
    });

    try {
      final repository = ref.read(feedRepositoryProvider);
      if (newLiked) {
        await repository.likeTasting(
          tastingId: widget.tastingId,
          userId: userId,
        );
      } else {
        await repository.unlikeTasting(
          tastingId: widget.tastingId,
          userId: userId,
        );
      }
      // Invalidate to refresh the liked state from Firestore.
      ref.invalidate(
        tastingLikedProvider(
          (tastingId: widget.tastingId, userId: userId),
        ),
      );
    } catch (_) {
      // Revert on error.
      if (mounted) {
        setState(() {
          _optimisticLiked = null;
          _optimisticCount = null;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) return const SizedBox.shrink();

    final userId = currentUser.uid;
    final likedAsync = ref.watch(
      tastingLikedProvider(
        (tastingId: widget.tastingId, userId: userId),
      ),
    );

    final isLiked = _optimisticLiked ?? likedAsync.valueOrNull ?? false;
    final count = _optimisticCount ?? widget.likesCount;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _toggle(isLiked, userId),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: isLiked ? colorScheme.error : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

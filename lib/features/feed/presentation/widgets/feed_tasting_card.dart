import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:coffeeno/core/widgets/star_rating.dart';
import 'package:coffeeno/features/feed/domain/feed_item.dart';
import 'package:coffeeno/features/social/presentation/widgets/user_avatar.dart';

import 'comment_sheet.dart';
import 'like_button.dart';

/// A card showing a single feed tasting entry with user info, coffee details,
/// rating, notes, and like/comment actions.
class FeedTastingCard extends StatelessWidget {
  const FeedTastingCard({
    super.key,
    required this.item,
  });

  final FeedItem item;

  void _navigateToProfile(BuildContext context) {
    context.push('/user/${item.authorId}');
  }

  void _navigateToTasting(BuildContext context) {
    context.push('/tasting/${item.tastingId}');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: InkWell(
        onTap: () => _navigateToTasting(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── User row ──
              Row(
                children: [
                  UserAvatar(
                    imageUrl: item.authorAvatar,
                    displayName: item.authorName,
                    onTap: () => _navigateToProfile(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToProfile(context),
                          child: Text(
                            item.authorName,
                            style: textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeago.format(item.createdAt),
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Coffee photo (optional) ──
              if (item.coffeePhotoUrl != null &&
                  item.coffeePhotoUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.coffeePhotoUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 180,
                      color: colorScheme.secondaryContainer,
                    ),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Coffee name + roaster ──
              Text(
                item.coffeeName,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.roasterName,
                style: textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // ── Rating + brew method ──
              Row(
                children: [
                  StarRating(rating: item.overallRating, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    item.overallRating.toStringAsFixed(1),
                    style: textTheme.titleSmall,
                  ),
                  if (item.brewMethod != null &&
                      item.brewMethod!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Chip(
                      label: Text(item.brewMethod!),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ],
              ),

              // ── Notes preview ──
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.notes!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),
              const Divider(),

              // ── Action row: like + comment ──
              Row(
                children: [
                  LikeButton(
                    tastingId: item.tastingId,
                    likesCount: item.likesCount,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => showCommentSheet(context, item.tastingId),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.commentsCount}',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

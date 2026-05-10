import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../../../roaster/domain/roaster_post.dart';

/// Visual differentiator for curated messages from roasters in the feed.
/// Uses a tinted container + "Pro" badge so it's unmistakable next to
/// regular tasting cards.
class FeedRoasterPostCard extends StatelessWidget {
  const FeedRoasterPostCard({super.key, required this.post});

  final RoasterPost post;

  Future<void> _openCta() async {
    final url = post.ctaUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/roaster/${post.roasterId}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: logo, roaster name, badge, time.
              Row(
                children: [
                  if (post.roasterLogoUrl != null &&
                      post.roasterLogoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: post.roasterLogoUrl!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            _roasterIconFallback(colorScheme),
                      ),
                    )
                  else
                    _roasterIconFallback(colorScheme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.feedPostedBy(post.roasterName),
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          timeago.format(post.createdAt),
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PRO',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(post.title, style: textTheme.titleMedium),

              // Linked coffee (optional)
              if (post.coffeeName != null) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.feedAboutCoffee(post.coffeeName!),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(height: 8),
              Text(
                post.body,
                style: textTheme.bodyMedium,
              ),

              // Optional CTA button
              if (post.ctaLabel != null &&
                  post.ctaLabel!.isNotEmpty &&
                  post.ctaUrl != null &&
                  post.ctaUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    onPressed: _openCta,
                    child: Text(post.ctaLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _roasterIconFallback(ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.store_rounded, color: colorScheme.primary, size: 20),
    );
  }
}

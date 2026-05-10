import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:coffeeno/core/widgets/app_card.dart';
import '../../../tasting/domain/tasting.dart';
import '../providers/roaster_stats_provider.dart';

/// List of the most recent tastings on any of the roaster's coffees.
/// This is the qualitative feedback a roaster actually wants to read.
class RoasterTastingsTab extends ConsumerWidget {
  const RoasterTastingsTab({super.key, required this.roasterId});

  final String roasterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tastingsAsync = ref.watch(roasterRecentTastingsProvider(roasterId));

    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(roasterRecentTastingsProvider(roasterId)),
      child: tastingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (tastings) {
          if (tastings.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    l10n.noTastingsYet,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tastings.length,
            itemBuilder: (context, i) => _TastingListTile(
              tasting: tastings[i],
              l10n: l10n,
            ),
          );
        },
      ),
    );
  }
}

class _TastingListTile extends StatelessWidget {
  const _TastingListTile({required this.tasting, required this.l10n});

  final Tasting tasting;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasNotes = tasting.notes != null && tasting.notes!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: InkWell(
          onTap: () => context.push('/tasting/${tasting.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tasting.coffeeName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.star_rounded,
                        size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 2),
                    Text(tasting.overallRating.toStringAsFixed(1),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      tasting.authorName ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${timeago.format(tasting.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Text(
                      '${tasting.brewMethod} · ${tasting.grindSize}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (tasting.flavorNotes.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tasting.flavorNotes
                        .take(6)
                        .map((n) => Chip(
                              label: Text(n,
                                  style: theme.textTheme.bodySmall),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 4),
                Text(
                  hasNotes ? tasting.notes! : l10n.tastingNotesEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasNotes
                        ? null
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontStyle: hasNotes ? null : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:coffeeno/core/widgets/app_card.dart';
import '../../domain/roaster_stats.dart';
import '../providers/roaster_stats_provider.dart';

class RoasterStatsTab extends ConsumerStatefulWidget {
  const RoasterStatsTab({super.key, required this.roasterId});

  final String roasterId;

  @override
  ConsumerState<RoasterStatsTab> createState() => _RoasterStatsTabState();
}

class _RoasterStatsTabState extends ConsumerState<RoasterStatsTab> {
  StatsPeriod _period = StatsPeriod.last30Days;
  bool _isExporting = false;

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(roasterStatsRepositoryProvider);
      final csv = await repo.buildRoasterExportCsv(widget.roasterId);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/coffeeno-${widget.roasterId}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: l10n.exportCsvShareText,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statsAsync = ref.watch(roasterStatsProvider(widget.roasterId));
    final seriesAsync = ref.watch(
      roasterTimeseriesProvider(
        RoasterTimeseriesParams(widget.roasterId, _period),
      ),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(roasterStatsProvider(widget.roasterId));
        ref.invalidate(
          roasterTimeseriesProvider(
            RoasterTimeseriesParams(widget.roasterId, _period),
          ),
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Stat cards
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l10n.error}: $e'),
            data: (stats) => _StatsGrid(stats: stats, l10n: l10n),
          ),
          const SizedBox(height: 24),

          // Period selector + chart
          SegmentedButton<StatsPeriod>(
            segments: [
              ButtonSegment(
                  value: StatsPeriod.last30Days, label: Text(l10n.period30d)),
              ButtonSegment(
                  value: StatsPeriod.last3Months, label: Text(l10n.period3m)),
              ButtonSegment(
                  value: StatsPeriod.last12Months, label: Text(l10n.period12m)),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: seriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.error}: $e')),
              data: (points) =>
                  _TimeseriesChart(points: points, colorScheme: colorScheme),
            ),
          ),
          _LegendRow(
            colorScheme: colorScheme,
            tastingsLabel: l10n.chartTastingsLabel,
            ratingLabel: l10n.chartRatingLabel,
          ),
          const SizedBox(height: 24),

          // Top coffees (kept from original dashboard)
          statsAsync.maybeWhen(
            data: (stats) => _TopCoffees(stats: stats, l10n: l10n),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),

          // CSV export
          OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportCsv,
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
            label: Text(l10n.exportCsv),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.l10n});

  final RoasterStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _StatCard(
              icon: Icons.coffee_rounded,
              label: l10n.totalCoffees,
              value: stats.totalCoffees.toString(),
              color: colorScheme.primary,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
              icon: Icons.rate_review_rounded,
              label: l10n.totalTastings,
              value: stats.totalTastings.toString(),
              color: colorScheme.tertiary,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _StatCard(
              icon: Icons.star_rounded,
              label: l10n.avgScore,
              value: stats.ratingsCount > 0
                  ? stats.avgRating.toStringAsFixed(1)
                  : '-',
              color: colorScheme.secondary,
              subtitle: stats.ratingsCount > 0
                  ? l10n.ratingsCount(stats.ratingsCount)
                  : null,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
              icon: Icons.trending_up_rounded,
              label: l10n.recentTastings30d,
              value: stats.recentTastings.toString(),
              color: colorScheme.error,
            )),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                )),
          ],
        ],
      ),
    );
  }
}

class _TopCoffees extends StatelessWidget {
  const _TopCoffees({required this.stats, required this.l10n});

  final RoasterStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (stats.topCoffees.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.topCoffeesByRating, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...stats.topCoffees.map((coffee) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.coffee_rounded,
                          size: 20,
                          color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coffee.name,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(l10n.tastingsCount(coffee.tastingsCount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            size: 18, color: colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(coffee.avgRating.toStringAsFixed(1),
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _TimeseriesChart extends StatelessWidget {
  const _TimeseriesChart({required this.points, required this.colorScheme});

  final List<TimeseriesPoint> points;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxCount = points
        .map((p) => p.tastingsCount)
        .fold<int>(0, (a, b) => a > b ? a : b);
    // Scale rating (0–5) up to the same axis as counts for a readable overlay.
    final ratingScale = maxCount <= 0 ? 1.0 : maxCount / 5.0;

    final tastingsSpots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].tastingsCount.toDouble()),
    ];
    final ratingSpots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].avgRating * ratingScale),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxCount == 0 ? 5 : maxCount.toDouble() * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: tastingsSpots,
            isCurved: true,
            barWidth: 2.5,
            color: colorScheme.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          LineChartBarData(
            spots: ratingSpots,
            isCurved: true,
            barWidth: 2,
            color: colorScheme.secondary,
            dotData: const FlDotData(show: false),
            dashArray: [4, 4],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.colorScheme,
    required this.tastingsLabel,
    required this.ratingLabel,
  });

  final ColorScheme colorScheme;
  final String tastingsLabel;
  final String ratingLabel;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Dot(color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(tastingsLabel, style: textStyle),
          const SizedBox(width: 16),
          _Dot(color: colorScheme.secondary, dashed: true),
          const SizedBox(width: 4),
          Text(ratingLabel, style: textStyle),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, this.dashed = false});
  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : color,
        border: dashed ? Border.all(color: color, width: 2) : null,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

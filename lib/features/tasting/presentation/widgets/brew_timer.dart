import 'dart:async';

import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

/// Pure, side-effect-free view state for the brew timer. Kept separate from the
/// widget so the display/formatting/progress logic is unit-testable without a
/// real clock.
class BrewTimerState {
  const BrewTimerState({
    required this.elapsedSeconds,
    required this.targetSeconds,
  });

  final int elapsedSeconds;

  /// The suggested/target brew time. When <= 0 there is no target, so progress
  /// is reported as 0 and the target is never "reached".
  final int targetSeconds;

  bool get hasTarget => targetSeconds > 0;

  /// Whether the elapsed time has reached the target (false when no target).
  bool get targetReached => hasTarget && elapsedSeconds >= targetSeconds;

  /// Progress toward the target, clamped to 0..1. Returns 0 when no target.
  double get progress {
    if (!hasTarget) return 0;
    return (elapsedSeconds / targetSeconds).clamp(0.0, 1.0);
  }

  /// Formats a duration in seconds as `m:ss`.
  static String format(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final m = safe ~/ 60;
    final s = safe % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get elapsedLabel => format(elapsedSeconds);
  String get targetLabel => format(targetSeconds);
}

/// A start/stop/reset brew timer that counts up toward [targetSeconds] (the
/// AI-suggested brew time). Purely a stopwatch — it does not mutate the form;
/// it just helps the user hit the target while brewing.
class BrewTimer extends StatefulWidget {
  const BrewTimer({super.key, required this.targetSeconds});

  final int targetSeconds;

  @override
  State<BrewTimer> createState() => _BrewTimerState();
}

class _BrewTimerState extends State<BrewTimer> {
  Timer? _timer;
  int _elapsed = 0;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed++);
      });
      setState(() => _running = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _elapsed = 0;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = BrewTimerState(
      elapsedSeconds: _elapsed,
      targetSeconds: widget.targetSeconds,
    );
    final reached = state.targetReached;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n.brewGuideTitle, style: theme.textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              state.elapsedLabel,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: reached ? theme.colorScheme.primary : null,
              ),
            ),
            if (state.hasTarget) ...[
              const SizedBox(width: 8),
              Text(
                '/ ${state.targetLabel}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        if (state.hasTarget) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 6,
              color: reached ? theme.colorScheme.primary : null,
            ),
          ),
          if (reached) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.brewGuideTargetReached,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              label: Text(_running ? l10n.brewGuideStop : l10n.brewGuideStart),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: (_elapsed == 0 && !_running) ? null : _reset,
              icon: const Icon(Icons.replay),
              label: Text(l10n.brewGuideReset),
            ),
          ],
        ),
      ],
    );
  }
}

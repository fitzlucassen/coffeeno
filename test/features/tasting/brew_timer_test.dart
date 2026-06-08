import 'package:coffeeno/features/tasting/presentation/widgets/brew_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrewTimerState.format', () {
    test('formats minutes and zero-padded seconds', () {
      expect(BrewTimerState.format(0), '0:00');
      expect(BrewTimerState.format(5), '0:05');
      expect(BrewTimerState.format(65), '1:05');
      expect(BrewTimerState.format(600), '10:00');
    });

    test('treats negative input as zero', () {
      expect(BrewTimerState.format(-3), '0:00');
    });
  });

  group('BrewTimerState progress & target', () {
    test('no target: never reached, progress 0', () {
      const s = BrewTimerState(elapsedSeconds: 30, targetSeconds: 0);
      expect(s.hasTarget, isFalse);
      expect(s.targetReached, isFalse);
      expect(s.progress, 0);
    });

    test('progress scales linearly and clamps at 1', () {
      expect(
        const BrewTimerState(elapsedSeconds: 0, targetSeconds: 100).progress,
        0.0,
      );
      expect(
        const BrewTimerState(elapsedSeconds: 50, targetSeconds: 100).progress,
        0.5,
      );
      expect(
        const BrewTimerState(elapsedSeconds: 150, targetSeconds: 100).progress,
        1.0,
      );
    });

    test('targetReached flips at or past the target', () {
      expect(
        const BrewTimerState(elapsedSeconds: 99, targetSeconds: 100)
            .targetReached,
        isFalse,
      );
      expect(
        const BrewTimerState(elapsedSeconds: 100, targetSeconds: 100)
            .targetReached,
        isTrue,
      );
      expect(
        const BrewTimerState(elapsedSeconds: 120, targetSeconds: 100)
            .targetReached,
        isTrue,
      );
    });

    test('labels render via format', () {
      const s = BrewTimerState(elapsedSeconds: 65, targetSeconds: 180);
      expect(s.elapsedLabel, '1:05');
      expect(s.targetLabel, '3:00');
    });
  });
}

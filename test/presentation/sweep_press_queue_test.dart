import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_phase.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_press_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a held forward key keeps no more than three presses', () {
    final queue = SweepPressQueue();
    var steps = 0;

    for (var press = 0; press < 30; press++) {
      queue.press(
        forward: true,
        phase: SweepPhase.hold,
        onForward: () => steps++,
        onBackward: () => steps--,
      );
    }

    expect(steps, 0);
    expect(queue.pending, SweepPressQueue.maxQueuedPresses);

    expect(queue.drainOne(() => steps++), isTrue);
    expect(steps, 1);
    expect(queue.pending, SweepPressQueue.maxQueuedPresses - 1);
  });

  test('a backward press during a flight is ignored rather than deferred', () {
    final queue = SweepPressQueue();
    var steps = 0;

    queue.press(
      forward: false,
      phase: SweepPhase.inward,
      onForward: () => steps++,
      onBackward: () => steps--,
    );

    expect(steps, 0);
    expect(queue.pending, 0);
  });
}

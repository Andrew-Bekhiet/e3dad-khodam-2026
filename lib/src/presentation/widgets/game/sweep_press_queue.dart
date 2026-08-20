import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_phase.dart';

/// Holds forward presses made while a camera sweep is still running.
final class SweepPressQueue {
  /// A held arrow repeats about thirty times a second; replaying a whole
  /// flight's worth would step past the Level the operator was waiting for.
  static const int maxQueuedPresses = 3;

  int _pending = 0;

  /// Number of forward presses waiting for a landed sweep.
  int get pending => _pending;

  /// Applies a press now, or queues a forward press while the camera flies.
  ///
  /// A backward press is dropped there: landing only to fly straight back
  /// out is less useful than ignoring a key pressed mid-flight.
  void press({
    required bool forward,
    required SweepPhase phase,
    required void Function() onForward,
    required void Function() onBackward,
  }) {
    if (phase.isRunning) {
      if (forward) {
        _pending = (_pending + 1).clamp(0, maxQueuedPresses);
      }

      return;
    }

    if (forward) {
      onForward();
    } else {
      onBackward();
    }
  }

  /// Applies one queued forward press, if there is one.
  bool drainOne(void Function() onForward) {
    if (_pending == 0) {
      return false;
    }
    _pending--;
    onForward();

    return true;
  }
}

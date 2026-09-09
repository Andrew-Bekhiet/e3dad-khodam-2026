import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_press_queue.dart';
import 'package:flutter/widgets.dart';

/// Owns one sweep's animation clock, the presses made while it flies, and
/// the keyboard focus a step should take back.
///
/// The shared half of what `GameJourneyPage` and `HistoricalJourneyPresenter`
/// each need around a `SweepCameraTarget`: [forward]/[backward] take focus
/// back and either apply or queue the press, and [handleCameraChange]
/// starts or parks the clock, then — once it lands — drains whatever was
/// queued mid-flight, one press per frame. See
/// `GameJourneyPage._drainPressQueue`'s original comment for why one at a
/// time: a press can set off another sweep, and applying the rest of the
/// queue on top of it would stack two flights on one clock.
final class SweepStepQueue {
  final AnimationController _controller;
  final FocusNode focusNode;
  final VoidCallback onForward;
  final VoidCallback onBackward;

  /// The clock's own phase and progress, shared with whatever draws the
  /// sweep.
  late final SweepClock sweepClock = SweepClock(_controller);

  final SweepPressQueue _pressQueue = SweepPressQueue();
  bool _disposed = false;

  /// Creates a queue over a fresh [AnimationController] ticked by [vsync],
  /// stepping [onForward]/[onBackward] and returning focus to [focusNode].
  SweepStepQueue({
    required TickerProvider vsync,
    required this.focusNode,
    required this.onForward,
    required this.onBackward,
  }) : _controller = AnimationController(vsync: vsync);

  /// Steps forward and takes the keyboard focus back, so a tap on the map
  /// or a button does not leave the arrow keys dead afterwards.
  ///
  /// Queued rather than applied while the camera is mid-flight: the sweep
  /// is one movement, and cutting it short leaves the camera somewhere
  /// nobody asked for.
  void forward() => _step(forward: true);

  /// Steps backward and takes the keyboard focus back.
  ///
  /// Dropped rather than queued while the camera is mid-flight: landing
  /// only to fly straight back out again is worse than ignoring a key
  /// pressed during a second of animation.
  void backward() => _step(forward: false);

  /// Starts timing [sweep], or parks the clock when there is none to fly.
  ///
  /// A `TickerFuture` only completes when the animation runs its whole
  /// course, so an interrupted sweep never calls [onLanded] or drains the
  /// queue — which is the point: nothing was reached.
  void handleCameraChange(SweepCameraTarget? sweep, {VoidCallback? onLanded}) {
    if (sweep == null) {
      sweepClock.interrupt();

      return;
    }
    sweepClock.start(sweep).then((_) => _onLanded(onLanded));
  }

  void dispose() {
    _disposed = true;
    sweepClock.dispose();
    _controller.dispose();
  }

  void _step({required bool forward}) {
    focusNode.requestFocus();
    _pressQueue.press(
      forward: forward,
      phase: sweepClock.phase,
      onForward: onForward,
      onBackward: onBackward,
    );
  }

  void _onLanded(VoidCallback? onLanded) {
    if (_disposed) {
      return;
    }
    onLanded?.call();
    _drainPressQueue();
  }

  void _drainPressQueue() {
    if (_disposed || !_pressQueue.drainOne(onForward)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || sweepClock.phase.isRunning) {
        return;
      }
      _drainPressQueue();
    });
  }
}

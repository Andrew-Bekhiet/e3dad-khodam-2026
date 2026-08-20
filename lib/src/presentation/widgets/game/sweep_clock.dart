import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_phase.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Derives a sweep's phases from the page's one animation controller.
///
/// The controller remains owned by the page. This object only gives its
/// consumers one vocabulary for the camera, couriers, sounds, and queue.
final class SweepClock extends ChangeNotifier {
  final AnimationController _controller;
  SweepCameraTarget? _sweep;
  SweepPhase _phase = SweepPhase.landed;

  /// The sweep being timed, if one is active or has just landed.
  SweepCameraTarget? get sweep => _sweep;

  /// The camera's current sweep phase.
  SweepPhase get phase => _phase;

  /// How far through the whole sweep the controller has travelled.
  double get progress => _controller.value;

  /// How far the party has walked during the hold phase.
  double get holdProgress {
    final sweep = _sweep;
    if (sweep == null) {
      return 1;
    }

    return switch (_phase) {
      SweepPhase.out => 0.0,
      SweepPhase.hold =>
        ((_controller.value * sweep.total.inMilliseconds -
                    sweep.outLeg.inMilliseconds) /
                sweep.hold.inMilliseconds)
            .clamp(0.0, 1.0),
      SweepPhase.inward || SweepPhase.landed || SweepPhase.interrupted => 1.0,
    };
  }

  /// Creates a phase clock over an [AnimationController].
  SweepClock(this._controller) {
    _controller
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);
  }

  /// Starts timing [sweep] from its outward leg.
  TickerFuture start(SweepCameraTarget sweep) {
    _sweep = sweep;
    _phase = SweepPhase.out;
    _controller.duration = sweep.total;
    notifyListeners();

    return _controller.forward(from: 0);
  }

  /// Stops a sweep that did not reach its destination.
  void interrupt() {
    _controller.stop();
    _sweep = null;
    _phase = SweepPhase.interrupted;
    _controller.value = 0;
    notifyListeners();
  }

  void _onTick() {
    final sweep = _sweep;
    if (sweep != null && _controller.isAnimating) {
      final elapsed = _controller.value * sweep.total.inMilliseconds;
      if (elapsed < sweep.outLeg.inMilliseconds) {
        _phase = SweepPhase.out;
      } else if (elapsed <
          sweep.outLeg.inMilliseconds + sweep.hold.inMilliseconds) {
        _phase = SweepPhase.hold;
      } else {
        _phase = SweepPhase.inward;
      }
    }
    notifyListeners();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _sweep == null) {
      return;
    }
    _phase = SweepPhase.landed;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..removeStatusListener(_onStatus);
    super.dispose();
  }
}

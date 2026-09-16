import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Drives the beacon's flash.
///
/// Alternates [isBright] between two states on a clock quantised to
/// roughly two states a second, so `HistoryMapView` hands the map
/// surface a changed spec twice a second rather than sixty times — the
/// same reasoning `_walkSteps` in `game_map_view.dart` is built on: a
/// smooth flash and a smooth walk would both fill the platform channel
/// with copies of a spec no eye can tell apart.
final class BeaconClock extends ChangeNotifier {
  /// One full bright-then-dim cycle: two states inside one second.
  static const Duration period = Duration(seconds: 1);

  final AnimationController _controller;
  bool _isBright = true;

  /// Whether the beacon should currently draw as
  /// `HistoryMapStyles.beaconBright`, as opposed to `beaconDim`.
  bool get isBright => _isBright;

  /// Whether the flash is running. Off, the beacon holds bright.
  bool get isFlashing => _controller.isAnimating;

  set isFlashing(bool value) {
    if (value == isFlashing) {
      return;
    }
    if (value) {
      _controller.repeat();

      return;
    }
    _controller.stop();
    _isBright = true;
    notifyListeners();
  }

  /// Creates a beacon clock over a repeating [AnimationController] and
  /// starts it immediately.
  ///
  /// The flash runs for the page's whole lifetime rather than only while
  /// a beacon is showing: nothing on the historical map moves but the
  /// trail and this, so the cost of always ticking is one boolean flip
  /// twice a second, and it saves the map view from having to start and
  /// stop a clock in step with the cubit.
  BeaconClock(this._controller) {
    _controller
      ..duration = period
      ..addListener(_onTick)
      ..repeat();
  }

  void _onTick() {
    final bright = _controller.value < 0.5;
    if (bright == _isBright) {
      return;
    }
    _isBright = bright;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    super.dispose();
  }
}

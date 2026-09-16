import 'dart:async';

import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/map_script_presenter.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/sweep_step_queue.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/beacon_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/history_map_view.dart';
import 'package:flutter/widgets.dart';

/// Plays one historical journey on the stage's shared map surface.
///
/// Reuses [HistoryMapSpecBuilder] for the trail/marker caching and
/// [SweepStepQueue] for the sweep clock, its press queue and its focus —
/// the same pieces `HistoryMapView` and `HistoricalJourneyPage` use
/// standalone — rather than restating any of them.
final class HistoricalJourneyPresenter extends MapScriptPresenter {
  final HistoricalJourneyCubit _cubit;
  final HistoryMapSpecBuilder _specBuilder = HistoryMapSpecBuilder();
  final SweepStepQueue _stepQueue;
  final AnimationController _beaconController;
  late final BeaconClock _beaconClock = BeaconClock(_beaconController);

  // Cancelled from `dispose`, not from the constructor that creates it —
  // the standard subscribe-in-constructor/cancel-in-dispose shape the
  // checker doesn't trace across methods.
  // ignore: cancel_subscriptions
  StreamSubscription<HistoricalJourneyState>? _subscription;
  MapCameraTarget? _lastCamera;

  @override
  bool get canGoForward => !_cubit.state.isAtEnd;

  @override
  bool get canGoBackward => !_cubit.state.isAtStart;

  /// Whether the beacon flashes or holds bright.
  bool get isBeaconFlashing => _beaconClock.isFlashing;

  set isBeaconFlashing(bool value) => _beaconClock.isFlashing = value;

  @override
  ScriptOverlayBuilder get buildOverlay =>
      (_) => const SizedBox.shrink();

  /// Plays [journey], ticked by [vsync], returning focus to [focusNode]
  /// on every step.
  factory HistoricalJourneyPresenter({
    required HistoricalJourney journey,
    required TickerProvider vsync,
    required FocusNode focusNode,
  }) {
    final cubit = HistoricalJourneyCubit(journey);

    return HistoricalJourneyPresenter._(
      cubit,
      SweepStepQueue(
        vsync: vsync,
        focusNode: focusNode,
        onForward: cubit.forward,
        onBackward: cubit.backward,
      ),
      AnimationController(vsync: vsync),
    );
  }

  HistoricalJourneyPresenter._(
    this._cubit,
    this._stepQueue,
    this._beaconController,
  ) {
    _lastCamera = _cubit.state.camera;
    _stepQueue.sweepClock.addListener(notifyListeners);
    _beaconClock.addListener(notifyListeners);
    _subscription = _cubit.stream.listen(_onState);
  }

  @override
  MapSurfaceSpec buildSpec(BuildContext context) => _specBuilder.build(
    state: _cubit.state,
    sweepClock: _stepQueue.sweepClock,
    beaconBright: _beaconClock.isBright,
    onMarkerTap: (_) => forward(),
    onSurfaceTap: forward,
  );

  @override
  void forward() => _stepQueue.forward();

  @override
  void backward() => _stepQueue.backward();

  @override
  void dispose() {
    final subscription = _subscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    _stepQueue
      ..sweepClock.removeListener(notifyListeners)
      ..dispose();
    _beaconClock
      ..removeListener(notifyListeners)
      ..dispose();
    _beaconController.dispose();
    unawaited(_cubit.close());
    super.dispose();
  }

  void _onState(HistoricalJourneyState state) {
    if (state.camera != _lastCamera) {
      _lastCamera = state.camera;
      _stepQueue.handleCameraChange(state.sweep);
    }
    notifyListeners();
  }
}

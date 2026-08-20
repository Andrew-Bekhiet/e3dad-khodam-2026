import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/step_direction.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/sweep_framing.dart';
import 'package:flutter/widgets.dart';

/// Camera policy and motion vocabulary for the Post Office Game.
final class GameJourneyCamera {
  static const GeoBounds sweepFrame = GeoBounds(
    south: 30.89,
    west: 10.0,
    north: 43.57,
    east: 26.0,
  );
  static const double arrivalZoom = 10.0;
  static const Duration sweepOut = Duration(milliseconds: 700);
  static const Duration sweepHold = Duration(milliseconds: 1000);
  static const Duration sweepIn = Duration(milliseconds: 900);
  static const double _legMargin = 0.6;
  static const EdgeInsets _legPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 72,
  );
  static const EdgeInsets _overviewPadding = EdgeInsets.only(
    top: 120,
    left: 64,
    right: 64,
    bottom: 104,
  );
  static const Duration stepDuration = Duration(milliseconds: 550);

  const GameJourneyCamera();

  MapCameraTarget targetFor(
    LevelScript script,
    GameTransition transition, {
    required MapCameraTarget? previous,
    required SweepFraming framing,
  }) {
    final arrival = transition.arrival;
    if (previous != null &&
        _levelContext(arrival) == _levelContext(transition.departure)) {
      return previous;
    }

    return switch (arrival) {
      OpeningStep() => CenterZoomCameraTarget(
        center: script.home.position,
        zoom: arrivalZoom,
      ),
      EpilogueStep() => FitBoundsCameraTarget(
        bounds: GeoBounds.containing([
          for (final level in script.levels) level.destination.position,
        ]),
        padding: _overviewPadding,
      ),
      PrologueStep() || LevelStep() => _arrivalOrSweep(
        transition,
        framing,
      ),
    };
  }

  MapCameraTarget _arrivalOrSweep(
    GameTransition transition,
    SweepFraming framing,
  ) {
    final destination = transition.arrivalStop;
    if (destination == null) {
      throw StateError('A level or prologue step must arrive at a stop.');
    }
    final arrival = CenterZoomCameraTarget(
      center: destination.position,
      zoom: arrivalZoom,
    );
    if (transition.direction == StepDirection.backward ||
        transition.departure == null ||
        transition.departureStop.id == destination.id) {
      return arrival;
    }

    return SweepCameraTarget(
      widest: _widestFrame(transition, framing),
      arrival: arrival,
      outLeg: sweepOut,
      hold: sweepHold,
      inLeg: sweepIn,
    );
  }

  FitBoundsCameraTarget _widestFrame(
    GameTransition transition,
    SweepFraming framing,
  ) => switch (framing) {
    SweepFraming.basin => const FitBoundsCameraTarget(
      bounds: sweepFrame,
      padding: EdgeInsets.zero,
    ),
    SweepFraming.leg => FitBoundsCameraTarget(
      bounds: GeoBounds.containing([
        transition.departureStop.position,
        transition.arrivalStop?.position ?? transition.departureStop.position,
      ]).padded(_legMargin),
      padding: _legPadding,
    ),
  };

  int? _levelContext(GameStep? step) => switch (step) {
    PrologueStep() => 0,
    LevelStep(:final levelIndex) => levelIndex,
    OpeningStep() || EpilogueStep() || null => null,
  };
}

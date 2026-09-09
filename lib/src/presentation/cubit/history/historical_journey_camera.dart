import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/step_direction.dart';
import 'package:flutter/widgets.dart';

/// Camera policy and motion vocabulary for the historical journeys.
///
/// A separate policy class for the same reason ADR 0006 gives for the
/// game's: it is the only part that needs `EdgeInsets`, while walking the
/// steps must stay synchronous and independent of a map surface.
final class HistoricalJourneyCamera {
  /// Zoom for a rest with no beacon — still reads as a map of the
  /// Mediterranean, not a street. The game's `arrivalZoom` of 10 is far
  /// too close for that.
  static const double arrivalZoom = 6.0;

  static const double _beaconMargin = 0.5;
  static const double _stretchMargin = 0.6;
  static const double _openingMargin = 1.0;

  static const EdgeInsets _beaconPadding = EdgeInsets.symmetric(
    horizontal: 48,
    vertical: 96,
  );
  static const EdgeInsets _stretchPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 72,
  );
  static const EdgeInsets _openingPadding = EdgeInsets.only(
    top: 120,
    left: 64,
    right: 64,
    bottom: 104,
  );

  /// How long the camera takes to pull out to the stretch about to be
  /// drawn.
  static const Duration sweepOut = Duration(milliseconds: 1100);

  /// How long the camera holds at the wide frame while the trail draws
  /// itself. Many times the game's 1000ms: these stretches are the length
  /// of the Aegean, the trail drawing itself is the content, and it is
  /// watched from across a hall rather than held in the hand.
  static const Duration sweepHold = Duration(milliseconds: 6000);

  /// How long the camera takes to come in to the arrival frame.
  static const Duration sweepIn = Duration(milliseconds: 1400);

  /// How long a non-sweeping camera move takes.
  static const Duration stepDuration = Duration(milliseconds: 550);

  const HistoricalJourneyCamera();

  /// The camera target for arriving at [arrival], having come from
  /// [departure] by [direction].
  MapCameraTarget targetFor(
    HistoricalJourney journey, {
    required HistoricalStep arrival,
    required HistoricalStep? departure,
    required StepDirection direction,
  }) => switch (arrival) {
    JourneyOpeningStep() => FitBoundsCameraTarget(
      bounds: GeoBounds.containing(_namedPoints(journey)).padded(
        _openingMargin,
      ),
      padding: _openingPadding,
    ),
    RestStep(:final restIndex) => _arrivalOrSweep(
      journey,
      restIndex,
      departure,
      direction,
    ),
  };

  MapCameraTarget _arrivalOrSweep(
    HistoricalJourney journey,
    int restIndex,
    HistoricalStep? departure,
    StepDirection direction,
  ) {
    final rest = journey.rests[restIndex];
    final previousStop = restIndex == 0
        ? journey.origin
        : journey.rests[restIndex - 1].stop;
    final arrival = _arrivalFrame(rest);
    if (direction == StepDirection.backward ||
        departure == null ||
        previousStop.id == rest.stop.id) {
      return arrival;
    }

    return SweepCameraTarget(
      widest: FitBoundsCameraTarget(
        bounds: GeoBounds.containing([
          previousStop.position,
          for (final via in rest.via) via.position,
          rest.stop.position,
        ]).padded(_stretchMargin),
        padding: _stretchPadding,
      ),
      arrival: arrival,
      outLeg: sweepOut,
      hold: sweepHold,
      inLeg: sweepIn,
    );
  }

  /// The frame to arrive on: both the rest and its beacon, comfortably —
  /// a frame that clips the beacon defeats the whole point of it — or
  /// just the rest when it sends none.
  CameraLeg _arrivalFrame(JourneyRest rest) {
    final beacon = rest.beacon;
    if (beacon == null) {
      return CenterZoomCameraTarget(
        center: rest.stop.position,
        zoom: arrivalZoom,
      );
    }

    return FitBoundsCameraTarget(
      bounds: GeoBounds.containing([
        rest.stop.position,
        beacon.position,
      ]).padded(_beaconMargin),
      padding: _beaconPadding,
    );
  }

  Iterable<GeoPosition> _namedPoints(HistoricalJourney journey) sync* {
    yield journey.origin.position;
    for (final rest in journey.rests) {
      for (final via in rest.via) {
        yield via.position;
      }
      yield rest.stop.position;
      final beacon = rest.beacon;
      if (beacon != null) {
        yield beacon.position;
      }
    }
  }
}

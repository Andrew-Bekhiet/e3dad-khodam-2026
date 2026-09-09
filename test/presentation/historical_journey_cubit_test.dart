import 'package:e3dad_khodam_2026/src/data/history/historical_journeys.dart';
import 'package:e3dad_khodam_2026/src/data/history/historical_stops.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_camera.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_step.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether [position] sits inside [bounds], on either edge included.
bool _frames(GeoBounds bounds, GeoPosition position) {
  final withinLatitude =
      bounds.south <= position.latitude && position.latitude <= bounds.north;
  final withinLongitude =
      bounds.west <= position.longitude && position.longitude <= bounds.east;

  return withinLatitude && withinLongitude;
}

/// How far, in degrees, [bounds] sits padded beyond the box that merely
/// touches [positions] at their edges — one number per edge, in
/// south/north/west/east order.
List<double> _paddingOf(GeoBounds bounds, List<GeoPosition> positions) {
  final raw = GeoBounds.containing(positions);

  return [
    raw.south - bounds.south,
    bounds.north - raw.north,
    raw.west - bounds.west,
    bounds.east - raw.east,
  ];
}

FitBoundsCameraTarget _fitBoundsOf(HistoricalJourneyState state) {
  final camera = state.camera;
  if (camera is! FitBoundsCameraTarget) {
    fail('expected a FitBoundsCameraTarget, got $camera');
  }

  return camera;
}

SweepCameraTarget _sweepOf(HistoricalJourneyState state) {
  final sweep = state.sweep;
  if (sweep == null) {
    fail('expected a step that sweeps');
  }

  return sweep;
}

void main() {
  _openingTests();
  _sweepAndArrivalTests();
  _revealedViaTests();
  _traceTests();
  _romeJourneyTests();
  _stepBoundaryTests();
}

void _openingTests() {
  test(
    'HistoricalJourneyCubit_construction_startsOnTheOpeningStep_framingTheWholeJourney',
    () {
      final cubit = HistoricalJourneyCubit(HistoricalJourneys.secondJourney);
      addTearDown(cubit.close);

      expect(cubit.state.step, isA<JourneyOpeningStep>());
      expect(cubit.state.stepIndex, 0);
      expect(cubit.state.stepCount, 2);
      expect(cubit.state.isAtStart, isTrue);

      final bounds = _fitBoundsOf(cubit.state).bounds;
      final rest = HistoricalJourneys.secondJourney.rests.single;
      final beacon = rest.beacon;
      if (beacon == null) {
        fail('the second journey names a beacon');
      }
      expect(_frames(bounds, HistoricalStops.antioch.position), isTrue);
      for (final via in rest.via) {
        expect(
          _frames(bounds, via.position),
          isTrue,
          reason: '${via.label} should be framed on the opening shot',
        );
      }
      expect(_frames(bounds, rest.stop.position), isTrue);
      expect(_frames(bounds, beacon.position), isTrue);
    },
  );
}

void _sweepAndArrivalTests() {
  test('HistoricalJourneyCubit_forwardFromOpening_intoARest_sweeps', () {
    final cubit = HistoricalJourneyCubit(HistoricalJourneys.secondJourney);
    addTearDown(cubit.close);

    cubit.forward();

    expect(cubit.state.step, const RestStep(0));
    final sweep = _sweepOf(cubit.state);
    expect(sweep.widest, isA<FitBoundsCameraTarget>());
    // Coming in is the part worth watching, so it takes longer, and the
    // hold is materially longer than the game's 1000ms: the trail
    // drawing itself is the content.
    expect(sweep.inLeg, greaterThan(sweep.outLeg));
    expect(sweep.hold, greaterThan(const Duration(milliseconds: 1000)));
  });

  test(
    'HistoricalJourneyCubit_aRestWithABeacon_arrivesFramingBothComfortably',
    () {
      final cubit = HistoricalJourneyCubit(HistoricalJourneys.secondJourney);
      addTearDown(cubit.close);

      cubit.forward();

      final arrival = _sweepOf(cubit.state).arrival;
      expect(arrival, isA<FitBoundsCameraTarget>());
      final bounds = (arrival as FitBoundsCameraTarget).bounds;

      final restPosition = JourneyStops.corinth.position;
      final beaconPosition = JourneyStops.thessalonica.position;
      expect(_frames(bounds, restPosition), isTrue);
      expect(_frames(bounds, beaconPosition), isTrue);

      // Not merely a FitBounds touching the two points at their exact
      // edges (which would clip them), and not padded out to basin scale
      // either (which would leave both as unreadable dots): the padding
      // on every edge sits in a legible band between the two.
      for (final pad in _paddingOf(bounds, [restPosition, beaconPosition])) {
        expect(pad, greaterThan(0.05));
        expect(pad, lessThan(2.0));
      }
    },
  );

  test(
    'HistoricalJourneyCubit_aRestWithoutABeacon_arrivesCenteredNotFramed',
    () {
      final cubit = HistoricalJourneyCubit(HistoricalJourneys.thirdJourney);
      addTearDown(cubit.close);

      cubit.forward();

      expect(cubit.state.beacon, isNull);
      final arrival = _sweepOf(cubit.state).arrival;
      expect(
        arrival,
        CenterZoomCameraTarget(
          center: JourneyStops.ephesus.position,
          zoom: HistoricalJourneyCamera.arrivalZoom,
        ),
      );
    },
  );

  test('HistoricalJourneyCubit_backward_landsDirectlyWithNoSweep', () {
    final cubit = HistoricalJourneyCubit(HistoricalJourneys.thirdJourney);
    addTearDown(cubit.close);

    cubit
      ..forward() // rest 0: أفسس
      ..forward(); // rest 1: فيلبي, beacon رومية
    expect(cubit.state.step, const RestStep(1));

    cubit.backward();

    expect(cubit.state.step, const RestStep(0));
    expect(cubit.state.sweep, isNull);
    expect(
      cubit.state.camera,
      CenterZoomCameraTarget(
        center: JourneyStops.ephesus.position,
        zoom: HistoricalJourneyCamera.arrivalZoom,
      ),
    );
  });
}

void _revealedViaTests() {
  test(
    'HistoricalJourneyCubit_revealedVia_neverRunsAheadOfTheCurrentRest',
    () {
      final cubit = HistoricalJourneyCubit(HistoricalJourneys.thirdJourney);
      addTearDown(cubit.close);
      final rest0 = HistoricalJourneys.thirdJourney.rests.first;
      final rest1 = HistoricalJourneys.thirdJourney.rests[1];

      expect(cubit.state.revealedVia, isEmpty);

      cubit.forward();
      expect(cubit.state.revealedVia, rest0.via);
      for (final via in rest1.via) {
        expect(cubit.state.revealedVia, isNot(contains(via)));
      }

      cubit.forward();
      expect(cubit.state.revealedVia, [...rest0.via, ...rest1.via]);
    },
  );
}

void _traceTests() {
  test('HistoricalJourneyCubit_trace_onTheOpeningStep_hasNotSetOff', () {
    final cubit = HistoricalJourneyCubit(HistoricalJourneys.thirdJourney);
    addTearDown(cubit.close);

    expect(cubit.state.trace.isUnderway, isFalse);
    expect(
      cubit.state.trace.trailAt(1).position,
      HistoricalStops.antioch.position,
    );
  });

  test(
    'HistoricalJourneyCubit_trace_walksFromThePreviousRestToTheCurrentOne',
    () {
      final cubit = HistoricalJourneyCubit(HistoricalJourneys.thirdJourney);
      addTearDown(cubit.close);

      cubit.forward();
      final atEphesus = cubit.state.trace;
      expect(atEphesus.isUnderway, isTrue);
      expect(atEphesus.trailAt(0).position, HistoricalStops.antioch.position);
      expect(atEphesus.trailAt(1).position, JourneyStops.ephesus.position);
      expect(
        atEphesus.trailAt(1).points.first,
        HistoricalStops.antioch.position,
      );

      cubit.forward();
      final atPhilippi = cubit.state.trace;
      // The stretch now under way sets out from the previous rest, not
      // from the origin — the whole first stretch is already behind it.
      expect(atPhilippi.trailAt(0).position, JourneyStops.ephesus.position);
      expect(
        atPhilippi.trailAt(1).position,
        HistoricalStops.philippi.position,
      );
      expect(
        atPhilippi.trailAt(1).points.first,
        HistoricalStops.antioch.position,
      );
    },
  );
}

void _romeJourneyTests() {
  test('HistoricalJourneyCubit_romeJourney_hasTwoSteps', () {
    final cubit = HistoricalJourneyCubit(HistoricalJourneys.romeJourney);
    addTearDown(cubit.close);

    expect(cubit.state.stepCount, 2);
    expect(cubit.state.step, isA<JourneyOpeningStep>());

    cubit.forward();
    expect(cubit.state.step, const RestStep(0));
    expect(cubit.state.currentStop, JourneyStops.rome);
    expect(cubit.state.beacon, isNull);
    expect(cubit.state.isAtEnd, isTrue);
    expect(
      cubit.state.revealedVia,
      HistoricalJourneys.romeJourney.rests.single.via,
    );
  });
}

void _stepBoundaryTests() {
  test('HistoricalJourneyCubit_forwardAtTheEnd_isANoOp', () {
    final cubit = HistoricalJourneyCubit(HistoricalJourneys.secondJourney);
    addTearDown(cubit.close);

    cubit.forward();
    expect(cubit.state.isAtEnd, isTrue);
    final step = cubit.state.stepIndex;

    cubit.forward();
    expect(cubit.state.stepIndex, step);
  });

  test('HistoricalJourneyCubit_backwardAtTheStart_isANoOp', () {
    final cubit = HistoricalJourneyCubit(HistoricalJourneys.secondJourney);
    addTearDown(cubit.close);

    cubit.backward();

    expect(cubit.state.stepIndex, 0);
    expect(cubit.state.step, isA<JourneyOpeningStep>());
  });
}

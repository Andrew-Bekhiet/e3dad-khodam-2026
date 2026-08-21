import 'package:e3dad_khodam_2026/src/data/game/journey_legs.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:flutter_test/flutter_test.dart';

/// The route geometry is generated, so its points are not asserted one by
/// one — that would only restate the Directions API. What is worth
/// holding is that the shipped data covers the shipped script, and that
/// every line starts and ends where its stops are.
const _repository = StaticLevelScriptRepository();

/// Every pair of stops the journey actually travels between, in order,
/// with a level that stays in the same city contributing nothing.
List<(JourneyStop, JourneyStop)> _travelledPairs() {
  final destinations = [
    for (final level in _repository.loadLevelScript().levels) level.destination,
  ];

  return [
    for (var index = 1; index < destinations.length; index++)
      if (destinations[index - 1].id != destinations[index].id)
        (destinations[index - 1], destinations[index]),
  ];
}

void main() {
  test('JourneyLegs_everyTravelledPair_hasRouteGeometry', () {
    for (final (from, to) in _travelledPairs()) {
      expect(
        JourneyLegs.geometryBetween(from.id, to.id),
        isNotNull,
        reason: 'no route charted for ${from.id} > ${to.id}',
      );
    }
  });

  test('JourneyLegs_everyRoute_runsBetweenItsOwnStops', () {
    for (final (from, to) in _travelledPairs()) {
      final route = JourneyLegs.geometryBetween(from.id, to.id);

      expect(
        route,
        isNotNull,
        reason: 'no route charted for ${from.id} > ${to.id}',
      );
      if (route == null) {
        continue;
      }

      expect(route.first, from.position, reason: '${from.id} > ${to.id}');
      expect(route.last, to.position, reason: '${from.id} > ${to.id}');
    }
  });

  test('JourneyLegs_everyRoute_hasEnoughPointsToDraw', () {
    for (final leg in JourneyLegs.all) {
      final route = JourneyLegs.geometryBetween(leg.from.id, leg.to.id);

      expect(
        route,
        isNotNull,
        reason: 'no route charted for ${leg.id}',
      );
      if (route == null) {
        continue;
      }

      expect(
        route.length,
        greaterThan(1),
        reason: '${leg.id} is not a line',
      );
    }
  });

  test('JourneyLegs_aLegTravelledBackwards_isTheSameWaterReversed', () {
    // أورشليم is only ever left for رومية along the same water the party
    // arrived on. The return trip must retrace the outward one exactly,
    // or the trail will show two different sea lanes between the stops.
    final out = JourneyLegs.geometryBetween('rome', 'jerusalem');
    final back = JourneyLegs.geometryBetween('jerusalem', 'rome');

    expect(out, isNotNull);
    expect(back, isNotNull);
    if (out == null || back == null) {
      return;
    }

    expect(back, out.reversed.toList());
  });

  test('JourneyLegs_noLeg_joinsAStopToItself', () {
    for (final leg in JourneyLegs.all) {
      expect(leg.from.id, isNot(leg.to.id));
    }
  });
}

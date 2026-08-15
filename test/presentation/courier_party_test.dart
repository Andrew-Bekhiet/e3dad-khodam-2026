import 'package:e3dad_khodam_2026/src/data/game/courier_route.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_characters.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart';
import 'package:flutter_test/flutter_test.dart';

/// A party of the real cast standing on [stops].
CourierParty _party(List<JourneyStop> stops) => CourierParty(
  couriers: PostOfficeCharacters.couriers,
  stops: stops,
);

void main() {
  test('CourierParty_beforeItHasMoved_isNotUnderway', () {
    final party = _party([JourneyStops.thessalonica]);

    expect(party.isUnderway, isFalse);
    expect(party.destination, JourneyStops.thessalonica);
    // A group standing still is on its stop whatever the walk says.
    expect(party.trailAt(0).position, JourneyStops.thessalonica.position);
    expect(party.trailAt(0.5).position, JourneyStops.thessalonica.position);
  });

  test('CourierParty_atTheEndOfItsWalk_drawsTheWholeJourney', () {
    final stops = [JourneyStops.thessalonica, JourneyStops.corinth];
    final trail = _party(stops).trailAt(1);

    expect(trail.points, CourierRoute.through(stops));
    expect(trail.position, JourneyStops.corinth.position);
    expect(trail.points.last, trail.position);
  });

  test('CourierParty_atTheStartOfItsWalk_isStillOnTheStopItLeft', () {
    final trail = _party([
      JourneyStops.thessalonica,
      JourneyStops.corinth,
    ]).trailAt(0);

    expect(trail.position, JourneyStops.thessalonica.position);
    expect(trail.points, [JourneyStops.thessalonica.position]);
  });

  test('CourierParty_partWayAlong_endsItsLineWhereItStands', () {
    final stops = [JourneyStops.thessalonica, JourneyStops.corinth];
    final trail = _party(stops).trailAt(0.5);
    final whole = CourierRoute.through(stops);

    expect(trail.points.last, trail.position);
    expect(trail.points.first, JourneyStops.thessalonica.position);
    expect(trail.points.length, lessThan(whole.length));
    expect(trail.position, isNot(JourneyStops.corinth.position));
  });

  test('CourierParty_walkingOn_onlyEverAddsToItsLine', () {
    final party = _party([
      JourneyStops.thessalonica,
      JourneyStops.corinth,
      JourneyStops.galatia,
    ]);

    var drawn = 0;
    for (var step = 0; step <= 10; step++) {
      final points = party.trailAt(step / 10).points;
      expect(points.length, greaterThanOrEqualTo(drawn));
      drawn = points.length;
    }
    expect(party.trailAt(1).position, JourneyStops.galatia.position);
  });

  test('CourierParty_aWalkOutsideItsLeg_isClamped', () {
    final party = _party([JourneyStops.thessalonica, JourneyStops.corinth]);

    expect(party.trailAt(-1), party.trailAt(0));
    expect(party.trailAt(2), party.trailAt(1));
  });

  test('CourierParty_theLegsBehindIt_areBuiltOnce', () {
    final party = _party([
      JourneyStops.thessalonica,
      JourneyStops.corinth,
      JourneyStops.galatia,
    ]);

    // Two walks along the same leg share the geometry behind it: the
    // completed legs depend on the stops alone, and a sweep asks for them
    // once a frame.
    final first = party.trailAt(0.25).points;
    final second = party.trailAt(0.75).points;

    expect(identical(first.first, second.first), isTrue);
    expect(party.trailAt(1).points, same(party.trailAt(1).points));
  });

  test('CourierParty_twoPartiesOnTheSameJourney_areEqual', () {
    final stops = [JourneyStops.thessalonica, JourneyStops.corinth];

    expect(_party(stops), _party([...stops]));
    expect(_party(stops), isNot(_party([JourneyStops.thessalonica])));
  });
}

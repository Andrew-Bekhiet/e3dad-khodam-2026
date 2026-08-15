import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_walk.dart';
import 'package:flutter_test/flutter_test.dart';

/// A leg whose two spans are deliberately lopsided: the first is one
/// degree long, the second nine. Anything that walks by point index
/// rather than by distance gives itself away on this route.
const _lopsided = [
  GeoPosition(latitude: 0, longitude: 0),
  GeoPosition(latitude: 0, longitude: 1),
  GeoPosition(latitude: 0, longitude: 10),
];

/// A leg that bends hard, so a walker cutting the corner is visible.
const _bent = [
  GeoPosition(latitude: 0, longitude: 0),
  GeoPosition(latitude: 5, longitude: 0),
  GeoPosition(latitude: 5, longitude: 5),
];

void main() {
  test('TrailWalk_atTheStart_standsOnTheFirstStop', () {
    final walk = TrailWalk.along(_lopsided, 0);

    expect(walk.position, _lopsided.first);
    expect(walk.travelled, [_lopsided.first]);
  });

  test('TrailWalk_atTheEnd_standsOnTheLastStop', () {
    final walk = TrailWalk.along(_lopsided, 1);

    expect(walk.position, _lopsided.last);
    expect(walk.travelled, _lopsided);
  });

  test('TrailWalk_halfway_measuresDistanceNotPointCount', () {
    // Half of the route's total length of ten degrees is five, which
    // falls four ninths of the way along the long second span. Walking
    // by point index would stop at the middle point, longitude 1.
    final walk = TrailWalk.along(_lopsided, 0.5);

    expect(walk.position.longitude, closeTo(5, 1e-9));
    expect(walk.position.latitude, closeTo(0, 1e-9));
  });

  test('TrailWalk_anywhere_endsTheTrailWhereTheWalkerStands', () {
    for (final progress in [0.0, 0.1, 0.25, 0.5, 0.75, 0.99, 1.0]) {
      final walk = TrailWalk.along(_bent, progress);

      expect(
        walk.travelled.last,
        walk.position,
        reason: 'trail parted from the walker at $progress',
      );
    }
  });

  test('TrailWalk_roundingABend_keepsTheCornerInTheTrail', () {
    // Three quarters along the bent route is past the corner, so the
    // corner must already be drawn behind the walker — a trail drawn as
    // start-to-walker alone would cut it off.
    final walk = TrailWalk.along(_bent, 0.75);

    expect(walk.travelled, contains(_bent[1]));
    expect(walk.travelled.length, 3);
  });

  test('TrailWalk_beforeTheBend_hasNotDrawnTheCornerYet', () {
    final walk = TrailWalk.along(_bent, 0.25);

    expect(walk.travelled, isNot(contains(_bent[1])));
  });

  test('TrailWalk_aSinglePosition_staysPutAtEveryProgress', () {
    const lone = [GeoPosition(latitude: 3, longitude: 4)];

    for (final progress in [0.0, 0.5, 1.0]) {
      final walk = TrailWalk.along(lone, progress);

      expect(walk.position, lone.first);
      expect(walk.travelled, lone);
    }
  });

  test('TrailWalk_progressOutsideTheRoute_isClampedToItsEnds', () {
    expect(TrailWalk.along(_lopsided, -1).position, _lopsided.first);
    expect(TrailWalk.along(_lopsided, 2).position, _lopsided.last);
  });

  test('TrailWalk_anEmptyRoute_isRejected', () {
    // Nobody can stand on a route with no positions. Throwing keeps
    // `position` non-null for every real caller, which is the same trade
    // `GeoBounds.containing` makes.
    expect(() => TrailWalk.along(const [], 0.5), throwsArgumentError);
  });
}

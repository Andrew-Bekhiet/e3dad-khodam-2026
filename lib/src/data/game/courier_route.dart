import 'package:e3dad_khodam_2026/src/data/game/journey_legs.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_trail.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// Turns the stops a courier has visited into the line their trail is
/// drawn along, by joining the route geometry of each leg between them.
///
/// A path with a stop the legs know nothing about contributes a straight
/// hop rather than nothing: a missing chart should show as a blunt line,
/// not as a courier who left no trail at all.
final class CourierRoute {
  /// The whole route through [path].
  ///
  /// An undrawn leg does not join what is either side of it — it starts
  /// the line again where it lands. Carrying on would stretch the trail
  /// across the very gap that is meant to leave no mark.
  static List<GeoPosition> through(List<JourneyStop> path) {
    if (path.isEmpty) {
      return const [];
    }

    var route = <GeoPosition>[path.first.position];
    for (var index = 1; index < path.length; index++) {
      final from = path[index - 1];
      final to = path[index];
      switch (JourneyLegs.trailOf(from.id, to.id)) {
        case LegTrail.undrawn:
          route = <GeoPosition>[to.position];
        case LegTrail.drawn:
          route.addAll(_leg(from, to).skip(1));
      }
    }

    return route;
  }

  /// The route through every stop except the last — where the courier
  /// had already been before the leg they are walking now.
  static List<GeoPosition> beforeLastLeg(List<JourneyStop> path) =>
      path.length < 2
      ? through(path)
      : through(path.sublist(0, path.length - 1));

  /// The geometry of the final leg, the one a courier walks while the
  /// camera comes in.
  ///
  /// An undrawn leg is not walked either, so it is the single point the
  /// party waits on: they are still where they set out from until the
  /// camera lands, and then they are simply at the far end.
  static List<GeoPosition> lastLeg(List<JourneyStop> path) {
    if (path.length < 2) {
      return [if (path.isNotEmpty) path.first.position];
    }
    final from = path[path.length - 2];
    final to = path.last;

    return switch (JourneyLegs.trailOf(from.id, to.id)) {
      LegTrail.undrawn => [from.position],
      LegTrail.drawn => _leg(from, to),
    };
  }

  /// The chart between two stops, or a blunt straight line when none has
  /// been drawn yet — a missing chart should show as a crude line rather
  /// than as a courier who left no trail at all.
  static List<GeoPosition> _leg(JourneyStop from, JourneyStop to) =>
      JourneyLegs.geometryBetween(from.id, to.id) ??
      [from.position, to.position];

  const CourierRoute._();
}

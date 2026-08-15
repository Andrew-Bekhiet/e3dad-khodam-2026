import 'package:e3dad_khodam_2026/src/data/game/journey_legs.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// Turns the stops a courier has visited into the line their trail is
/// drawn along, by joining the route geometry of each leg between them.
///
/// A path with a stop the legs know nothing about contributes a straight
/// hop rather than nothing: a missing chart should show as a blunt line,
/// not as a courier who left no trail at all.
final class CourierRoute {
  /// The whole route through [path].
  static List<GeoPosition> through(List<JourneyStop> path) {
    if (path.isEmpty) {
      return const [];
    }

    final route = <GeoPosition>[path.first.position];
    for (var index = 1; index < path.length; index++) {
      route.addAll(_leg(path[index - 1], path[index]).skip(1));
    }

    return route;
  }

  /// The route through every stop except the last — where the courier
  /// had already been before the leg they are walking now.
  static List<GeoPosition> beforeLastLeg(List<JourneyStop> path) =>
      path.length < 2 ? through(path) : through(path.sublist(0, path.length - 1));

  /// The geometry of the final leg, the one a courier walks while the
  /// camera comes in.
  static List<GeoPosition> lastLeg(List<JourneyStop> path) => path.length < 2
      ? [if (path.isNotEmpty) path.first.position]
      : _leg(path[path.length - 2], path.last);

  static List<GeoPosition> _leg(JourneyStop from, JourneyStop to) =>
      JourneyLegs.geometryBetween(from.id, to.id) ??
      [from.position, to.position];

  const CourierRoute._();
}

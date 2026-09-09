import 'package:e3dad_khodam_2026/src/data/game/journey_legs.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/routing/route_line.dart';

/// Turns the stops a courier has visited into the line their trail is
/// drawn along, by joining the route geometry of each leg between them.
///
/// A thin wrapper over [RouteLine] joined out of the game's own legs — the
/// game's own legs — kept so CourierParty and its tests need not know
/// that a [RouteLine] exists.
final class CourierRoute {
  static const RouteLine _line = RouteLine(JourneyLegs.charted);

  /// The whole route through [path].
  static List<GeoPosition> through(List<JourneyStop> path) =>
      _line.through(path);

  /// The route through every stop except the last — where the courier
  /// had already been before the leg they are walking now.
  static List<GeoPosition> beforeLastLeg(List<JourneyStop> path) =>
      _line.beforeLastLeg(path);

  /// The geometry of the final leg, the one a courier walks while the
  /// camera comes in.
  static List<GeoPosition> lastLeg(List<JourneyStop> path) =>
      _line.lastLeg(path);

  const CourierRoute._();
}

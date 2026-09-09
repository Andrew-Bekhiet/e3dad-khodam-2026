import 'package:e3dad_khodam_2026/src/domain/game/leg_trail.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// The set of legs a route can be joined out of.
///
/// A RouteLine asks this for the geometry and the trail behaviour
/// between two stop ids; it does not know or care whose legs they are.
abstract interface class LegAtlas {
  /// The line to draw between the stops [fromId] and [toId], or null when
  /// no leg joins them.
  List<GeoPosition>? geometryBetween(String fromId, String toId);

  /// Whether the leg between [fromId] and [toId] leaves a line behind it.
  LegTrail trailOf(String fromId, String toId);
}

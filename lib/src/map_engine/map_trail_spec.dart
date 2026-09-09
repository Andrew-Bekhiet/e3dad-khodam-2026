import 'dart:ui';

import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';

/// One dashed path drawn on the map: the route a character has already
/// travelled, as an ordered list of stops.
///
/// A trail is its own concept rather than a kind of marker because it is
/// a line, not a point — and because several characters can be on the
/// move at once, each leaving its own trail behind it.
final class MapTrailSpec extends Equatable {
  /// Stable identifier, unique among the trails in one spec. Usually the
  /// id of the character whose route this is.
  final String id;

  /// The stops the line runs through, oldest first. Fewer than two points
  /// draws nothing — a journey needs somewhere to have come from.
  final List<GeoPosition> points;

  /// How the line is stroked.
  final MapTrailStyle style;

  @override
  List<Object?> get props => [id, points, style];

  /// Creates a trail.
  const MapTrailSpec({
    required this.id,
    required this.points,
    required this.style,
  });
}

/// The stroke of a [MapTrailSpec]. The dash pattern itself is fixed
/// style-wide in `TrailLayer`: `line-dasharray` is one of the few Mapbox
/// properties that cannot be driven from feature data.
final class MapTrailStyle extends Equatable {
  /// The white dashed route of the design mockup, legible over both the
  /// green land and the blue sea of the pixel basemap.
  static const MapTrailStyle travelled = MapTrailStyle(
    color: Color(0xFFFFFFFF),
    width: 4.0,
    opacity: 1.0,
  );

  /// The historical journeys' own line: heavier than [travelled] because
  /// this map is projected on a TV and read from up to 10 metres across a
  /// hall rather than held in the hand, and the six-second sweep hold
  /// spends its whole span watching this exact line draw itself — it has
  /// to carry as the content, not just mark the route underneath it.
  static const MapTrailStyle historicalTravelled = MapTrailStyle(
    color: Color(0xFFFFFFFF),
    width: 10.0,
    opacity: 1.0,
  );

  /// Line colour.
  final Color color;

  /// Stroke width in logical pixels.
  final double width;

  /// Stroke opacity, `0..1`.
  final double opacity;

  @override
  List<Object?> get props => [color, width, opacity];

  /// Creates a trail stroke.
  const MapTrailStyle({
    required this.color,
    required this.width,
    required this.opacity,
  });
}

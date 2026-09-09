import 'dart:math';

import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';

/// Where a courier stands part-way along a leg, and how much of that
/// leg's trail is drawn behind them.
///
/// One computation answers both, because they are the same point: the
/// trail ends exactly where the walker is. Progress is measured by
/// *distance* along the route, not by how many positions have been
/// passed — route geometry comes back from the road service with its
/// points bunched at junctions, and walking by index would make a
/// courier crawl through towns and sprint across open country.
///
/// Distance is planar in degrees rather than great-circle. The whole map
/// is one basin, the difference is far below a pixel at these zooms, and
/// `TrailCurve` already interpolates in the same space.
final class TrailWalk extends Equatable {
  /// The straight-line length of each span between consecutive positions.
  static List<double> _spanLengths(List<GeoPosition> route) => [
    for (var index = 0; index < route.length - 1; index++)
      _distance(route[index], route[index + 1]),
  ];

  /// The straight-line length of [route], in degrees — the same metric
  /// [TrailWalk.along] measures progress by, so a fraction of this is a
  /// fraction of the walk.
  static double lengthOf(List<GeoPosition> route) =>
      _spanLengths(route).fold<double>(0, (sum, span) => sum + span);

  static double _distance(GeoPosition from, GeoPosition to) {
    final dLatitude = to.latitude - from.latitude;
    final dLongitude = to.longitude - from.longitude;

    return sqrt(dLatitude * dLatitude + dLongitude * dLongitude);
  }

  static GeoPosition _lerp(GeoPosition from, GeoPosition to, double t) =>
      GeoPosition(
        latitude: from.latitude + (to.latitude - from.latitude) * t,
        longitude: from.longitude + (to.longitude - from.longitude) * t,
      );

  /// Where the courier stands.
  final GeoPosition position;

  /// The route drawn so far, ending on [position].
  final List<GeoPosition> travelled;

  @override
  List<Object?> get props => [position, travelled];

  const TrailWalk._({required this.position, required this.travelled});

  /// The walk along [route] at [progress], a fraction from `0` to `1`
  /// which is clamped to those ends.
  ///
  /// Throws [ArgumentError] if [route] is empty: nobody can stand on a
  /// route with no positions.
  factory TrailWalk.along(List<GeoPosition> route, double progress) {
    if (route.isEmpty) {
      throw ArgumentError.value(route, 'route', 'must not be empty');
    }
    if (route.length == 1) {
      return TrailWalk._(position: route.first, travelled: route);
    }

    final spans = _spanLengths(route);
    final total = spans.fold<double>(0, (sum, span) => sum + span);
    if (total == 0) {
      return TrailWalk._(position: route.first, travelled: [route.first]);
    }

    var remaining = progress.clamp(0.0, 1.0) * total;
    for (var index = 0; index < spans.length; index++) {
      final span = spans[index];
      if (remaining > span && index < spans.length - 1) {
        remaining -= span;
        continue;
      }

      final t = span == 0 ? 0.0 : (remaining / span).clamp(0.0, 1.0);
      final position = _lerp(route[index], route[index + 1], t);

      return TrailWalk._(
        position: position,
        // At `t == 0` the walker is standing on `route[index]`, which is
        // already the last point taken — appending would draw it twice.
        travelled: [...route.take(index + 1), if (t > 0) position],
      );
    }

    // Unreachable: the loop always returns on its last span.
    return TrailWalk._(position: route.last, travelled: route);
  }
}

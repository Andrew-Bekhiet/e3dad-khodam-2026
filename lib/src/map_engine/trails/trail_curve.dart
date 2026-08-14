import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';

/// Turns the stops of a route into the curved line the map draws.
///
/// A journey between cities was never a straight line, and the design
/// mockup shows it as a sweeping dashed curve — so the stops are treated
/// as control points of a cardinal spline and sampled into a dense
/// polyline. Mapbox has no curve primitive: a smooth line *is* a
/// many-segment line, and this is where those segments come from.
final class TrailCurve {
  /// Points generated per span between two stops. Enough that the curve
  /// reads as smooth at every zoom the game uses, without turning a
  /// fourteen-stop route into thousands of coordinates.
  static const int samplesPerSpan = 16;

  /// How far the curve is allowed to bow away from the straight line
  /// between two stops. `0` is a polyline; `1` is the textbook
  /// Catmull-Rom curve; the value here overshoots it slightly so the
  /// route arcs the way the mockup's does.
  static const double curviness = 1.3;

  /// A line needs two ends before it can be curved at all.
  static const int _minimumPoints = 2;

  /// Samples a smooth curve through [stops], which it always passes
  /// exactly through. Returns [stops] unchanged when there is nothing to
  /// interpolate.
  static List<GeoPosition> through(List<GeoPosition> stops) {
    if (stops.length < _minimumPoints) {
      return stops;
    }
    final curve = <GeoPosition>[];
    for (var span = 0; span < stops.length - 1; span++) {
      final start = stops[span];
      final end = stops[span + 1];
      // The neighbours give the curve its direction of travel into and
      // out of the span; at the ends of the route there is none, so the
      // span's own endpoint stands in and the curve leaves straight.
      final before = span == 0 ? start : stops[span - 1];
      final after = span + 2 >= stops.length ? end : stops[span + 2];
      final startTangent = _tangent(before, end);
      final endTangent = _tangent(start, after);
      for (var sample = 0; sample < samplesPerSpan; sample++) {
        curve.add(
          _hermite(
            start,
            end,
            startTangent,
            endTangent,
            sample / samplesPerSpan,
          ),
        );
      }
    }

    return [...curve, stops.last];
  }

  /// Half the vector between a point's neighbours, scaled by
  /// [curviness] — the classic cardinal-spline tangent.
  static GeoPosition _tangent(GeoPosition before, GeoPosition after) =>
      GeoPosition(
        latitude: curviness * (after.latitude - before.latitude) / 2,
        longitude: curviness * (after.longitude - before.longitude) / 2,
      );

  /// The cubic Hermite point at [t] (`0..1`) along a span.
  static GeoPosition _hermite(
    GeoPosition start,
    GeoPosition end,
    GeoPosition startTangent,
    GeoPosition endTangent,
    double t,
  ) {
    final t2 = t * t;
    final t3 = t2 * t;
    final startWeight = 2 * t3 - 3 * t2 + 1;
    final startTangentWeight = t3 - 2 * t2 + t;
    final endWeight = -2 * t3 + 3 * t2;
    final endTangentWeight = t3 - t2;

    return GeoPosition(
      latitude:
          startWeight * start.latitude +
          startTangentWeight * startTangent.latitude +
          endWeight * end.latitude +
          endTangentWeight * endTangent.latitude,
      longitude:
          startWeight * start.longitude +
          startTangentWeight * startTangent.longitude +
          endWeight * end.longitude +
          endTangentWeight * endTangent.longitude,
    );
  }

  const TrailCurve._();
}

// Generates route geometry for the game and the historical journeys into
// `lib/src/data/game/route_geometry.dart` and
// `lib/src/data/history/historical_route_geometry.dart`.
//
// Run by hand, never at build time:
//
//   MAPBOX_ACCESS_TOKEN=pk.… dart run tool/generate_route_geometry.dart
//
// Land legs are fetched from the Mapbox Directions API with
// `overview=simplified`, which is where the simplification comes from —
// the service returns a geometry already sized for display, so there is
// no client-side thinning pass here. Sea legs are charted by hand in
// `JourneyLegs` and `HistoricalLegs`, and smoothed through `TrailCurve`,
// because no road service will route across the Aegean.
//
// A failed land leg stops the script. It does not fall back to a
// straight line: a wrong route that looks plausible is worse than a
// generator that refuses to finish.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:e3dad_khodam_2026/src/data/game/journey_legs.dart';
import 'package:e3dad_khodam_2026/src/data/history/historical_legs.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_leg.dart';
import 'package:e3dad_khodam_2026/src/domain/game/leg_kind.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_curve.dart';

/// The environment variable the Directions token is read from.
const String tokenKey = 'MAPBOX_ACCESS_TOKEN';

/// Decimal places kept per coordinate. Five is a little over a metre,
/// far finer than anything visible at the zooms this map uses, and it
/// keeps the generated file readable.
const int coordinatePrecision = 5;

/// One geometry file to generate: which legs feed it, what class its
/// output takes the shape of, and where it is written.
///
/// A record rather than a class, so this script — which has no class of
/// its own to name — stays clear of `prefer_match_file_name`.
typedef _Target = ({
  String className,
  String outputPath,
  String sourceDescription,

  // What each line traces, for the doc comment's opening sentence —
  // "the journey" for the game, "the historical journeys" for history.
  String tracedDescription,

  // Who the doc comment credits with drawing its own history — "game"
  // or "app". Kept a parameter so the game's regenerated file is
  // byte-identical to the one already committed.
  String subject,
  List<JourneyLeg> legs,

  // Douglas-Peucker tolerance, in degrees, applied to every leg before
  // writing. Zero leaves a leg's geometry untouched — the game's legs are
  // short and stay at road fidelity, so its target keeps this at zero and
  // its regenerated file stays byte-identical to the one already
  // committed.
  double simplifyToleranceDegrees,
});

const List<_Target> _targets = [
  (
    className: 'RouteGeometry',
    outputPath: 'lib/src/data/game/route_geometry.dart',
    sourceDescription: 'JourneyLegs',
    tracedDescription: 'journey',
    subject: 'game',
    legs: JourneyLegs.all,
    simplifyToleranceDegrees: 0,
  ),
  (
    className: 'HistoricalRouteGeometry',
    outputPath: 'lib/src/data/history/historical_route_geometry.dart',
    sourceDescription: 'HistoricalLegs',
    tracedDescription: 'historical journeys',
    subject: 'app',
    legs: HistoricalLegs.all,
    // The historical stretches run through up to fifteen legs joined end
    // to end and are swept over for a six-second hold, so their raw
    // road/curve fidelity is real per-frame cost the game's short legs
    // never pay. ~0.005 degrees (~500m at these latitudes) is the
    // tolerance that halves the point count while keeping every
    // headland and strait the sea charts were hand-routed around: it is
    // an order of magnitude below the size of the land features the
    // charted legs thread between. See CONTRACT.md / the bug report for
    // the measurements this was picked from.
    simplifyToleranceDegrees: 0.005,
  ),
];

Future<void> main() async {
  final token = Platform.environment[tokenKey];
  if (token == null || token.isEmpty) {
    stderr.writeln('$tokenKey is not set. Export it and run again.');
    exitCode = 1;

    return;
  }

  final client = HttpClient();
  try {
    for (final target in _targets) {
      final geometries = <String, List<GeoPosition>>{};
      for (final leg in target.legs) {
        stdout.writeln('${leg.id} (${leg.kind.name})');
        final geometry = switch (leg.kind) {
          LegKind.land => await _fetchRoad(client, leg, token),
          LegKind.sea => _chartSea(leg),
        };
        geometries[leg.id] = _simplify(
          geometry,
          target.simplifyToleranceDegrees,
        );
      }

      File(
        target.outputPath,
      ).writeAsStringSync(_render(target, geometries));
      stdout.writeln('\nWrote ${target.outputPath}');
    }
  } finally {
    client.close();
  }
}

/// Fetches a land leg's shape from the Directions API.
///
/// Throws if the service answers with anything other than a route, which
/// is deliberate: كريت and the sea legs are typed `sea` precisely so this
/// is never asked a question it cannot answer, and a leg that is typed
/// wrong should stop the generator rather than quietly draw a line.
Future<List<GeoPosition>> _fetchRoad(
  HttpClient client,
  JourneyLeg leg,
  String token,
) async {
  final uri = Uri.https(
    'api.mapbox.com',
    '/directions/v5/mapbox/driving/'
        '${_pair(leg.from.position)};${_pair(leg.to.position)}',
    {
      'geometries': 'geojson',
      'overview': 'simplified',
      'access_token': token,
    },
  );

  final request = await client.getUrl(uri);
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  if (response.statusCode != HttpStatus.ok) {
    throw StateError(
      'Directions API returned ${response.statusCode} for ${leg.id}: $body',
    );
  }

  final routes = (jsonDecode(body) as Map<String, Object?>)['routes'];
  if (routes is! List || routes.isEmpty) {
    throw StateError('Directions API found no route for ${leg.id}: $body');
  }

  final geometry =
      (routes.first as Map<String, Object?>)['geometry']!
          as Map<String, Object?>;
  final coordinates = geometry['coordinates']! as List;
  final road = [
    for (final point in coordinates)
      GeoPosition(
        latitude: ((point as List)[1] as num).toDouble(),
        longitude: (point.first as num).toDouble(),
      ),
  ];

  // The service snaps each end to the nearest road, landing a few metres
  // off the gazetteer. Invisible at these zooms, but it would leave a
  // courier standing just beside their own marker, so pin both ends.
  return [
    leg.from.position,
    ...road.skip(1).take(road.length - 2),
    leg.to.position,
  ];
}

/// Smooths a sea leg's hand-picked chart, with its two stops at the ends.
List<GeoPosition> _chartSea(JourneyLeg leg) => TrailCurve.through([
  leg.from.position,
  ...leg.chart,
  leg.to.position,
]);

/// Thins [points] by the Douglas-Peucker algorithm, dropping any point
/// within [toleranceDegrees] of the straight line between its surviving
/// neighbours. The two ends always survive.
///
/// Planar in degrees, like `TrailWalk`'s own distance metric: the error
/// from skipping the latitude/longitude scale correction is far below
/// the tolerances in play here.
List<GeoPosition> _simplify(List<GeoPosition> points, double toleranceDegrees) {
  if (toleranceDegrees <= 0 || points.length < 3) {
    return points;
  }
  final keep = List<bool>.filled(points.length, false)
    ..first = true
    ..last = true;
  _simplifySpan(points, 0, points.length - 1, toleranceDegrees, keep);

  return [
    for (var index = 0; index < points.length; index++)
      if (keep[index]) points[index],
  ];
}

/// Keeps whichever point between [start] and [end] strays furthest from
/// the straight line joining them, then recurses either side of it — the
/// classic Douglas-Peucker recursion, applied in place onto [keep].
void _simplifySpan(
  List<GeoPosition> points,
  int start,
  int end,
  double toleranceDegrees,
  List<bool> keep,
) {
  if (end <= start + 1) {
    return;
  }
  var farthestDistance = 0.0;
  var farthestIndex = -1;
  for (var index = start + 1; index < end; index++) {
    final distance = _perpendicularDistance(
      points[index],
      points[start],
      points[end],
    );
    if (distance > farthestDistance) {
      farthestDistance = distance;
      farthestIndex = index;
    }
  }
  if (farthestIndex == -1 || farthestDistance <= toleranceDegrees) {
    return;
  }
  keep[farthestIndex] = true;
  _simplifySpan(points, start, farthestIndex, toleranceDegrees, keep);
  _simplifySpan(points, farthestIndex, end, toleranceDegrees, keep);
}

/// The perpendicular distance from [point] to the line through [lineStart]
/// and [lineEnd], in degrees. Falls back to the straight-line distance to
/// [lineStart] when the two ends coincide.
double _perpendicularDistance(
  GeoPosition point,
  GeoPosition lineStart,
  GeoPosition lineEnd,
) {
  final dx = lineEnd.longitude - lineStart.longitude;
  final dy = lineEnd.latitude - lineStart.latitude;
  if (dx == 0 && dy == 0) {
    final ddx = point.longitude - lineStart.longitude;
    final ddy = point.latitude - lineStart.latitude;

    return sqrt(ddx * ddx + ddy * ddy);
  }
  final numerator =
      (dy * point.longitude -
              dx * point.latitude +
              lineEnd.longitude * lineStart.latitude -
              lineEnd.latitude * lineStart.longitude)
          .abs();

  return numerator / sqrt(dx * dx + dy * dy);
}

/// A coordinate as the Directions API wants it: longitude first.
String _pair(GeoPosition position) =>
    '${position.longitude},${position.latitude}';

/// A coordinate as a Dart double literal, rounded and with its trailing
/// zeros dropped — `double_literal_format` rejects `40.64010`, and the
/// generated file has to pass the same analyzer as everything else.
String _number(double value) {
  final fixed = value.toStringAsFixed(coordinatePrecision);
  final trimmed = fixed.contains('.')
      ? fixed.replaceAll(RegExp(r'0+$'), '')
      : fixed;

  return trimmed.endsWith('.') ? '${trimmed}0' : trimmed;
}

String _render(_Target target, Map<String, List<GeoPosition>> geometries) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED BY tool/generate_route_geometry.dart')
    ..writeln(
      '// Do not edit by hand. Change ${target.sourceDescription} and re-run.',
    )
    ..writeln()
    ..writeln(
      "import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';",
    )
    ..writeln()
    ..writeln(
      '/// The fixed line each leg of the ${target.tracedDescription} is drawn along.',
    )
    ..writeln('///')
    ..writeln('/// Land legs come from the Mapbox Directions API; sea legs are')
    ..writeln(
      '/// charted by hand in `${target.sourceDescription}`. Both are baked in here so',
    )
    ..writeln(
      '/// the ${target.subject} draws its own history with no network and no token.',
    )
    ..writeln('final class ${target.className} {')
    ..writeln('  /// Every leg, by `from>to` id.')
    ..writeln('  static const Map<String, List<GeoPosition>> byLegId = {');

  for (final entry in geometries.entries) {
    buffer.writeln("    '${entry.key}': [");
    for (final position in entry.value) {
      buffer
        ..write('      GeoPosition(latitude: ')
        ..write(_number(position.latitude))
        ..write(', longitude: ')
        ..write(_number(position.longitude))
        ..writeln('),');
    }
    buffer.writeln('    ],');
  }

  buffer
    ..writeln('  };')
    ..writeln()
    ..writeln('  const ${target.className}._();')
    ..writeln('}');

  return buffer.toString();
}

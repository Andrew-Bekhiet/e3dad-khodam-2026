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
});

const List<_Target> _targets = [
  (
    className: 'RouteGeometry',
    outputPath: 'lib/src/data/game/route_geometry.dart',
    sourceDescription: 'JourneyLegs',
    tracedDescription: 'journey',
    subject: 'game',
    legs: JourneyLegs.all,
  ),
  (
    className: 'HistoricalRouteGeometry',
    outputPath: 'lib/src/data/history/historical_route_geometry.dart',
    sourceDescription: 'HistoricalLegs',
    tracedDescription: 'historical journeys',
    subject: 'app',
    legs: HistoricalLegs.all,
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
        geometries[leg.id] = switch (leg.kind) {
          LegKind.land => await _fetchRoad(client, leg, token),
          LegKind.sea => _chartSea(leg),
        };
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

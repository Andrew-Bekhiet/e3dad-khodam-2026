import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/geo_json_encoder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const markerStyle = MapMarkerStyle(
    id: 'marker',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 40,
      color: Color(0xFF0288D1),
    ),
    shadow: null,
    glyph: null,
    label: MapMarkerLabelStyle(
      fontSize: 10,
      color: Color(0xFF102030),
      haloColor: Color(0xFFFFFFFF),
      haloWidth: 2,
      gap: 5,
    ),
  );
  const position = GeoPosition(latitude: 31.5, longitude: 30.25);

  test('encodes marker coordinates and rendering properties', () {
    final collection = GeoJsonEncoder.markers([
      const MapMarkerSpec(
        id: 'sea',
        position: position,
        label: 'البحر',
        style: markerStyle,
        isInteractive: true,
      ),
    ]);
    final feature = switch (collection['features']) {
      [final Map<String, Object?> feature] => feature,
      _ => fail('expected one marker feature'),
    };
    final geometry = feature['geometry']! as Map<String, Object?>;
    final properties = feature['properties']! as Map<String, Object?>;

    expect(geometry['coordinates'], [30.25, 31.5]);
    expect(properties['markerId'], 'sea');
    expect(properties['labelOffsetEms'], [0.0, 2.5]);
    expect(properties['labelColor'], '#102030');
  });

  test('encodes token offsets and omits one-point trails', () {
    const tokenStyle = MapTokenStyle(
      id: 'courier',
      portraitAsset: 'assets/courier.png',
      diameter: 48,
      ringColor: Color(0xFFFFFFFF),
      ringWidth: 2,
      fallbackColor: Color(0xFF000000),
    );
    final tokenCollection = GeoJsonEncoder.tokens([
      const MapTokenSpec(
        id: 'paul',
        position: position,
        style: tokenStyle,
        offset: Offset(2, -3),
      ),
    ]);
    final token = switch (tokenCollection['features']) {
      [final Map<String, Object?> feature] => feature,
      _ => fail('expected one token feature'),
    };
    final tokenProperties = token['properties']! as Map<String, Object?>;

    expect(tokenProperties['tokenSprite'], 'courier');
    expect(tokenProperties['tokenOffset'], [2.0, -3.0]);
    expect(
      GeoJsonEncoder.trails([
        const MapTrailSpec(
          id: 'one-stop',
          points: [position],
          style: MapTrailStyle.travelled,
        ),
      ])['features'],
      isEmpty,
    );
  });

  test('encodes trail points in GeoJSON axis order', () {
    final collection = GeoJsonEncoder.trails([
      const MapTrailSpec(
        id: 'route',
        points: [position, GeoPosition(latitude: 32, longitude: 31)],
        style: MapTrailStyle.travelled,
      ),
    ]);
    final feature = switch (collection['features']) {
      [final Map<String, Object?> feature] => feature,
      _ => fail('expected one trail feature'),
    };
    final geometry = feature['geometry']! as Map<String, Object?>;

    expect(geometry['coordinates'], [
      [30.25, 31.5],
      [31.0, 32.0],
    ]);
  });
}

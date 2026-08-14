import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/tokens/token_layer.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_curve.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_layer.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _a = GeoPosition(latitude: 40.64, longitude: 22.94);
const _b = GeoPosition(latitude: 37.91, longitude: 22.88);
const _c = GeoPosition(latitude: 39.5, longitude: 32.9);

const _tokenStyle = MapTokenStyle(
  id: 'token-test',
  portraitAsset: 'assets/characters/postman1-avatar.jpg',
  diameter: 54,
  ringColor: Color(0xFFFFFFFF),
  ringWidth: 4,
  fallbackColor: Color(0xFFC77B00),
);

/// The coordinate pairs of the single feature in [trails].
List<List<double>> _coordinatesOf(List<MapTrailSpec> trails) {
  final feature = _featuresOf(TrailLayer.featureCollection(trails)).single;
  final geometry = feature['geometry']! as Map<String, Object?>;

  return (geometry['coordinates']! as List).cast<List<double>>();
}

/// The features of a GeoJSON `FeatureCollection`, typed.
List<Map<String, Object?>> _featuresOf(Map<String, Object?> collection) =>
    (collection['features']! as List).cast<Map<String, Object?>>();

void main() {
  _curveTests();
  _layerTests();
}

void _curveTests() {
  test('TrailCurve_withFewerThanTwoStops_isLeftAlone', () {
    expect(TrailCurve.through(const []), isEmpty);
    expect(TrailCurve.through(const [_a]), [_a]);
  });

  test('TrailCurve_alwaysPassesThroughEveryStop', () {
    final curve = TrailCurve.through(const [_a, _b, _c]);

    expect(curve.first, _a);
    expect(curve.last, _c);
    expect(curve, contains(_b));
  });

  test('TrailCurve_densifiesEachSpan', () {
    final curve = TrailCurve.through(const [_a, _b, _c]);

    // Two spans, each sampled, plus the closing stop.
    expect(curve, hasLength(TrailCurve.samplesPerSpan * 2 + 1));
  });

  test('TrailCurve_bowsAwayFromTheStraightLine', () {
    final curve = TrailCurve.through(const [_a, _b, _c]);
    // The midpoint of the first span, had it been drawn straight.
    final straightLatitude = (_a.latitude + _b.latitude) / 2;
    final straightLongitude = (_a.longitude + _b.longitude) / 2;
    final midpoint = curve[TrailCurve.samplesPerSpan ~/ 2];

    expect(
      (midpoint.latitude - straightLatitude).abs() +
          (midpoint.longitude - straightLongitude).abs(),
      greaterThan(0.01),
    );
  });
}

void _layerTests() {
  test('TrailLayer_feature_carriesTheCurveNotTheRawStops', () {
    const trail = MapTrailSpec(
      id: 'courier1',
      points: [_a, _b, _c],
      style: MapTrailStyle.travelled,
    );

    final coordinates = _coordinatesOf(const [trail]);

    expect(coordinates, hasLength(TrailCurve.through(trail.points).length));
    expect(coordinates.first, [_a.longitude, _a.latitude]);
    expect(coordinates.last, [_c.longitude, _c.latitude]);
  });

  test('TrailLayer_featureCollection_dropsSingleStopTrails', () {
    const trail = MapTrailSpec(
      id: 'courier1',
      points: [_a],
      style: MapTrailStyle.travelled,
    );

    expect(_featuresOf(TrailLayer.featureCollection(const [trail])), isEmpty);
  });

  test('TokenLayer_feature_carriesTheTokensScreenOffset', () {
    const token = MapTokenSpec(
      id: 'courier2',
      position: _a,
      style: _tokenStyle,
      offset: Offset(17, 0),
    );

    final feature = _featuresOf(
      TokenLayer.featureCollection(const [token]),
    ).single;
    final properties = feature['properties']! as Map<String, Object?>;

    expect(properties['tokenOffset'], [17.0, 0.0]);
  });
}

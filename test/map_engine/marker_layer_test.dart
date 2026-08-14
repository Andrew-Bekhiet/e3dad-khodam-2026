import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/marker_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const style = MapMarkerStyle(
    id: 'marker-test',
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

  const marker = MapMarkerSpec(
    id: 'sea-1',
    position: GeoPosition(latitude: 31.5, longitude: 30.25),
    label: 'البحر',
    style: style,
    isInteractive: true,
  );

  Map<String, Object?> featureOf(MapMarkerSpec spec) {
    if (MarkerLayer.featureCollection([spec])['features']
        case [final Map<String, Object?> feature]) {
      return feature;
    }

    return fail('expected exactly one feature');
  }

  Map<String, Object?> memberOf(MapMarkerSpec spec, String key) {
    if (featureOf(spec)[key] case final Map<String, Object?> member) {
      return member;
    }

    return fail('expected a "$key" object on the feature');
  }

  Map<String, Object?> propertiesOf(MapMarkerSpec spec) =>
      memberOf(spec, 'properties');

  test('writes lon/lat in GeoJSON axis order', () {
    expect(memberOf(marker, 'geometry')['coordinates'], [30.25, 31.5]);
  });

  test('round-trips the marker id through feature properties', () {
    expect(MarkerLayer.idOf(propertiesOf(marker)), 'sea-1');
  });

  test('reports interactivity from feature properties', () {
    expect(MarkerLayer.isInteractive(propertiesOf(marker)), isTrue);
    expect(
      MarkerLayer.isInteractive(
        propertiesOf(
          const MapMarkerSpec(
            id: 'city-1',
            position: GeoPosition(latitude: 0, longitude: 0),
            label: 'مدينة',
            style: style,
            isInteractive: false,
          ),
        ),
      ),
      isFalse,
    );
  });

  test('offsets the label clear of the shape, in ems of its own size', () {
    // Half of a 40px shape plus a 5px gap is 25px, which at a 10px font
    // is 2.5em. Anything less would overlap the artwork.
    expect(propertiesOf(marker)['labelOffsetEms'], [0.0, 2.5]);
  });

  test('emits colours as CSS hex, which is what Mapbox parses', () {
    expect(propertiesOf(marker)['labelColor'], '#102030');
    expect(propertiesOf(marker)['labelHaloColor'], '#ffffff');
  });

  test('collapses markers sharing a style to one image', () {
    final styles = MarkerLayer.stylesOf([
      marker,
      const MapMarkerSpec(
        id: 'sea-2',
        position: GeoPosition(latitude: 1, longitude: 2),
        label: 'آخر',
        style: style,
        isInteractive: true,
      ),
    ]);

    expect(styles, hasLength(1));
    expect(styles.single.id, 'marker-test');
  });

  test('names the source the layer draws from', () {
    expect(MarkerLayer.layer()['source'], MarkerLayer.sourceId);
    expect(MarkerLayer.source([marker])['type'], 'geojson');
  });
}

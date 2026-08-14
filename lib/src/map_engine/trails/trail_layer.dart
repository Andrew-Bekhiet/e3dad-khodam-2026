import 'dart:ui';

import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_style_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_curve.dart';

/// Builds the GeoJSON source and line layer the travelled routes are
/// drawn by.
///
/// One `geojson` source and one `line` layer whose colour, width and
/// opacity come from each feature's own properties — so any number of
/// characters' trails cost exactly one layer. Shared by both surfaces,
/// since a style document means the same thing to the native SDK and to
/// GL JS.
final class TrailLayer {
  /// Id of the `geojson` source holding the trail features.
  static const String sourceId = '${PixelStyleBuilder.addedLayerPrefix}trails';

  /// Id of the `line` layer drawing them.
  static const String layerId =
      '${PixelStyleBuilder.addedLayerPrefix}trail-lines';

  /// Dash pattern in multiples of the line width: a dash then a gap of
  /// roughly equal length, which with round caps reads as the rounded
  /// stitching of the design mockup.
  ///
  /// Fixed for every trail because `line-dasharray` cannot be driven from
  /// feature data; only colour, width and opacity vary per character.
  static const List<double> dashArray = [1.5, 1.5];

  static const String _colorProperty = 'trailColor';
  static const String _widthProperty = 'trailWidth';
  static const String _opacityProperty = 'trailOpacity';

  /// A line needs two ends; a single stop is not yet a journey.
  static const int _minimumPoints = 2;

  /// The `geojson` source definition, whose data is replaced wholesale
  /// whenever the travelled route changes.
  static JsonMap source(List<MapTrailSpec> trails) => {
    'type': 'geojson',
    'data': featureCollection(trails),
  };

  /// The line layer. Drawn under the marker layer so a city's marker is
  /// never hidden by the route running into it.
  static JsonMap layer() => {
    'id': layerId,
    'type': 'line',
    'source': sourceId,
    'layout': <String, Object?>{
      'line-cap': 'round',
      'line-join': 'round',
    },
    'paint': <String, Object?>{
      'line-color': <Object?>['get', _colorProperty],
      'line-width': <Object?>['get', _widthProperty],
      'line-opacity': <Object?>['get', _opacityProperty],
      'line-dasharray': dashArray,
    },
  };

  /// The trail features as a GeoJSON `FeatureCollection`. Trails with
  /// fewer than two points are dropped rather than emitted as degenerate
  /// lines.
  static JsonMap featureCollection(List<MapTrailSpec> trails) => {
    'type': 'FeatureCollection',
    'features': [
      for (final trail in trails)
        if (trail.points.length >= _minimumPoints) _feature(trail),
    ],
  };

  /// The stops become a curve here rather than in the spec: a trail is
  /// authored as the places someone actually stopped at, and how that
  /// route is drawn between them is a rendering decision.
  static JsonMap _feature(MapTrailSpec trail) => {
    'type': 'Feature',
    'id': trail.id,
    'geometry': <String, Object?>{
      'type': 'LineString',
      'coordinates': [
        for (final point in TrailCurve.through(trail.points))
          <double>[point.longitude, point.latitude],
      ],
    },
    'properties': <String, Object?>{
      _colorProperty: _hex(trail.style.color),
      _widthProperty: trail.style.width,
      _opacityProperty: trail.style.opacity,
    },
  };

  /// Mapbox parses colours from CSS strings.
  static String _hex(Color color) {
    final argb = color.toARGB32();
    final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');

    return '#$rgb';
  }

  const TrailLayer._();
}

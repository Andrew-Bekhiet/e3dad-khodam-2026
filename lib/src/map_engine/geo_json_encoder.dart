import 'dart:math';
import 'dart:ui';

import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_style_builder.dart';

/// Encodes the provider-agnostic surface content as GeoJSON.
final class GeoJsonEncoder {
  static const int _minimumTrailPoints = 2;

  /// The marker features as a GeoJSON `FeatureCollection`.
  static JsonMap markers(List<MapMarkerSpec> markers) => {
    'type': 'FeatureCollection',
    'features': [for (final marker in markers) _marker(marker)],
  };

  /// The token features as a GeoJSON `FeatureCollection`.
  static JsonMap tokens(List<MapTokenSpec> tokens) => {
    'type': 'FeatureCollection',
    'features': [for (final token in tokens) _token(token)],
  };

  /// The trail features as a GeoJSON `FeatureCollection`.
  static JsonMap trails(List<MapTrailSpec> trails) => {
    'type': 'FeatureCollection',
    'features': [
      for (final trail in trails)
        if (trail.points.length >= _minimumTrailPoints) _trail(trail),
    ],
  };

  static JsonMap _marker(MapMarkerSpec marker) {
    final style = marker.style;
    final label = style.label;

    return {
      'type': 'Feature',
      'id': marker.id,
      'geometry': <String, Object?>{
        'type': 'Point',
        'coordinates': <double>[
          marker.position.longitude,
          marker.position.latitude,
        ],
      },
      'properties': <String, Object?>{
        'markerId': marker.id,
        'sprite': style.id,
        'label': marker.label,
        'fontSize': label.fontSize,
        // The icon is centred on the coordinate, so its label must clear
        // half the shape plus the gap and anything drawn over it.
        'labelOffsetEms': <double>[
          0,
          (max(style.diameter / 2, marker.labelClearance) + label.gap) /
              label.fontSize,
        ],
        'labelColor': _hex(label.color),
        'labelHaloColor': _hex(label.haloColor),
        'labelHaloWidth': label.haloWidth,
        'interactive': marker.isInteractive,
      },
    };
  }

  static JsonMap _token(MapTokenSpec token) => {
    'type': 'Feature',
    'id': token.id,
    'geometry': <String, Object?>{
      'type': 'Point',
      'coordinates': <double>[
        token.position.longitude,
        token.position.latitude,
      ],
    },
    'properties': <String, Object?>{
      'tokenSprite': token.style.id,
      'tokenOffset': <double>[token.offset.dx, token.offset.dy],
    },
  };

  // The points arrive as real route geometry, so smoothing would bend a
  // road or charted sea lane away from the route it represents.
  static JsonMap _trail(MapTrailSpec trail) => {
    'type': 'Feature',
    'id': trail.id,
    'geometry': <String, Object?>{
      'type': 'LineString',
      'coordinates': [
        for (final point in trail.points)
          <double>[point.longitude, point.latitude],
      ],
    },
    'properties': <String, Object?>{
      'trailColor': _hex(trail.style.color),
      'trailWidth': trail.style.width,
      'trailOpacity': trail.style.opacity,
    },
  };

  static String _hex(Color color) {
    final argb = color.toARGB32();
    final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');

    return '#$rgb';
  }

  const GeoJsonEncoder._();
}

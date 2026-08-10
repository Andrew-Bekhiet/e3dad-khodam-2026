import 'dart:math' as math;

import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A map camera — centre, zoom and viewport — that can project
/// geographic positions to widget-local pixels.
///
/// The app keeps its own camera in Dart rather than reading one back
/// from the renderer. Marker widgets are laid out on top of the map's
/// platform view, so their positions must be known in the same frame the
/// map is drawn; asking the renderer where a coordinate landed is an
/// asynchronous round trip and would leave every marker a frame or more
/// behind the basemap.
///
/// Only valid for a north-up, unpitched camera, which is what this app
/// enforces (rotation and pitch gestures are disabled).
final class WebMercatorCamera extends Equatable {
  /// Edge length in pixels of one tile at integer zoom. Mapbox GL —
  /// both the native SDK and GL JS — uses 512, so zoom `z` maps to a
  /// world `512 * 2^z` pixels across.
  static const double tileSize = 512.0;

  static const double _degreesPerTurn = 360.0;
  static const double _halfTurnDegrees = 180.0;
  static const double _quarterTurnDegrees = 90.0;
  static const double _half = 0.5;

  /// Latitude beyond which Web Mercator y runs away to infinity; the
  /// standard clamp used by every slippy-map implementation.
  static const double maxLatitude = 85.051129;

  /// Web Mercator pixel coordinates of [position] in a world of
  /// [worldSize] pixels, origin at the top-left (north-west) corner.
  static Offset _worldOf(GeoPosition position, double worldSize) {
    final latitude = position.latitude.clamp(-maxLatitude, maxLatitude);
    final sinLatitude = math.sin(latitude * math.pi / _halfTurnDegrees);
    final x = (position.longitude + _halfTurnDegrees) / _degreesPerTurn;
    final y =
        _half -
        math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * math.pi);

    return Offset(x * worldSize, y * worldSize);
  }

  /// Inverse of [_worldOf].
  static GeoPosition _positionOf(Offset world, double worldSize) {
    final x = world.dx / worldSize;
    final y = world.dy / worldSize;
    final latitude =
        _quarterTurnDegrees -
        2 *
            math.atan(math.exp((y - _half) * 2 * math.pi)) *
            _halfTurnDegrees /
            math.pi;

    return GeoPosition(
      latitude: latitude,
      longitude: x * _degreesPerTurn - _halfTurnDegrees,
    );
  }

  /// Geographic position at the centre of the viewport.
  final GeoPosition center;

  /// Zoom level; each whole step doubles the world's pixel size.
  final double zoom;

  /// Size of the map viewport in logical pixels.
  final Size viewport;

  @override
  List<Object?> get props => [center, zoom, viewport];

  /// The world's edge length in pixels at [zoom].
  double get worldSize => tileSize * math.pow(2, zoom);

  /// Creates a camera.
  const WebMercatorCamera({
    required this.center,
    required this.zoom,
    required this.viewport,
  });

  /// The camera that frames [bounds] inside [viewport] minus [padding],
  /// clamped to `[minZoom, maxZoom]`.
  ///
  /// Asymmetric padding shifts the centre rather than shrinking the fit,
  /// so e.g. extra top padding pushes content down out from under an app
  /// bar instead of just zooming further out.
  factory WebMercatorCamera.fitting(
    GeoBounds bounds, {
    required Size viewport,
    required EdgeInsets padding,
    required double minZoom,
    required double maxZoom,
  }) {
    final available = Size(
      math.max(viewport.width - padding.horizontal, 1.0),
      math.max(viewport.height - padding.vertical, 1.0),
    );
    final northWest = _worldOf(
      GeoPosition(latitude: bounds.north, longitude: bounds.west),
      tileSize,
    );
    final southEast = _worldOf(
      GeoPosition(latitude: bounds.south, longitude: bounds.east),
      tileSize,
    );
    final spanX = math.max(
      (southEast.dx - northWest.dx).abs(),
      double.minPositive,
    );
    final spanY = math.max(
      (southEast.dy - northWest.dy).abs(),
      double.minPositive,
    );
    final scale = math.min(available.width / spanX, available.height / spanY);
    final zoom = (math.log(scale) / math.ln2).clamp(minZoom, maxZoom);

    // Re-project the centre at the chosen zoom, then slide it by half
    // the padding imbalance so the framed box sits inside the padded
    // region rather than the raw viewport.
    final worldSize = tileSize * math.pow(2, zoom);
    final boundsCenter = _worldOf(bounds.center, worldSize);
    final shifted = Offset(
      boundsCenter.dx + (padding.right - padding.left) * _half,
      boundsCenter.dy + (padding.bottom - padding.top) * _half,
    );

    return WebMercatorCamera(
      center: _positionOf(shifted, worldSize),
      zoom: zoom,
      viewport: viewport,
    );
  }

  /// Where [position] falls inside the viewport, in logical pixels from
  /// its top-left corner.
  Offset offsetOf(GeoPosition position) {
    final world = _worldOf(position, worldSize);
    final centerWorld = _worldOf(center, worldSize);

    return Offset(
      viewport.width * _half + (world.dx - centerWorld.dx),
      viewport.height * _half + (world.dy - centerWorld.dy),
    );
  }

  /// This camera moved to [center] and [zoom], keeping the viewport.
  WebMercatorCamera copyWith({GeoPosition? center, double? zoom}) =>
      WebMercatorCamera(
        center: center ?? this.center,
        zoom: zoom ?? this.zoom,
        viewport: viewport,
      );

  /// This camera resized to [viewport].
  WebMercatorCamera resized(Size viewport) => WebMercatorCamera(
    center: center,
    zoom: zoom,
    viewport: viewport,
  );
}

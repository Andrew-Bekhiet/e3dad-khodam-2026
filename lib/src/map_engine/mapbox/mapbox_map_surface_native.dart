import 'dart:convert';

import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_state_mixin.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/missing_access_token_notice.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/pixel_style_source.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/marker_layer.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/marker_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite_png.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';
import 'package:flutter/widgets.dart';
// `Size` collides with `dart:ui`'s, and only the latter is wanted here.
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

/// Builds the mobile map surface for a [MapSurfaceSpec]; the mobile half
/// of `mapbox_map_surface.dart`'s platform seam.
///
/// A tear-off assigned to a top-level constant, not a function
/// declaration, per the rationale in `MapSurfaceBuilder`'s own doc
/// comment: a function that returns a widget is otherwise flagged by
/// `avoid_returning_widgets`.
const MapSurfaceBuilder mapboxMapSurface = MapboxMapSurfaceNative.new;

/// Hands the Maps SDK its access token. Must run before the first map
/// widget is built.
void configureMapboxRenderer() {
  if (!MapboxStyle.hasAccessToken) {
    return;
  }
  MapboxOptions.setAccessToken(MapboxStyle.accessToken);
}

/// The mobile map surface: the Maps SDK rendering the pixel style, with
/// markers as a symbol layer inside it.
///
/// Everything positional belongs to the SDK — nothing here knows where a
/// coordinate lands on screen, which is why rotation and pitch are left
/// enabled. The web build never imports this file.
final class MapboxMapSurfaceNative extends StatefulWidget {
  /// The map content and camera target to render.
  final MapSurfaceSpec spec;

  /// Creates the surface.
  ///
  /// Takes a single positional parameter so the tear-off
  /// `MapboxMapSurfaceNative.new` satisfies `MapSurfaceBuilder`.
  const MapboxMapSurfaceNative(this.spec, {super.key});

  @override
  State<MapboxMapSurfaceNative> createState() => _MapboxMapSurfaceNativeState();
}

class _MapboxMapSurfaceNativeState extends State<MapboxMapSurfaceNative>
    with MapSurfaceStateMixin<MapboxMapSurfaceNative> {
  /// One image pixel per screen pixel; scaling would smooth the very
  /// edges the pixel-art look is made of.
  static const double _patternScale = 1.0;

  /// Hit-test radius in logical pixels; city dots are only 18px across.
  static const double _tapSlop = 12.0;

  static const Duration _snapDuration = Duration(milliseconds: 120);

  /// Below this, a snap is skipped so it cannot re-trigger itself.
  static const double _zoomEpsilon = 1e-3;

  MapboxMap? _map;
  PixelStyle? _style;
  bool _styleRequested = false;
  bool _styleLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStyle();
  }

  @override
  MapSurfaceSpec specOf(MapboxMapSurfaceNative widget) => widget.spec;

  @override
  void pushMarkers(List<MapMarkerSpec> markers) {
    _pushMarkers(markers);
  }

  @override
  void moveCamera(MapCameraTarget camera, Duration duration) {
    _moveCamera(camera, duration);
  }

  @override
  Widget build(BuildContext context) {
    if (!MapboxStyle.hasAccessToken) {
      return const MissingAccessTokenNotice();
    }

    return MapWidget(
      // The SDK insists on a style URI at construction and cannot take
      // JSON there, so the plain Studio style shows briefly before
      // `loadStyleJson` swaps in the pixel one. Same tile source.
      styleUri: MapboxStyle.styleUri,
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: _onStyleLoaded,
      onStyleImageMissingListener: _onStyleImageMissing,
      onMapIdleListener: _onMapIdle,
    );
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _loadStyle() async {
    final style = await PixelStyleSource.load(markers: widget.spec.markers);
    if (!mounted) {
      return;
    }
    _style = style;
    await _applyStyle();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.compass.updateSettings(CompassSettings(enabled: false));
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.setBounds(
      CameraBoundsOptions(
        minZoom: widget.spec.minZoom,
        maxZoom: widget.spec.maxZoom,
      ),
    );
    _listenForMarkerTaps(map);
    await _applyStyle();
  }

  /// The map and the built style arrive in either order, so whichever
  /// lands second loads. The flag is read and set before the first
  /// `await`, so no second caller can observe it unset — hence no lock.
  Future<void> _applyStyle() async {
    final map = _map;
    final style = _style;
    if (map == null || style == null || _styleRequested) {
      return;
    }
    _styleRequested = true;
    await map.loadStyleJson(style.json);
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData _) async {
    _styleLoaded = true;
    // Loading a style clears every registered image.
    await _addSprites();
    await _moveCamera(widget.spec.camera, Duration.zero);
  }

  /// Supplies an image the renderer asked for. The eager registration in
  /// [_onStyleLoaded] can lose the race against the first render, and a
  /// missing `fill-pattern` or `icon-image` draws nothing at all.
  Future<void> _onStyleImageMissing(StyleImageMissingEventData event) async {
    final pattern = _style?.sprites
        .where((candidate) => candidate.id == event.id)
        .firstOrNull;
    if (pattern != null) {
      await _addSprite(pattern);

      return;
    }
    final markerStyle = _style?.markerStyles
        .where((candidate) => candidate.id == event.id)
        .firstOrNull;
    if (markerStyle == null) {
      return;
    }
    await _addSprite(await MarkerSprite.render(markerStyle));
  }

  Future<void> _addSprites() async {
    final style = _style;
    if (style == null) {
      return;
    }
    for (final sprite in style.sprites) {
      await _addSprite(sprite);
    }
    for (final sprite in await MarkerSprite.renderAll(style.markerStyles)) {
      await _addSprite(sprite, scale: MarkerSprite.scale);
    }
  }

  Future<void> _addSprite(
    PixelSprite sprite, {
    double scale = _patternScale,
  }) async {
    final map = _map;
    if (map == null) {
      return;
    }
    final png = await sprite.toPng();
    if (!mounted) {
      return;
    }
    await map.style.addStyleImage(
      sprite.id,
      scale,
      MbxImage(width: sprite.width, height: sprite.height, data: png),
      false,
      [],
      [],
      null,
    );
  }

  /// Replaces the marker source's data, registering artwork for any
  /// style the previous level did not use.
  Future<void> _pushMarkers(List<MapMarkerSpec> markers) async {
    final map = _map;
    if (map == null || !_styleLoaded) {
      return;
    }
    for (final markerStyle in MarkerLayer.stylesOf(markers)) {
      if (await map.style.hasStyleImage(markerStyle.id)) {
        continue;
      }
      await _addSprite(
        await MarkerSprite.render(markerStyle),
        scale: MarkerSprite.scale,
      );
    }
    if (!mounted) {
      return;
    }
    await map.style.setStyleSourceProperty(
      MarkerLayer.sourceId,
      'data',
      jsonEncode(MarkerLayer.featureCollection(markers)),
    );
  }

  /// Moves the map's own camera. A [FitBoundsCameraTarget] is resolved by
  /// `cameraForCoordinateBounds`, which knows the real viewport and
  /// projection, so nothing here reimplements Web Mercator.
  Future<void> _moveCamera(MapCameraTarget target, Duration duration) async {
    final map = _map;
    if (map == null || !_styleLoaded) {
      return;
    }
    final camera = switch (target) {
      CenterZoomCameraTarget(:final center, :final zoom) => CameraOptions(
        center: center.toMapboxPoint(),
        zoom: zoom,
      ),
      FitBoundsCameraTarget(:final bounds, :final padding) =>
        await map.cameraForCoordinateBounds(
          bounds.toMapboxBounds(),
          MbxEdgeInsets(
            top: padding.top,
            left: padding.left,
            bottom: padding.bottom,
            right: padding.right,
          ),
          null,
          null,
          widget.spec.maxZoom,
          null,
        ),
    };
    if (!mounted) {
      return;
    }
    if (duration == Duration.zero) {
      await map.setCamera(camera);

      return;
    }
    await map.flyTo(
      camera,
      MapAnimationOptions(duration: duration.inMilliseconds),
    );
  }

  /// Settles onto a whole zoom level: between levels the renderer
  /// resamples the patterns and the pixel art turns to mush.
  Future<void> _onMapIdle(MapIdleEventData _) async {
    final map = _map;
    if (map == null || PixelTuning.zoomSnap <= 0) {
      return;
    }
    final state = await map.getCameraState();
    final snapped =
        (state.zoom / PixelTuning.zoomSnap).roundToDouble() *
        PixelTuning.zoomSnap;
    if (!mounted || (snapped - state.zoom).abs() < _zoomEpsilon) {
      return;
    }
    await map.easeTo(
      CameraOptions(zoom: snapped),
      MapAnimationOptions(duration: _snapDuration.inMilliseconds),
    );
  }

  /// The renderer hit-tests the marker layer and applies
  /// [MarkerLayer.interactiveFilter], so inert markers never match.
  void _listenForMarkerTaps(MapboxMap map) {
    map.addInteraction(
      TapInteraction(
        FeaturesetDescriptor(layerId: MarkerLayer.layerId),
        (feature, _) {
          final id = MarkerLayer.idOf(feature.properties);
          if (id != null && mounted) {
            widget.spec.onMarkerTap(id);
          }
        },
        filter: jsonEncode(MarkerLayer.interactiveFilter),
        radius: _tapSlop,
      ),
    );
  }
}

/// Lives here rather than on the domain types, which must stay free of
/// `mapbox_maps_flutter` since it has no web implementation.
extension GeoPositionMapbox on GeoPosition {
  /// Note the axis order — the SDK takes longitude first.
  Point toMapboxPoint() => Point(coordinates: Position(longitude, latitude));
}

/// See [GeoPositionMapbox] for why this lives here.
extension GeoBoundsMapbox on GeoBounds {
  /// South-west then north-east.
  CoordinateBounds toMapboxBounds() => CoordinateBounds(
    southwest: GeoPosition(
      latitude: south,
      longitude: west,
    ).toMapboxPoint(),
    northeast: GeoPosition(
      latitude: north,
      longitude: east,
    ).toMapboxPoint(),
    infiniteBounds: false,
  );
}

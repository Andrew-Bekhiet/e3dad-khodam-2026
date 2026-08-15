import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:e3dad_khodam_2026/src/app/app_features.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_state_mixin.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_gl_js.dart'
    as gl;
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/missing_access_token_notice.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/pixel_style_source.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/marker_layer.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/marker_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';
import 'package:e3dad_khodam_2026/src/map_engine/tokens/token_layer.dart';
import 'package:e3dad_khodam_2026/src/map_engine/tokens/token_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Parses a JSON string with the browser's own parser.
@JS('JSON.parse')
external JSObject _jsonParse(String _);

/// Builds the web map surface for a [MapSurfaceSpec]; the web half of
/// `mapbox_map_surface.dart`'s platform seam.
const MapSurfaceBuilder mapboxMapSurface = MapboxMapSurfaceWeb.new;

/// No-op on web: GL JS takes the access token when each map is created,
/// so there is no global to configure up front. Still required so both
/// platforms present the same seam to `main.dart`.
void configureMapboxRenderer() {
  // Intentionally empty — see doc comment above.
}

/// The web map surface: GL JS in a platform view, rendering the same
/// pixel style and marker layer as the mobile surface. Mobile builds
/// never import this file.
final class MapboxMapSurfaceWeb extends StatefulWidget {
  /// The map content and camera target to render.
  final MapSurfaceSpec spec;

  /// Creates the surface.
  const MapboxMapSurfaceWeb(this.spec, {super.key});

  @override
  State<MapboxMapSurfaceWeb> createState() => _MapboxMapSurfaceWebState();
}

class _MapboxMapSurfaceWebState extends State<MapboxMapSurfaceWeb>
    with MapSurfaceStateMixin<MapboxMapSurfaceWeb> {
  /// Platform view type, registered once per app run.
  static const String _viewType = 'e3dad-khodam-mapbox-gl';

  /// Pattern sprites are authored at one image pixel per CSS pixel.
  static const double _patternScale = 1.0;

  static const Duration _snapDuration = Duration(milliseconds: 120);
  static const double _zoomEpsilon = 1e-3;

  /// How hard the map is blurred at the height of a sweep, in CSS
  /// pixels. Enough to read as speed, light enough that the coastline
  /// never stops being a coastline.
  static const double _sweepBlurPixels = 3.0;

  /// How long the blur takes to come and go, so it is never switched on
  /// or off in one frame.
  static const Duration _blurFade = Duration(milliseconds: 260);

  static bool _viewFactoryRegistered = false;

  /// Containers created by the view factory, by platform view id.
  static final Map<int, web.HTMLElement> _containers = {};

  int? _viewId;
  gl.GlMap? _map;
  PixelStyle? _style;
  bool _styleLoaded = false;

  /// Ids of the images already handed to GL JS.
  ///
  /// `hasImage` is cheap here, but rendering a sprite is not and the
  /// check has an `await` after it — so two pushes in flight together
  /// would both decide the image is missing and both rasterise it. This
  /// is claimed before the first await instead. Cleared when a style
  /// loads, which is what drops the map's own images.
  final Set<String> _registeredImages = {};

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
  }

  @override
  MapSurfaceSpec specOf(MapboxMapSurfaceWeb widget) => widget.spec;

  @override
  void pushMarkers(List<MapMarkerSpec> markers) {
    _pushMarkers(markers);
  }

  @override
  void pushTrails(List<MapTrailSpec> trails) {
    _setSourceData(TrailLayer.sourceId, TrailLayer.featureCollection(trails));
  }

  @override
  void pushTokens(List<MapTokenSpec> tokens) {
    _pushTokens(tokens);
  }

  @override
  void moveCamera(MapCameraTarget camera, Duration duration) =>
      _moveCamera(camera, duration);

  @override
  Widget build(BuildContext context) {
    if (!MapboxStyle.hasAccessToken) {
      return const MissingAccessTokenNotice();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _scheduleResize(constraints.biggest);

        return HtmlElementView(
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      },
    );
  }

  @override
  void dispose() {
    _map?.remove();
    _containers.remove(_viewId);
    super.dispose();
  }

  /// Registration is global and one-shot; the per-instance element is
  /// looked up by view id.
  void _registerViewFactory() {
    if (_viewFactoryRegistered) {
      return;
    }
    _viewFactoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final container = web.document.createElement('div') as web.HTMLElement;
      container.style
        ..width = '100%'
        ..height = '100%';
      _containers[viewId] = container;

      return container;
    });
  }

  /// GL JS reads its size from the container, which Flutter resizes
  /// during layout — so tell it after the frame, not mid-build.
  void _scheduleResize(Size size) {
    if (size.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _map?.resize();
    });
  }

  Future<void> _onPlatformViewCreated(int viewId) async {
    _viewId = viewId;
    final container = _containers[viewId];
    if (container == null || !gl.isMapboxGlLoaded) {
      assert(
        gl.isMapboxGlLoaded,
        'mapbox-gl.js did not load — check the <script> tag in '
        'web/index.html.',
      );

      return;
    }
    final style = await PixelStyleSource.load(
      markers: widget.spec.markers,
      trails: widget.spec.trails,
      tokens: widget.spec.tokens,
    );
    if (!mounted) {
      return;
    }
    _style = style;
    gl.accessToken = MapboxStyle.accessToken;
    gl.ensureRtlTextPluginSet();
    final map = gl.GlMap(
      gl.GlMapOptions(
        container: container,
        // Parsed by the JS engine straight into a JS object: going via
        // Dart maps would copy the 130-layer document twice.
        style: _jsonParse(style.json),
        viewport: (
          center: _positionToJs(_nullIsland),
          zoom: widget.spec.minZoom,
          minZoom: widget.spec.minZoom,
          maxZoom: widget.spec.maxZoom,
        ),
      ),
    );
    // Listeners must return void: `toJS` rejects a Future signature.
    map.on(
      'load',
      (JSAny? _) {
        _onStyleLoaded();
      }.toJS,
    );
    // Same safety net as mobile: an absent image draws nothing at all.
    map.on(
      'styleimagemissing',
      (JSAny? _) {
        _addSprites();
      }.toJS,
    );
    map.on('moveend', ((JSAny? _) => _onMoveEnd()).toJS);
    map.onLayer('click', MarkerLayer.layerId, _onMarkerClicked.toJS);
    _map = map;
  }

  Future<void> _onStyleLoaded() async {
    _styleLoaded = true;
    _registeredImages.clear();
    await _addSprites();
    if (mounted) {
      _moveCamera(widget.spec.camera, Duration.zero);
    }
  }

  Future<void> _addSprites() async {
    final map = _map;
    final style = _style;
    if (map == null || style == null) {
      return;
    }
    for (final sprite in style.sprites) {
      _addSprite(sprite, scale: _patternScale);
    }
    await _addMarkerSprites(MarkerLayer.stylesOf(widget.spec.markers));
    if (mounted) {
      await _addTokenSprites(TokenLayer.stylesOf(widget.spec.tokens));
    }
  }

  Future<void> _addTokenSprites(List<MapTokenStyle> styles) async {
    final map = _map;
    if (map == null) {
      return;
    }
    for (final tokenStyle in styles) {
      if (map.hasImage(tokenStyle.id) ||
          !_registeredImages.add(tokenStyle.id)) {
        continue;
      }
      final sprite = await TokenSprite.render(tokenStyle);
      if (!mounted) {
        _registeredImages.remove(tokenStyle.id);

        return;
      }
      _addSprite(sprite, scale: TokenSprite.scale);
    }
  }

  Future<void> _addMarkerSprites(List<MapMarkerStyle> styles) async {
    final map = _map;
    if (map == null) {
      return;
    }
    for (final markerStyle in styles) {
      if (map.hasImage(markerStyle.id) ||
          !_registeredImages.add(markerStyle.id)) {
        continue;
      }
      final sprite = await MarkerSprite.render(markerStyle);
      if (!mounted) {
        _registeredImages.remove(markerStyle.id);

        return;
      }
      _addSprite(sprite, scale: MarkerSprite.scale);
    }
  }

  void _addSprite(PixelSprite sprite, {required double scale}) {
    final map = _map;
    if (map == null || map.hasImage(sprite.id)) {
      return;
    }
    map.addImage(
      sprite.id,
      gl.GlImageData(
        width: sprite.width,
        height: sprite.height,
        data: sprite.rgba.toJS,
      ),
      gl.GlImageOptions(pixelRatio: scale),
    );
    _registeredImages.add(sprite.id);
  }

  /// Replaces the marker source's features, registering artwork for any
  /// style the previous level did not use.
  Future<void> _pushMarkers(List<MapMarkerSpec> markers) async {
    final map = _map;
    if (map == null || !_styleLoaded) {
      return;
    }
    await _addMarkerSprites(MarkerLayer.stylesOf(markers));
    if (!mounted) {
      return;
    }
    _setSourceData(
      MarkerLayer.sourceId,
      MarkerLayer.featureCollection(markers),
    );
  }

  /// Replaces the token source's features, registering artwork for any
  /// character the map has not drawn before.
  Future<void> _pushTokens(List<MapTokenSpec> tokens) async {
    final map = _map;
    if (map == null || !_styleLoaded) {
      return;
    }
    await _addTokenSprites(TokenLayer.stylesOf(tokens));
    if (!mounted) {
      return;
    }
    _setSourceData(TokenLayer.sourceId, TokenLayer.featureCollection(tokens));
  }

  /// Swaps a `geojson` source's features, going through the browser's own
  /// JSON parser rather than converting a Dart map member by member.
  void _setSourceData(String sourceId, Map<String, Object?> data) {
    final map = _map;
    if (map == null || !_styleLoaded) {
      return;
    }
    map.getSource(sourceId)?.setData(_jsonParse(jsonEncode(data)));
  }

  /// A [FitBoundsCameraTarget] goes straight to `fitBounds`, which knows
  /// the real viewport and projection.
  void _moveCamera(MapCameraTarget target, Duration duration) {
    if (target is SweepCameraTarget) {
      _flySweep(target);

      return;
    }
    _flyLeg(target, duration);
  }

  /// Flies a sweep as its three parts, and blurs the map while it runs.
  ///
  /// The blur is a CSS filter on the map's own container. Flutter cannot
  /// blur this: the map is a platform view, so its pixels are never
  /// Flutter's to filter — `ImageFiltered` and `BackdropFilter` both
  /// stop at the boundary. The element is already held here, so the real
  /// map blurs on the web build and only there.
  Future<void> _flySweep(SweepCameraTarget sweep) async {
    _flyLeg(sweep.widest, sweep.outLeg);
    _blur(_sweepBlurPixels);
    await Future<void>.delayed(sweep.outLeg + sweep.hold);
    if (!mounted) {
      return;
    }
    _flyLeg(sweep.arrival, sweep.inLeg);
    await Future<void>.delayed(sweep.inLeg);
    if (!mounted) {
      return;
    }
    _blur(0);
  }

  /// Sets the map container's blur in CSS pixels; zero clears it.
  void _blur(double pixels) {
    if (!AppFeatures.sweepMotionBlur) {
      return;
    }
    final container = _containers[_viewId];
    if (container == null) {
      return;
    }
    container.style.filter = pixels <= 0 ? '' : 'blur(${pixels}px)';
    container.style.transition = 'filter ${_blurFade.inMilliseconds}ms linear';
  }

  /// Moves the camera to one plain target over [duration].
  void _flyLeg(MapCameraTarget target, Duration duration) {
    final map = _map;
    if (map == null || !_styleLoaded) {
      return;
    }
    final millis = duration.inMilliseconds.toDouble();
    switch (target) {
      // A sweep is three legs, never one; `_moveCamera` splits it first.
      case SweepCameraTarget():
        throw StateError('a sweep is not a leg');
      case CenterZoomCameraTarget(:final center, :final zoom):
        final options = gl.GlCameraOptions(
          zoom: zoom,
          center: _positionToJs(center),
          duration: millis,
        );
        duration == Duration.zero ? map.jumpTo(options) : map.easeTo(options);
      case FitBoundsCameraTarget(:final bounds, :final padding):
        map.fitBounds(
          <JSArray<JSNumber>>[
            <JSNumber>[bounds.west.toJS, bounds.south.toJS].toJS,
            <JSNumber>[bounds.east.toJS, bounds.north.toJS].toJS,
          ].toJS,
          gl.GlFitBoundsOptions(
            padding: _paddingToJs(padding),
            duration: millis,
            maxZoom: widget.spec.maxZoom,
          ),
        );
    }
  }

  /// Settles onto a whole zoom level: between levels the renderer
  /// resamples the patterns and the pixel art turns to mush.
  void _onMoveEnd() {
    final map = _map;
    if (map == null || PixelTuning.zoomSnap <= 0) {
      return;
    }
    final zoom = map.getZoom();
    final snapped =
        (zoom / PixelTuning.zoomSnap).roundToDouble() * PixelTuning.zoomSnap;
    if ((snapped - zoom).abs() < _zoomEpsilon) {
      return;
    }
    map.easeTo(
      gl.GlCameraOptions(
        zoom: snapped,
        duration: _snapDuration.inMilliseconds.toDouble(),
      ),
    );
  }

  void _onMarkerClicked(gl.GlMapMouseEvent event) {
    for (final feature in event.features.toDart) {
      final properties = feature.properties.dartify();
      if (properties is! Map) {
        continue;
      }
      final typed = properties.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      if (!MarkerLayer.isInteractive(typed)) {
        continue;
      }
      final id = MarkerLayer.idOf(typed);
      if (id != null && mounted) {
        widget.spec.onMarkerTap(id);

        return;
      }
    }
  }

  static const GeoPosition _nullIsland = GeoPosition(
    latitude: 0,
    longitude: 0,
  );

  static JSArray<JSNumber> _positionToJs(GeoPosition position) =>
      <JSNumber>[position.longitude.toJS, position.latitude.toJS].toJS;

  static JSObject _paddingToJs(EdgeInsets padding) => JSObject()
    ..['top'] = padding.top.toJS
    ..['right'] = padding.right.toJS
    ..['bottom'] = padding.bottom.toJS
    ..['left'] = padding.left.toJS;
}

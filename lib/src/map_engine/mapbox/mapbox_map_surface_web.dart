import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/camera_change_listener_mixin.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/map_camera_controller.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/projected_marker_layer.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_gl_js.dart'
    as gl;
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/missing_access_token_notice.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/pixel_style_source.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Parses a JSON string with the browser's own parser.
@JS('JSON.parse')
external JSObject _jsonParse(String _);

/// Builds the web map surface for a [MapSurfaceSpec]; the web half of
/// `mapbox_map_surface.dart`'s platform seam.
///
/// A tear-off assigned to a top-level constant, not a function
/// declaration — see `mapbox_map_surface_native.dart`'s copy of this
/// same doc comment for why.
const MapSurfaceBuilder mapboxMapSurface = MapboxMapSurfaceWeb.new;

/// No-op on web: GL JS takes the access token when each map is created,
/// so there is no global to configure up front. Still required so both
/// platforms present the same seam to `main.dart`.
void configureMapboxRenderer() {
  // Intentionally empty — see doc comment above.
}

/// The web map surface: Mapbox GL JS in a platform view, rendering the
/// same pixel style the mobile surface renders, with the app's marker
/// widgets laid over it.
///
/// Mobile builds never import this file (see `mapbox_map_surface.dart`).
final class MapboxMapSurfaceWeb extends StatefulWidget {
  /// The map content and camera target to render.
  final MapSurfaceSpec spec;

  /// Creates the surface.
  ///
  /// Takes a single positional parameter so the tear-off
  /// `MapboxMapSurfaceWeb.new` satisfies `MapSurfaceBuilder`.
  const MapboxMapSurfaceWeb(this.spec, {super.key});

  @override
  State<MapboxMapSurfaceWeb> createState() => _MapboxMapSurfaceWebState();
}

class _MapboxMapSurfaceWebState extends State<MapboxMapSurfaceWeb>
    with
        SingleTickerProviderStateMixin,
        CameraChangeListenerMixin<MapboxMapSurfaceWeb> {
  /// Platform view type, registered once per app run.
  static const String _viewType = 'e3dad-khodam-mapbox-gl';

  /// Sprites are authored at one image pixel per CSS pixel.
  static const double _spriteScale = 1.0;

  /// How long a zoom snap takes once a gesture settles.
  static const Duration _snapDuration = Duration(milliseconds: 120);

  static bool _viewFactoryRegistered = false;

  /// Containers created by the view factory, by platform view id. The
  /// factory and `onPlatformViewCreated` are handed the same id, which
  /// is how an instance finds the element it was given.
  static final Map<int, web.HTMLElement> _containers = {};

  // Built in initState against `vsync: this`, which only becomes
  // available once this State is attached — see the identical field on
  // the native surface for the full rationale. Overrides
  // CameraChangeListenerMixin's abstract getter directly, rather than
  // through a delegating getter.
  @override
  late final MapCameraController cameraController;
  int? _viewId;
  gl.GlMap? _map;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
    cameraController = MapCameraController(
      vsync: this,
      minZoom: widget.spec.minZoom,
      maxZoom: widget.spec.maxZoom,
    );
    listenForCameraChanges();
  }

  @override
  void didUpdateWidget(MapboxMapSurfaceWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    cameraController.syncFrom(widget.spec, oldWidget.spec);
  }

  @override
  Widget build(BuildContext context) {
    if (!MapboxStyle.hasAccessToken) {
      return const MissingAccessTokenNotice();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _scheduleViewport(constraints.biggest);
        final camera = cameraController.camera;

        return Stack(
          fit: StackFit.expand,
          children: [
            HtmlElementView(
              viewType: _viewType,
              onPlatformViewCreated: _onPlatformViewCreated,
            ),
            if (camera != null)
              ProjectedMarkerLayer(
                camera: camera,
                markers: widget.spec.markers,
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    stopListeningForCameraChanges();
    cameraController.dispose();
    _map?.remove();
    _containers.remove(_viewId);

    super.dispose();
  }

  /// Registers the factory that hands Flutter the `<div>` GL JS draws
  /// into. Registration is global and one-shot; the per-instance
  /// element is looked up by view id.
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

  /// Viewport changes arrive mid-build; resolving the camera notifies
  /// listeners, which would rebuild this widget while it is building.
  void _scheduleViewport(Size size) {
    if (cameraController.camera?.viewport == size) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      cameraController.setViewport(size);
      _map?.resize();
    });
  }

  Future<void> _onPlatformViewCreated(int viewId) async {
    _viewId = viewId;
    final container = _containers[viewId];
    if (container == null || !gl.isMapboxGlLoaded) {
      // Nothing to fail loudly with here beyond the assert: the page
      // simply has no Mapbox GL JS, which `web/index.html` is supposed
      // to have loaded.
      assert(
        gl.isMapboxGlLoaded,
        'mapbox-gl.js did not load — check the <script> tag in '
        'web/index.html.',
      );

      return;
    }
    final style = await PixelStyleSource.load();
    if (!mounted) {
      return;
    }
    gl.accessToken = MapboxStyle.accessToken;
    final map = gl.GlMap(
      gl.GlMapOptions(
        container: container,
        // The style goes in as a decoded object, so the pixel look is
        // there on the first painted frame.
        // Parsed by the JS engine straight into a JS object: decoding
        // to Dart maps only to convert them back would copy the whole
        // 130-layer document twice.
        style: _jsonParse(style.json),
        viewport: (
          center: _positionToJs(_initialCenter),
          zoom: widget.spec.minZoom,
          minZoom: widget.spec.minZoom,
          maxZoom: widget.spec.maxZoom,
        ),
        gestures: (
          dragRotate: false,
          pitchWithRotate: false,
          touchPitch: false,
        ),
      ),
    );
    map.touchZoomRotate.disableRotation();
    map.on('load', ((JSAny? _) => _addSprites(style)).toJS);
    // Same safety net as the mobile surface: a `fill-pattern` whose
    // image is absent draws nothing rather than falling back to
    // `fill-color`, so the renderer gets to ask for what it is missing.
    map.on('styleimagemissing', ((JSAny? _) => _addSprites(style)).toJS);
    map.on('move', ((JSAny? _) => _onRendererCameraChanged()).toJS);
    map.on('moveend', ((JSAny? _) => _onMoveEnd()).toJS);
    _map = map;
  }

  /// Registers the patterns — what turns the style's `fill-pattern`
  /// references into artwork. GL JS takes raw RGBA here; the mobile
  /// surface has to encode PNG instead (see `PixelSpritePng`).
  void _addSprites(PixelStyle style) {
    final map = _map;
    if (map == null) {
      return;
    }
    for (final sprite in style.sprites) {
      if (map.hasImage(sprite.id)) {
        continue;
      }
      map.addImage(
        sprite.id,
        gl.GlImageData(
          width: sprite.width,
          height: sprite.height,
          data: sprite.rgba.toJS,
        ),
        gl.GlImageOptions(pixelRatio: _spriteScale),
      );
    }
    _pushCamera();
  }

  @override
  void pushCameraToRenderer() => _pushCamera();

  void _pushCamera() {
    final map = _map;
    final camera = cameraController.camera;
    if (map == null || camera == null) {
      return;
    }
    map.jumpTo(
      gl.GlCameraOptions(
        center: _positionToJs(camera.center),
        zoom: camera.zoom,
        bearing: 0,
        pitch: 0,
      ),
    );
  }

  void _onRendererCameraChanged() {
    final map = _map;
    if (map == null) {
      return;
    }
    final center = map.getCenter();
    cameraController.adoptFromRenderer(
      center: GeoPosition(latitude: center.lat, longitude: center.lng),
      zoom: map.getZoom(),
    );
  }

  /// Settles onto a whole zoom level once a gesture ends: between levels
  /// the renderer resamples the patterns and the pixel art turns to
  /// mush.
  void _onMoveEnd() =>
      cameraController.snapZoom(PixelTuning.zoomSnap, duration: _snapDuration);

  /// Where the map opens before the app's own camera is pushed on
  /// style load — a moment later, and always overridden.
  GeoPosition get _initialCenter => cameraController.camera?.center ?? _nullIsland;

  static const GeoPosition _nullIsland = GeoPosition(
    latitude: 0,
    longitude: 0,
  );

  static JSArray<JSNumber> _positionToJs(GeoPosition position) =>
      <JSNumber>[position.longitude.toJS, position.latitude.toJS].toJS;
}

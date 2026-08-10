import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/map_camera_controller.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/projected_marker_layer.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/missing_access_token_notice.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/pixel_style_source.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';
import 'package:flutter/widgets.dart';
// `Size` collides with `dart:ui`'s, and only the latter is wanted here.
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

/// Builds the mobile map surface for [spec]; the mobile half of
/// `mapbox_map_surface.dart`'s platform seam.
Widget mapboxMapSurface(MapSurfaceSpec spec) => MapboxMapSurfaceNative(spec);

/// Hands the Maps SDK its access token. Must run before the first map
/// widget is built.
void configureMapboxRenderer() {
  if (MapboxStyle.hasAccessToken) {
    MapboxOptions.setAccessToken(MapboxStyle.accessToken);
  }
}

/// The mobile map surface: Mapbox's own Maps SDK rendering the pixel
/// style, with the app's marker widgets laid over it.
///
/// The web build never imports this file (see `mapbox_map_surface.dart`),
/// since the SDK has no web implementation.
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
    with SingleTickerProviderStateMixin {
  /// Sprites are authored at one image pixel per screen pixel; letting
  /// the renderer scale them would smooth the very edges the look is
  /// made of.
  static const double _spriteScale = 1.0;

  /// How long a zoom snap takes once a gesture settles. Long enough to
  /// read as a movement, short enough not to feel like a correction.
  static const Duration _snapDuration = Duration(milliseconds: 120);

  late final MapCameraController _camera;
  MapboxMap? _map;
  PixelStyle? _style;

  @override
  void initState() {
    super.initState();
    _camera = MapCameraController(
      vsync: this,
      minZoom: widget.spec.minZoom,
      maxZoom: widget.spec.maxZoom,
    )..addListener(_onCameraChanged);
    _loadStyle();
  }

  @override
  void dispose() {
    _camera
      ..removeListener(_onCameraChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MapboxMapSurfaceNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.spec.camera;
    if (target == oldWidget.spec.camera) {
      return;
    }
    _camera.moveTo(target, duration: widget.spec.cameraAnimationDuration);
  }

  @override
  Widget build(BuildContext context) {
    if (!MapboxStyle.hasAccessToken) {
      return const MissingAccessTokenNotice();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _scheduleViewport(constraints.biggest);
        final camera = _camera.camera;

        return Stack(
          fit: StackFit.expand,
          children: [
            MapWidget(
              // The SDK insists on a style at construction and cannot
              // take JSON there, so it briefly shows the plain Studio
              // style before `loadStyleJson` swaps in the pixel one.
              // Both draw from the same tile source, so this costs one
              // style document, not a second set of tiles.
              styleUri: MapboxStyle.styleUri,
              onMapCreated: _onMapCreated,
              onStyleLoadedListener: _onStyleLoaded,
              onCameraChangeListener: _onRendererCameraChanged,
              onMapIdleListener: _onMapIdle,
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

  /// Viewport changes arrive mid-build, but resolving the camera
  /// notifies listeners and would rebuild this widget while it is
  /// already building — so hand it to the next frame.
  void _scheduleViewport(Size size) {
    if (_camera.camera?.viewport == size) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _camera.setViewport(size);
      }
    });
  }

  Future<void> _loadStyle() async {
    final style = await PixelStyleSource.load();
    if (!mounted) {
      return;
    }
    _style = style;
    await _applyStyle();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.gestures.updateSettings(
      GesturesSettings(
        // A rotated or pitched camera would invalidate the app's own
        // Web Mercator projection, which every marker position and the
        // whole cross layout depend on.
        rotateEnabled: false,
        pitchEnabled: false,
        simultaneousRotateAndPinchToZoomEnabled: false,
      ),
    );
    await map.compass.updateSettings(CompassSettings(enabled: false));
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await _applyStyle();
  }

  /// Loads the pixel style, once both the map and the built style exist
  /// — they arrive in either order.
  Future<void> _applyStyle() async {
    final map = _map;
    final style = _style;
    if (map == null || style == null) {
      return;
    }
    await map.loadStyleJson(style.json);
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData _) async {
    final map = _map;
    final style = _style;
    if (map == null || style == null) {
      return;
    }
    // Registering the patterns is what turns the style's `fill-pattern`
    // references into artwork; loading a style clears any previously
    // registered images, so this has to run after every style load.
    for (final sprite in style.sprites) {
      await map.style.addStyleImage(
        sprite.id,
        _spriteScale,
        MbxImage(
          width: sprite.width,
          height: sprite.height,
          data: sprite.rgba,
        ),
        false,
        [],
        [],
        null,
      );
    }
    await _pushCamera();
  }

  void _onCameraChanged() {
    if (!mounted) {
      return;
    }
    // Reposition the markers for the new camera regardless of who moved
    // it; only tell the renderer about movements it did not make.
    setState(() {});
    if (_camera.origin == CameraChangeOrigin.app) {
      _pushCamera();
    }
  }

  Future<void> _pushCamera() async {
    final map = _map;
    final camera = _camera.camera;
    if (map == null || camera == null) {
      return;
    }
    await map.setCamera(
      CameraOptions(
        center: _pointOf(camera.center),
        zoom: camera.zoom,
        bearing: 0,
        pitch: 0,
      ),
    );
  }

  void _onRendererCameraChanged(CameraChangedEventData event) {
    final center = event.cameraState.center.coordinates;
    _camera.adoptFromRenderer(
      center: GeoPosition(
        latitude: center.lat.toDouble(),
        longitude: center.lng.toDouble(),
      ),
      zoom: event.cameraState.zoom,
    );
  }

  /// Settles onto a whole zoom level once a gesture ends: between
  /// levels the renderer resamples the patterns and the pixel art turns
  /// to mush.
  void _onMapIdle(MapIdleEventData _) {
    _camera.snapZoom(PixelTuning.zoomSnap, duration: _snapDuration);
  }

  static Point _pointOf(GeoPosition position) =>
      Point(coordinates: Position(position.longitude, position.latitude));
}

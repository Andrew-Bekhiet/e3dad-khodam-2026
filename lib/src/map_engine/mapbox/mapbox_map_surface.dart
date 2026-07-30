import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// `MapSurfaceBuilder` implementation backed by the app's Mapbox Studio
/// style (see [MapboxStyle]), rendered as raster tiles via `flutter_map`.
/// The only file in this app allowed to import `package:flutter_map` or
/// `package:latlong2`.
final class MapboxMapSurface extends StatefulWidget {
  /// The map content and camera target to render.
  final MapSurfaceSpec spec;

  /// Creates a Mapbox-backed map surface.
  ///
  /// Takes a single positional parameter so this constructor's tear-off,
  /// `MapboxMapSurface.new`, satisfies the `MapSurfaceBuilder` function
  /// type.
  const MapboxMapSurface(this.spec, {super.key});

  @override
  State<MapboxMapSurface> createState() => _MapboxMapSurfaceState();
}

class _MapboxMapSurfaceState extends State<MapboxMapSurface>
    with SingleTickerProviderStateMixin {
  static const Curve _cameraCurve = Curves.easeInOutCubic;
  static const String _userAgentPackageName =
      'dev.andrewbekhiet.e3dad_khodam_2026';

  /// Mapbox's terms require both its own and OpenStreetMap's attribution
  /// to stay visible on the map.
  static const String _mapboxAttributionText = '© Mapbox';
  static const String _osmAttributionText = '© OpenStreetMap';
  static const double _attributionFontSize = 10.0;
  static const Color _attributionTextColor = Color(0xFF333333);
  static const TextStyle _attributionTextStyle = TextStyle(
    fontSize: _attributionFontSize,
    fontWeight: FontWeight.w400,
    color: _attributionTextColor,
    fontFamily: 'Roboto',
  );
  static const LatLng _fallbackCenter = LatLng(0.0, 0.0);
  static const double _fallbackZoom = 0.0;

  final MapController _mapController = MapController();
  late final AnimationController _cameraAnimationController;
  _CameraAnimationPlan? _cameraAnimationPlan;

  @override
  void initState() {
    super.initState();
    assert(
      MapboxStyle.hasAccessToken,
      'No Mapbox access token: build with '
      '--dart-define=${MapboxStyle.accessTokenEnvKey}=pk.<your token>.',
    );
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: widget.spec.cameraAnimationDuration,
    )..addListener(_applyCameraAnimationTick);
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = _InitialCamera.resolve(widget.spec.camera);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCamera.center,
        initialZoom: initialCamera.zoom,
        initialCameraFit: initialCamera.fit,
        minZoom: widget.spec.minZoom,
        maxZoom: widget.spec.maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all - InteractiveFlag.rotate,
        ),
      ),
      children: [
        if (MapboxStyle.hasAccessToken)
          TileLayer(
            urlTemplate: MapboxStyle.tileUrlTemplate,
            tileDimension: MapboxStyle.tileDimension,
            zoomOffset: MapboxStyle.zoomOffset,
            retinaMode: RetinaMode.isHighDensity(context),
            userAgentPackageName: _userAgentPackageName,
          )
        else
          const _MissingAccessTokenNotice(),
        MarkerLayer(markers: _toMarkers(widget.spec.markers)),
        if (MapboxStyle.hasAccessToken)
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                _mapboxAttributionText,
                textStyle: _attributionTextStyle,
              ),
              TextSourceAttribution(
                _osmAttributionText,
                textStyle: _attributionTextStyle,
              ),
            ],
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(MapboxMapSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    final camera = widget.spec.camera;
    if (camera == oldWidget.spec.camera) {
      return;
    }
    _startCameraAnimation(
      to: camera,
      duration: widget.spec.cameraAnimationDuration,
    );
  }

  @override
  void dispose() {
    _cameraAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _toMarkers(List<MapMarkerSpec> specs) =>
      specs.map(_toMarker).toList(growable: false);

  Marker _toMarker(MapMarkerSpec spec) => Marker(
    point: spec.position.toLatLng(),
    width: spec.size.width,
    height: spec.size.height,
    alignment: spec.alignment,
    child: Builder(builder: spec.builder),
  );

  void _startCameraAnimation({
    required MapCameraTarget to,
    required Duration duration,
  }) {
    final currentCamera = _mapController.camera;
    final target = switch (to) {
      CenterZoomCameraTarget(:final center, :final zoom) => (
        center: center.toLatLng(),
        zoom: zoom,
      ),
      FitBoundsCameraTarget(:final bounds, :final padding) => _fitBounds(
        bounds,
        padding,
        currentCamera,
      ),
    };
    _cameraAnimationPlan = _CameraAnimationPlan(
      startCenter: currentCamera.center,
      startZoom: currentCamera.zoom,
      endCenter: target.center,
      endZoom: target.zoom,
    );
    _cameraAnimationController
      ..duration = duration
      ..reset()
      ..forward();
  }

  void _applyCameraAnimationTick() {
    final plan = _cameraAnimationPlan;
    if (plan == null) {
      return;
    }
    final progress = CurvedAnimation(
      parent: _cameraAnimationController,
      curve: _cameraCurve,
    ).value;
    final center = LatLng(
      _lerpDouble(plan.startCenter.latitude, plan.endCenter.latitude, progress),
      _lerpDouble(
        plan.startCenter.longitude,
        plan.endCenter.longitude,
        progress,
      ),
    );
    final zoom = _lerpDouble(plan.startZoom, plan.endZoom, progress);
    _mapController.move(center, zoom);
  }

  static double _lerpDouble(double start, double end, double t) =>
      start + (end - start) * t;

  static ({LatLng center, double zoom}) _fitBounds(
    GeoBounds bounds,
    EdgeInsets padding,
    MapCamera camera,
  ) {
    final fitted = CameraFit.bounds(
      bounds: bounds.toLatLngBounds(),
      padding: padding,
    ).fit(camera);

    return (center: fitted.center, zoom: fitted.zoom);
  }
}

/// Painted in place of the basemap when the build defined no Mapbox
/// access token, so the cause of a blank map is stated on the map itself
/// instead of being swallowed as an endless stream of failed tile
/// requests.
class _MissingAccessTokenNotice extends StatelessWidget {
  static const Color _background = Color(0xFFFFF4E5);
  static const Color _textColor = Color(0xFF8A4B00);
  static const double _fontSize = 12.0;
  static const EdgeInsets _padding = EdgeInsets.all(24.0);
  static const String _message =
      'Missing Mapbox access token. Run with '
      '--dart-define=${MapboxStyle.accessTokenEnvKey}=pk.<your token>';

  const _MissingAccessTokenNotice();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: _background,
    child: Padding(
      padding: _padding,
      child: Center(
        child: Text(
          _message,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(color: _textColor, fontSize: _fontSize),
        ),
      ),
    ),
  );
}

/// The center/zoom (and optional [CameraFit]) to seed `MapOptions` with on
/// first build, before the map has laid out and gained a usable
/// [MapController.camera] to resolve a [FitBoundsCameraTarget] against.
///
/// `MapOptions.initialCameraFit` takes precedence over
/// `initialCenter`/`initialZoom` when set, so [center]/[zoom] are only
/// meaningful fallbacks for [CenterZoomCameraTarget].
class _InitialCamera {
  /// Seed center, used directly for [CenterZoomCameraTarget] and ignored
  /// (in favour of [fit]) for [FitBoundsCameraTarget].
  final LatLng center;

  /// Seed zoom; see [center] for when it applies.
  final double zoom;

  /// Set only for [FitBoundsCameraTarget], where flutter_map itself
  /// resolves the fit once the map's size is known.
  final CameraFit? fit;

  const _InitialCamera({required this.center, required this.zoom, this.fit});

  factory _InitialCamera.resolve(MapCameraTarget target) => switch (target) {
    CenterZoomCameraTarget(:final center, :final zoom) => _InitialCamera(
      center: center.toLatLng(),
      zoom: zoom,
    ),
    FitBoundsCameraTarget(:final bounds, :final padding) => _InitialCamera(
      center: _MapboxMapSurfaceState._fallbackCenter,
      zoom: _MapboxMapSurfaceState._fallbackZoom,
      fit: CameraFit.bounds(
        bounds: bounds.toLatLngBounds(),
        padding: padding,
      ),
    ),
  };
}

/// The start and end center/zoom of an in-flight camera animation, sampled
/// each tick of the driving [AnimationController].
class _CameraAnimationPlan {
  /// Camera center when the animation started.
  final LatLng startCenter;

  /// Camera zoom when the animation started.
  final double startZoom;

  /// Camera center the animation is moving toward.
  final LatLng endCenter;

  /// Camera zoom the animation is moving toward.
  final double endZoom;

  const _CameraAnimationPlan({
    required this.startCenter,
    required this.startZoom,
    required this.endCenter,
    required this.endZoom,
  });
}

extension on GeoPosition {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension on GeoBounds {
  LatLngBounds toLatLngBounds() =>
      LatLngBounds.unsafe(north: north, south: south, east: east, west: west);
}

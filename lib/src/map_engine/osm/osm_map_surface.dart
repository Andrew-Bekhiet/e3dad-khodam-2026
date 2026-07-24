import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// `MapSurfaceBuilder` implementation backed by OpenStreetMap tiles via
/// `flutter_map`. The only file in this app allowed to import
/// `package:flutter_map` or `package:latlong2`.
final class OsmMapSurface extends StatefulWidget {
  /// The map content and camera target to render.
  final MapSurfaceSpec spec;

  /// Creates an OSM-backed map surface.
  ///
  /// Takes a single positional parameter so this constructor's tear-off,
  /// `OsmMapSurface.new`, satisfies the `MapSurfaceBuilder` function type.
  const OsmMapSurface(this.spec, {super.key});

  @override
  State<OsmMapSurface> createState() => _OsmMapSurfaceState();
}

class _OsmMapSurfaceState extends State<OsmMapSurface>
    with SingleTickerProviderStateMixin {
  static const Duration _cameraAnimationDuration = Duration(milliseconds: 600);
  static const String _tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _userAgentPackageName =
      'dev.andrewbekhiet.e3dad_khodam_2026';
  static const String _attributionText = '© OpenStreetMap contributors';
  static const LatLng _fallbackCenter = LatLng(0.0, 0.0);
  static const double _fallbackZoom = 0.0;

  final MapController _mapController = MapController();
  late final AnimationController _cameraAnimationController;
  _CameraAnimationPlan? _cameraAnimationPlan;

  @override
  void initState() {
    super.initState();
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: _cameraAnimationDuration,
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
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrlTemplate,
          userAgentPackageName: _userAgentPackageName,
        ),
        MarkerLayer(markers: _toMarkers(widget.spec.markers)),
        const SimpleAttributionWidget(source: Text(_attributionText)),
      ],
    );
  }

  @override
  void didUpdateWidget(OsmMapSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    final camera = widget.spec.camera;
    if (camera == oldWidget.spec.camera) {
      return;
    }
    _startCameraAnimation(to: camera);
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

  void _startCameraAnimation({required MapCameraTarget to}) {
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
      ..reset()
      ..forward();
  }

  void _applyCameraAnimationTick() {
    final plan = _cameraAnimationPlan;
    if (plan == null) {
      return;
    }
    final progress = _cameraAnimationController.value;
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
      center: _OsmMapSurfaceState._fallbackCenter,
      zoom: _OsmMapSurfaceState._fallbackZoom,
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

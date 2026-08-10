import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/camera_change_origin.dart';
import 'package:e3dad_khodam_2026/src/map_engine/camera/web_mercator_camera.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:flutter/widgets.dart';

export 'package:e3dad_khodam_2026/src/map_engine/camera/camera_change_origin.dart';

/// Owns the app's authoritative [WebMercatorCamera] and animates it
/// between [MapCameraTarget]s.
///
/// Shared by both map surfaces so the mobile and web implementations
/// move identically, and so marker positions and the basemap always come
/// from the same camera (see [WebMercatorCamera] for why the app, not
/// the renderer, holds it).
final class MapCameraController extends ChangeNotifier {
  static const Curve _curve = Curves.easeInOutCubic;

  /// Degrees of centre movement below which a renderer-reported camera
  /// counts as the one the app already has. Roughly a tenth of a metre.
  static const double _adoptEpsilon = 1e-6;

  /// Zoom difference below which two cameras count as the same.
  static const double _zoomEpsilon = 1e-4;

  static bool _differsMeaningfully(
    WebMercatorCamera from,
    WebMercatorCamera to,
  ) =>
      (from.zoom - to.zoom).abs() > _zoomEpsilon ||
      (from.center.latitude - to.center.latitude).abs() > _adoptEpsilon ||
      (from.center.longitude - to.center.longitude).abs() > _adoptEpsilon;

  static double _lerp(double from, double to, double t) =>
      from + (to - from) * t;

  final AnimationController _animation;

  /// Lower bound applied to every resolved zoom.
  final double minZoom;

  /// Upper bound applied to every resolved zoom.
  final double maxZoom;

  WebMercatorCamera? _camera;
  WebMercatorCamera? _from;
  WebMercatorCamera? _to;
  MapCameraTarget? _target;
  CameraChangeOrigin _origin = CameraChangeOrigin.app;

  /// The current camera, or null before the viewport size is known.
  WebMercatorCamera? get camera => _camera;

  /// Why [camera] last changed.
  CameraChangeOrigin get origin => _origin;

  /// Whether a camera animation is currently running.
  bool get isAnimating => _animation.isAnimating;

  /// Creates a controller driving its animation from [vsync].
  MapCameraController({
    required TickerProvider vsync,
    required this.minZoom,
    required this.maxZoom,
  }) : _animation = AnimationController(vsync: vsync) {
    _animation.addListener(_onTick);
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  /// Tells the controller how big the map is. The first call resolves
  /// the pending target into a real camera; later calls (rotation,
  /// resize) re-resolve it so a fitted box stays fitted.
  void setViewport(Size viewport) {
    if (viewport.isEmpty || _camera?.viewport == viewport) {
      return;
    }
    final target = _target;
    _camera = target == null
        ? _camera?.resized(viewport)
        : _resolve(target, viewport);
    _emit(CameraChangeOrigin.app);
  }

  /// Moves to [target], animating over [duration] when a camera already
  /// exists and jumping when one does not (the very first frame).
  void moveTo(MapCameraTarget target, {required Duration duration}) {
    _target = target;
    final viewport = _camera?.viewport;
    if (viewport == null) {
      return;
    }
    final resolved = _resolve(target, viewport);
    if (duration == Duration.zero || _camera == null) {
      _camera = resolved;
      _emit(CameraChangeOrigin.app);

      return;
    }
    _from = _camera;
    _to = resolved;
    _animation
      ..duration = duration
      ..reset()
      ..forward();
  }

  /// Moves to [spec]'s camera target if it differs from [previous]'s —
  /// the `didUpdateWidget` logic both map surfaces need, kept here so
  /// it is written once.
  void syncFrom(MapSurfaceSpec spec, MapSurfaceSpec previous) {
    if (spec.camera == previous.camera) {
      return;
    }
    moveTo(spec.camera, duration: spec.cameraAnimationDuration);
  }

  /// Adopts a camera the renderer arrived at on its own — a pan or
  /// pinch. Ignored while an app-driven animation is in flight, where
  /// the renderer is merely echoing back the frames we just pushed.
  ///
  /// Movements smaller than [_adoptEpsilon] are also ignored: a
  /// renderer echoes back a camera we pushed with the last bits of the
  /// coordinates rounded, and adopting that would clear the pending
  /// target for no visible gain.
  void adoptFromRenderer({
    required GeoPosition center,
    required double zoom,
  }) {
    final current = _camera;
    if (current == null || isAnimating) {
      return;
    }
    final adopted = current.copyWith(center: center, zoom: zoom);
    if (!_differsMeaningfully(current, adopted)) {
      return;
    }
    _camera = adopted;
    // The target is stale the moment the user pans away from it;
    // keeping it would snap the map back on the next resize.
    _target = null;
    _emit(CameraChangeOrigin.renderer);
  }

  /// Settles the zoom onto the nearest multiple of [step], keeping the
  /// centre. A [step] of `0` disables snapping.
  void snapZoom(double step, {required Duration duration}) {
    final current = _camera;
    if (current == null || step <= 0 || isAnimating) {
      return;
    }
    final snapped = ((current.zoom / step).roundToDouble() * step).clamp(
      minZoom,
      maxZoom,
    );
    if ((snapped - current.zoom).abs() < _zoomEpsilon) {
      return;
    }
    moveTo(
      CenterZoomCameraTarget(center: current.center, zoom: snapped),
      duration: duration,
    );
  }

  void _onTick() {
    final from = _from;
    final to = _to;
    if (from == null || to == null) {
      return;
    }
    final t = _curve.transform(_animation.value);
    _camera = WebMercatorCamera(
      center: GeoPosition(
        latitude: _lerp(from.center.latitude, to.center.latitude, t),
        longitude: _lerp(
          from.center.longitude,
          to.center.longitude,
          t,
        ),
      ),
      zoom: _lerp(from.zoom, to.zoom, t),
      viewport: to.viewport,
    );
    _emit(CameraChangeOrigin.app);
  }

  WebMercatorCamera _resolve(MapCameraTarget target, Size viewport) =>
      switch (target) {
        CenterZoomCameraTarget(:final center, :final zoom) => WebMercatorCamera(
          center: center,
          zoom: zoom.clamp(minZoom, maxZoom),
          viewport: viewport,
        ),
        FitBoundsCameraTarget(:final bounds, :final padding) =>
          WebMercatorCamera.fitting(
            bounds,
            viewport: viewport,
            padding: padding,
            minZoom: minZoom,
            maxZoom: maxZoom,
          ),
      };

  void _emit(CameraChangeOrigin origin) {
    _origin = origin;
    notifyListeners();
  }
}

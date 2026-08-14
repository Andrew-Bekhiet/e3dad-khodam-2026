import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:flutter/widgets.dart';

/// The `didUpdateWidget` body both map surfaces need: push markers when
/// they change, move the camera when its target does, and do neither
/// otherwise.
///
/// A mixin rather than the same lines in each `State`: the two surfaces
/// differ in *how* they push markers and move the camera, never in when.
mixin MapSurfaceStateMixin<T extends StatefulWidget> on State<T> {
  /// The spec carried by [widget], which only the concrete surface knows
  /// how to reach.
  MapSurfaceSpec specOf(T widget);

  /// Replaces the rendered markers with [markers].
  void pushMarkers(List<MapMarkerSpec> markers);

  /// Moves the renderer's camera to [camera] over [duration].
  void moveCamera(MapCameraTarget camera, Duration duration);

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    final spec = specOf(widget);
    final previous = specOf(oldWidget);
    if (spec.markers != previous.markers) {
      pushMarkers(spec.markers);
    }
    if (spec.camera != previous.camera) {
      moveCamera(spec.camera, spec.cameraAnimationDuration);
    }
  }
}

import 'package:collection/collection.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:flutter/widgets.dart';

/// The `didUpdateWidget` body both map surfaces need: push whichever of
/// the markers, trails and tokens changed, move the camera when its
/// target does, and do nothing otherwise.
///
/// A mixin rather than the same lines in each `State`: the two surfaces
/// differ in *how* they push content and move the camera, never in when.
mixin MapSurfaceStateMixin<T extends StatefulWidget> on State<T> {
  /// The spec carried by [widget], which only the concrete surface knows
  /// how to reach.
  MapSurfaceSpec specOf(T widget);

  /// Replaces the rendered markers with [markers].
  void pushMarkers(List<MapMarkerSpec> markers);

  /// Replaces the rendered trails with [trails].
  void pushTrails(List<MapTrailSpec> trails);

  /// Replaces the rendered character tokens with [tokens].
  void pushTokens(List<MapTokenSpec> tokens);

  /// Moves the renderer's camera to [camera] over [duration].
  void moveCamera(MapCameraTarget camera, Duration duration);

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    final spec = specOf(widget);
    final previous = specOf(oldWidget);
    if (_changed(spec.markers, previous.markers)) {
      pushMarkers(spec.markers);
    }
    if (_changed(spec.trails, previous.trails)) {
      pushTrails(spec.trails);
    }
    if (_changed(spec.tokens, previous.tokens)) {
      pushTokens(spec.tokens);
    }
    if (spec.camera != previous.camera) {
      moveCamera(spec.camera, spec.cameraAnimationDuration);
    }
  }

  /// Whether the content of two lists differs.
  ///
  /// `==` on a `List` is identity, so a rebuilt-but-unchanged list is
  /// "different" from the one before it — and a widget rebuilding on an
  /// animation clock rebuilds every list on every frame. Every one of
  /// these pushes is an unawaited platform call carrying an encoded copy
  /// of the whole route, so answering this question by identity is the
  /// difference between pushing on movement and pushing at 60 Hz.
  static bool _changed<E>(List<E> spec, List<E> previous) =>
      !identical(spec, previous) &&
      !const ListEquality<Object?>().equals(spec, previous);
}

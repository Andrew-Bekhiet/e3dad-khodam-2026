import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:equatable/equatable.dart';

/// The full, provider-agnostic description of what a map surface should
/// currently show.
///
/// Deliberately excludes tile URLs and attribution text: those are
/// specific to whichever provider implements `MapSurfaceBuilder`, not to
/// the app's content.
final class MapSurfaceSpec extends Equatable {
  /// Markers to render on the surface.
  final List<MapMarkerSpec> markers;

  /// Where the camera should be, or move to.
  final MapCameraTarget camera;

  /// The most zoomed-out level the surface should allow.
  final double minZoom;

  /// The most zoomed-in level the surface should allow.
  final double maxZoom;

  /// How long the surface should take to animate to [camera] when it
  /// changes. The surface itself has no notion of "drilling down" vs.
  /// "going back", so whoever produces this spec (the navigation cubit)
  /// picks the duration per transition.
  final Duration cameraAnimationDuration;

  @override
  List<Object?> get props => [
    markers,
    camera,
    minZoom,
    maxZoom,
    cameraAnimationDuration,
  ];

  /// Creates a map surface spec.
  const MapSurfaceSpec({
    required this.markers,
    required this.camera,
    required this.minZoom,
    required this.maxZoom,
    required this.cameraAnimationDuration,
  });
}

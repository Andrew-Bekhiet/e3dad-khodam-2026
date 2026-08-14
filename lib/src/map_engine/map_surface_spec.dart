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

  /// Called with a marker's id when the renderer reports a tap on it.
  ///
  /// Only ever called for markers whose [MapMarkerSpec.isInteractive] is
  /// true. The surface reports the tap rather than the marker carrying
  /// its own callback, because a marker is now a GeoJSON feature and a
  /// feature cannot hold a closure.
  final void Function(String markerId) onMarkerTap;

  @override
  List<Object?> get props => [
    markers,
    camera,
    minZoom,
    maxZoom,
    cameraAnimationDuration,
  ];

  /// Creates a map surface spec.
  ///
  /// [onMarkerTap] is excluded from equality, as closures are never
  /// structurally comparable.
  const MapSurfaceSpec({
    required this.markers,
    required this.camera,
    required this.minZoom,
    required this.maxZoom,
    required this.cameraAnimationDuration,
    required this.onMarkerTap,
  });
}

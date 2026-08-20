import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
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

  /// Routes already travelled, drawn under the markers. Empty for a plain
  /// map with nobody moving over it.
  final List<MapTrailSpec> trails;

  /// Characters standing on the map, drawn over everything else. Empty
  /// for a plain map with nobody on it.
  final List<MapTokenSpec> tokens;

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

  /// Called when a tap lands on the map itself rather than on a marker.
  ///
  /// The renderer decides which of the two a tap was: it is the only
  /// thing that knows where the markers ended up on screen. Null for a
  /// surface whose empty space means nothing.
  final void Function()? onSurfaceTap;

  @override
  List<Object?> get props => [
    markers,
    trails,
    tokens,
    camera,
    minZoom,
    maxZoom,
    cameraAnimationDuration,
  ];

  /// Creates a map surface spec.
  ///
  /// [onMarkerTap] and [onSurfaceTap] are excluded from equality, as
  /// closures are never structurally comparable.
  const MapSurfaceSpec({
    required this.markers,
    required this.camera,
    required this.minZoom,
    required this.maxZoom,
    required this.cameraAnimationDuration,
    required this.onMarkerTap,
    this.trails = const [],
    this.tokens = const [],
    this.onSurfaceTap,
  });
}

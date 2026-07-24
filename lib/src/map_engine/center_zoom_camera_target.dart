part of 'map_camera_target.dart';

/// Requests the camera center on [center] at [zoom].
final class CenterZoomCameraTarget extends MapCameraTarget {
  /// The point to center the viewport on.
  final GeoPosition center;

  /// The map provider's zoom level; scale and semantics are provider
  /// defined, but larger values always mean more zoomed in.
  final double zoom;

  @override
  List<Object?> get props => [center, zoom];

  /// Creates a center/zoom camera target.
  const CenterZoomCameraTarget({required this.center, required this.zoom});
}

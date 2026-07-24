part of 'map_camera_target.dart';

/// Requests the camera frame exactly [bounds], inset by [padding] so
/// markers near the edge remain fully visible.
final class FitBoundsCameraTarget extends MapCameraTarget {
  /// The geographic area to fit within the viewport.
  final GeoBounds bounds;

  /// Screen-space inset applied around [bounds] when fitting.
  final EdgeInsets padding;

  @override
  List<Object?> get props => [bounds, padding];

  /// Creates a bounds-fitting camera target.
  const FitBoundsCameraTarget({required this.bounds, required this.padding});
}

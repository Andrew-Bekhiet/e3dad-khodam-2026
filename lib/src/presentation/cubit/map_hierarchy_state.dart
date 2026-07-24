import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:equatable/equatable.dart';

/// A snapshot of what the journey map should currently show: the nodes to
/// draw, the drill-down breadcrumb, and the camera target. The dataset is
/// a synchronous compile-time constant, so there is no loading variant.
final class MapHierarchyState extends Equatable {
  /// Exactly the nodes that should be drawn as markers right now.
  final List<MapNode> visibleNodes;

  /// The chain of ancestors from a root down to the node currently
  /// drilled into; empty while showing the root four-category cross.
  final List<MapNode> breadcrumb;

  /// Where the map should be looking.
  final MapCameraTarget camera;

  /// How long the map surface should take to animate to [camera]; set per
  /// transition (drilling down is slower than going back) so the surface
  /// doesn't have to infer direction itself.
  final Duration cameraAnimationDuration;

  /// Whether the root cross (not a drilled-into node) is showing.
  bool get isAtRoot => breadcrumb.isEmpty;

  /// The node currently drilled into, or null while [isAtRoot].
  MapNode? get focusedNode => switch (breadcrumb) {
    [] => null,
    [..., final last] => last,
  };

  @override
  List<Object?> get props => [
    visibleNodes,
    breadcrumb,
    camera,
    cameraAnimationDuration,
  ];

  /// Creates a hierarchy state.
  const MapHierarchyState({
    required this.visibleNodes,
    required this.breadcrumb,
    required this.camera,
    required this.cameraAnimationDuration,
  });
}

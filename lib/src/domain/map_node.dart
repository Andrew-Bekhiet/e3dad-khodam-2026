import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';
import 'package:equatable/equatable.dart';

part 'category_node.dart';
part 'place_node.dart';

/// A single node in the fixed three-level journey-map hierarchy: a root
/// category, or a place nested one or two levels beneath it.
///
/// Sealed so presentation code can switch exhaustively over its variants
/// ([CategoryNode] and [PlaceNode]) when choosing marker styling. Split
/// across `part` files (one class per file) since Dart requires a sealed
/// type's direct subtypes to live in the same library.
sealed class MapNode extends Equatable {
  /// Stable identifier used for lookups by `JourneyMapTree`; also
  /// distinguishes nodes that might otherwise share a display [label].
  final String id;

  /// The Arabic text shown on the map marker and in breadcrumbs.
  final String label;

  /// Where this node's marker is anchored on the map.
  final GeoPosition position;

  /// Nodes one level deeper in the hierarchy; empty for leaves.
  final List<MapNode> children;

  /// Whether tapping this node's marker should drill into [children]
  /// rather than treat it as a terminal place.
  bool get isExpandable => children.isNotEmpty;

  /// Creates a node; subclasses supply their own discriminating field.
  const MapNode({
    required this.id,
    required this.label,
    required this.position,
    required this.children,
  });
}

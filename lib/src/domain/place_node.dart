part of 'map_node.dart';

/// A place-level node: a continent, country, sea, island, or city nested
/// one or two levels beneath a root [CategoryNode].
final class PlaceNode extends MapNode {
  /// The place taxonomy used to choose marker styling.
  final PlaceKind kind;

  /// Compares every field, including [MapNode.children] — two nodes with
  /// the same [MapNode.id] but different data are considered different.
  @override
  List<Object?> get props => [id, label, position, children, kind];

  /// Creates a place node.
  const PlaceNode({
    required this.kind,
    required super.id,
    required super.label,
    required super.position,
    required super.children,
  });
}

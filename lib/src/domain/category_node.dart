part of 'map_node.dart';

/// A root-level node representing one of the four top categories
/// (continents, countries, seas, islands) that together form the cross
/// layout over the Mediterranean.
final class CategoryNode extends MapNode {
  /// Which arm of the cross this category occupies.
  final CrossArm arm;

  /// Compares every field, including [MapNode.children] — two nodes with
  /// the same [MapNode.id] but different data are considered different.
  @override
  List<Object?> get props => [id, label, position, children, arm];

  /// Creates a root category node.
  const CategoryNode({
    required this.arm,
    required super.id,
    required super.label,
    required super.position,
    required super.children,
  });
}

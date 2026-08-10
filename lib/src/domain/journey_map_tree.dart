import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:equatable/equatable.dart';

/// The full St Paul journey-map hierarchy, plus indexes for fast lookup
/// by node id.
///
/// The indexes are built once in the [JourneyMapTree.new] factory (a
/// depth-first walk over [roots]) rather than computed lazily with `late`,
/// since the dataset is small and fixed for the lifetime of the tree.
final class JourneyMapTree extends Equatable {
  /// Recursively records [node] and its ancestor chain into the two
  /// indexes, and appends it to [depthFirstNodes]; [ancestors] excludes
  /// [node] itself.
  static void _index(
    MapNode node,
    List<MapNode> ancestors,
    Map<String, MapNode> nodesById,
    Map<String, List<MapNode>> pathsById,
    List<MapNode> depthFirstNodes,
  ) {
    final path = [...ancestors, node];
    nodesById[node.id] = node;
    pathsById[node.id] = path;
    depthFirstNodes.add(node);
    for (final child in node.children) {
      _index(child, path, nodesById, pathsById, depthFirstNodes);
    }
  }

  /// Every top-level category node, e.g. قارات، بلاد، بحار، جزر.
  final List<MapNode> roots;

  final Map<String, MapNode> _nodesById;
  final Map<String, List<MapNode>> _pathsById;

  /// Every node in the tree, in depth-first pre-order: each root, then
  /// its entire subtree left to right, before moving to the next root —
  /// the order a linear "walk every node" navigation (e.g. a slideshow)
  /// should visit them in. Captured once during construction, not
  /// recomputed on access.
  final List<MapNode> depthFirstNodes;

  @override
  List<Object?> get props => [roots];

  /// Builds the tree and its lookup indexes from a fixed set of [roots].
  factory JourneyMapTree(List<MapNode> roots) {
    final nodesById = <String, MapNode>{};
    final pathsById = <String, List<MapNode>>{};
    final depthFirstNodes = <MapNode>[];
    for (final root in roots) {
      _index(root, const [], nodesById, pathsById, depthFirstNodes);
    }

    return JourneyMapTree._(
      roots,
      nodesById,
      pathsById,
      List.unmodifiable(depthFirstNodes),
    );
  }

  const JourneyMapTree._(
    this.roots,
    this._nodesById,
    this._pathsById,
    this.depthFirstNodes,
  );

  /// Finds the node with [id] anywhere in the tree, or null if absent.
  MapNode? findById(String id) => _nodesById[id];

  /// The ancestor chain from a root down to and including the node with
  /// [id]; empty if no such node exists.
  List<MapNode> pathTo(String id) => _pathsById[id] ?? const [];

  /// Direct children of the node with [parentId], or [roots] when
  /// [parentId] is null (i.e. the top of the hierarchy).
  List<MapNode> childrenOf(String? parentId) => switch (parentId) {
    null => roots,
    final id => findById(id)?.children ?? const [],
  };
}

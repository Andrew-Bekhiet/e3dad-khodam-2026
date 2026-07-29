import 'package:bloc/bloc.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_tree.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/map_hierarchy_state.dart';
import 'package:flutter/widgets.dart';

/// Drives drill-down navigation over the journey map's fixed three-level
/// hierarchy, translating tree position into what should be visible and
/// where the camera should look.
final class MapHierarchyCubit extends Cubit<MapHierarchyState> {
  /// The exact box the four cross anchors were placed to fill, used
  /// whenever the root is showing so the cross always reads as a cross
  /// regardless of which markers happen to be visible.
  static const GeoBounds _rootBounds = GeoBounds(
    south: 28.5,
    west: 15.0,
    north: 46.5,
    east: 37.0,
  );

  /// Screen-space inset applied whenever the camera fits a set of
  /// markers, for every drill/back fit (root included) — the larger top
  /// value clears the app bar and breadcrumb region. Left/right are wide
  /// enough to keep a level-1 label pill (150px wide, so 75px half-width)
  /// fully on screen even when its marker sits exactly at the fit
  /// envelope's edge, which the extreme child in any fitted set always
  /// does.
  static const EdgeInsets _fitPadding = EdgeInsets.only(
    top: 100,
    left: 84,
    right: 84,
    bottom: 56,
  );

  /// Degrees a degenerate (zero-area) bounding box is padded by on every
  /// edge before being fitted — needed for a single visible node, e.g.
  /// رومية alone under إيطاليا, whose bounds would otherwise be a point.
  static const double _degenerateBoundsPadding = 0.5;

  /// Duration for a drill-down camera move (tap a node → fit its
  /// children's bounds) — slightly slower than [_goBackDuration] since
  /// it's a less "familiar" direction of travel for the user.
  static const Duration _drillDownDuration = Duration(milliseconds: 500);

  /// Duration for a go-back camera move (up one level), and the fallback
  /// used for the initial/root state.
  static const Duration _goBackDuration = Duration(milliseconds: 400);

  /// Duration for a slideshow step ([forward]/[backward]), used for both
  /// directions since neither reads as more "familiar" than the other.
  static const Duration _traverseDuration = Duration(milliseconds: 450);

  /// Fixed camera target for the root cross; never recomputed since the
  /// four category anchors are compile-time constants.
  static const MapCameraTarget _rootCamera = FitBoundsCameraTarget(
    bounds: _rootBounds,
    padding: _fitPadding,
  );

  /// Loaded once at construction — this is data pulled from the
  /// repository, not view state, so it is kept off [MapHierarchyState].
  final JourneyMapTree _tree;

  /// Loads the tree from [repository] once and starts at the root cross.
  MapHierarchyCubit(JourneyMapRepository repository)
    : this._(repository.loadTree());

  MapHierarchyCubit._(this._tree) : super(_rootState(_tree, _goBackDuration));

  /// Shows the children of [nodeId] and extends the breadcrumb to it.
  /// Does nothing at all — not even a re-emit — if [nodeId] is unknown or
  /// names a leaf place with no children to drill into.
  void drillDown(String nodeId) {
    final node = _tree.findById(nodeId);
    if (node == null || !node.isExpandable) {
      return;
    }

    emit(_focusState(node, _drillDownDuration));
  }

  /// Goes to next sibling node, or to next parent node if at the end of the
  /// current level.
  /// Goes back to original overview if at the end of the hierarchy.
  void forward() {
    _traverse(1);
  }

  /// Moves to previous sibling node, or to previous parent node if at the
  /// start of the current level.
  /// Goes back to original overview if at the start of the hierarchy.
  void backward() {
    _traverse(-1);
  }

  /// Steps [step] positions through the depth-first walk of every node,
  /// with the overview as one extra position at both ends of the cycle —
  /// so this composes with manual [drillDown]/[goBack]: it always
  /// continues from [MapHierarchyState.focusedNode], however that was
  /// reached. Only ever called with ±1 by [forward]/[backward], but the
  /// bounds check below keeps any step size correct.
  void _traverse(int step) {
    final flat = _tree.depthFirstNodes;
    final current = state.focusedNode;
    final MapNode? target;
    if (current == null) {
      target = step > 0 ? flat.first : flat.last;
    } else {
      final index = flat.indexWhere((node) => node.id == current.id);
      final next = index + step;
      target = (next < 0 || next >= flat.length) ? null : flat[next];
    }

    emit(
      switch (target) {
        null => _rootState(_tree, _traverseDuration),
        final node => _focusState(node, _traverseDuration),
      },
    );
  }

  /// Moves up exactly one level; from depth 1 this returns to the root
  /// cross. Does nothing when already at the root.
  void goBack() {
    final breadcrumb = state.breadcrumb;
    if (breadcrumb.isEmpty) {
      return;
    }
    final ancestors = breadcrumb.sublist(0, breadcrumb.length - 1);
    emit(
      switch (ancestors) {
        [] => _rootState(_tree, _goBackDuration),
        [..., final parent] => MapHierarchyState(
          visibleNodes: parent.children,
          breadcrumb: ancestors,
          camera: _cameraFor(parent.children),
          cameraAnimationDuration: _goBackDuration,
        ),
      },
    );
  }

  /// Returns straight to the root cross.
  void reset() => emit(_rootState(_tree, _goBackDuration));

  /// The state produced by focusing directly on [node]: its children when
  /// [node] is expandable (what drilling into it means), or just [node]
  /// itself when it's a leaf city — so the slideshow can stop on a leaf
  /// without a parent already showing it. Shared by [drillDown] and
  /// [_traverse].
  MapHierarchyState _focusState(MapNode node, Duration duration) {
    final visibleNodes = node.isExpandable ? node.children : [node];

    return MapHierarchyState(
      visibleNodes: visibleNodes,
      breadcrumb: _tree.pathTo(node.id),
      camera: _cameraFor(visibleNodes),
      cameraAnimationDuration: duration,
    );
  }

  static MapHierarchyState _rootState(JourneyMapTree tree, Duration duration) =>
      MapHierarchyState(
        visibleNodes: tree.roots,
        breadcrumb: const [],
        camera: _rootCamera,
        cameraAnimationDuration: duration,
      );

  static MapCameraTarget _cameraFor(List<MapNode> nodes) =>
      FitBoundsCameraTarget(
        bounds: _fittableBounds(nodes),
        padding: _fitPadding,
      );

  /// Computes the enclosing box for [nodes], padding it out when it would
  /// otherwise be degenerate (zero area, from a single node).
  static GeoBounds _fittableBounds(List<MapNode> nodes) {
    final bounds = GeoBounds.containing(nodes.map((node) => node.position));
    final isDegenerate =
        bounds.north == bounds.south || bounds.east == bounds.west;

    return isDegenerate ? bounds.padded(_degenerateBoundsPadding) : bounds;
  }
}

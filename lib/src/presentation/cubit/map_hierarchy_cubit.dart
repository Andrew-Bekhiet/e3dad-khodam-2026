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
  /// enough to keep an 8em label at the 34px projector scale, including
  /// its halo, fully on screen when its marker sits exactly at a fitted
  /// set's edge.
  static const EdgeInsets _fitPadding = EdgeInsets.only(
    top: 100,
    left: 144,
    right: 144,
    bottom: 144,
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

  static MapHierarchyState _rootState(
    JourneyMapTree tree,
    Duration duration, {
    int slideIndex = 0,
  }) => MapHierarchyState(
    visibleNodes: tree.roots,
    breadcrumb: const [],
    camera: _rootCamera,
    cameraAnimationDuration: duration,
    slideIndex: slideIndex,
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

    return isDegenerate
        ? bounds.padded(_degenerateBoundsPadding)
        : bounds.padded(1);
  }

  /// Loaded once at construction — this is data pulled from the
  /// repository, not view state, so it is kept off [MapHierarchyState].
  final JourneyMapTree _tree;

  /// Node ids in the order [forward] visits them, `null` being the root
  /// cross; the root recurs, so a position here is not recoverable from
  /// the focused node alone.
  final List<String?> _slideshow;

  /// Loads the tree from [repository] once and starts at the root cross.
  MapHierarchyCubit(JourneyMapRepository repository)
    : this._(repository.loadTree(), repository.loadSlideshow());

  MapHierarchyCubit._(this._tree, this._slideshow)
    : super(_rootState(_tree, _goBackDuration));

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

  /// Advances one slide, wrapping from the last back to the root cross.
  void forward() {
    _traverse(1);
  }

  /// Retreats one slide, wrapping from the root cross to the last slide.
  void backward() {
    _traverse(-1);
  }

  /// Steps [step] slides through [_slideshow] from
  /// [MapHierarchyState.slideIndex], so this composes with manual
  /// [drillDown]/[goBack]: they land on the slide of whatever they focus.
  void _traverse(int step) {
    final index = (state.slideIndex + step) % _slideshow.length;
    final target = switch (_slideshow[index]) {
      null => null,
      final id => _tree.findById(id),
    };

    emit(
      switch (target) {
        null => _rootState(_tree, _traverseDuration, slideIndex: index),
        final node => _focusState(node, _traverseDuration, slideIndex: index),
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
        [..., final parent] => _focusState(parent, _goBackDuration),
      },
    );
  }

  /// Returns straight to the root cross.
  void reset() => emit(_rootState(_tree, _goBackDuration));

  /// The state produced by focusing directly on [node]: its children when
  /// [node] is expandable (what drilling into it means), or just [node]
  /// itself when it's a leaf city — so the slideshow can stop on a leaf
  /// without a parent already showing it. Shared by [drillDown],
  /// [goBack] and [_traverse]; the latter passes the [slideIndex] it
  /// stepped to, the others take the slide of [node] or its nearest
  /// ancestor in the slideshow.
  MapHierarchyState _focusState(
    MapNode node,
    Duration duration, {
    int? slideIndex,
  }) {
    final visibleNodes = node.isExpandable ? node.children : [node];
    final breadcrumb = _tree.pathTo(node.id);

    return MapHierarchyState(
      visibleNodes: visibleNodes,
      breadcrumb: breadcrumb,
      camera: _cameraFor(visibleNodes),
      cameraAnimationDuration: duration,
      slideIndex: slideIndex ?? _slideIndexAlong(breadcrumb),
    );
  }

  /// The slide of the deepest node in [breadcrumb] that has one; the
  /// root cross's first slide when none does.
  int _slideIndexAlong(List<MapNode> breadcrumb) {
    for (final node in breadcrumb.reversed) {
      final index = _slideshow.indexOf(node.id);
      if (index >= 0) {
        return index;
      }
    }

    return 0;
  }
}

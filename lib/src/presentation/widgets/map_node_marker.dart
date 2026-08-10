import 'dart:math' as math;

import 'package:e3dad_khodam_2026/src/domain/cross_arm.dart';
import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/marker_label_pill.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/marker_visual.dart';
import 'package:flutter/material.dart';

/// The painted marker for one [MapNode]: shape/size/color/icon per the
/// design spec (§2), its label, and a one-shot entrance animation (§5,
/// entrance only — see [MapNodeMarker.new]). Leaf places (cities) render
/// inert: no tap handling, `IgnorePointer`-wrapped so they never steal
/// pan/zoom gestures from the map beneath them.
final class MapNodeMarker extends StatelessWidget {
  static const double _labelGap = 4.0;
  static const Duration _enterDuration = Duration(milliseconds: 250);
  static const double _enterScaleBegin = 0.6;
  static const double _enterScaleEnd = 1.0;
  static const double _opacityBegin = 0.0;
  static const double _opacityEnd = 1.0;
  static const Color _white = Color(0xFFFFFFFF);

  /// The fixed box `ProjectedMarkerLayer` reserves for this marker —
  /// top shape segment + gap + label, matching what [build] paints.
  static Size layoutSize(MapNode node) {
    final visual = MarkerVisual.forNode(node);

    return Size(
      visual.boxWidth,
      visual.topSegmentSize + _labelGap + visual.label.segmentHeight,
    );
  }

  /// Where within [layoutSize] the geographic point sits: horizontally
  /// centered, vertically at the middle of the painted shape — not the
  /// box center — so the shape, not the label beneath it, anchors to
  /// the coordinate. For a box of total height `H` with the anchor
  /// shape of height `D` at the top, the y-alignment that puts the
  /// shape's own center on the point is `1 - D / H` (the naive
  /// `D / H - 1` has the wrong sign and pins the label, not the shape,
  /// to the coordinate). `ProjectedMarkerLayer` consumes it.
  static Alignment anchorAlignment(MapNode node) {
    final visual = MarkerVisual.forNode(node);
    final totalHeight =
        visual.topSegmentSize + _labelGap + visual.label.segmentHeight;

    return Alignment(0, 1 - (visual.topSegmentSize / totalHeight));
  }

  static IconData? _iconFor(MapNode node) => switch (node) {
    CategoryNode(:final arm) => _iconForArm(arm),
    PlaceNode(:final kind) => _iconForPlaceKind(kind),
  };

  static IconData _iconForArm(CrossArm arm) => switch (arm) {
    CrossArm.top => Icons.public,
    CrossArm.bottom => Icons.flag,
    CrossArm.left => Icons.waves,
    CrossArm.right => Icons.beach_access,
  };

  static IconData? _iconForPlaceKind(PlaceKind kind) => switch (kind) {
    PlaceKind.sea => Icons.waves,
    PlaceKind.island => Icons.terrain,
    PlaceKind.continent || PlaceKind.country || PlaceKind.city => null,
  };

  /// The node this marker represents.
  final MapNode node;

  /// Invoked on tap; never wired up for leaf (non-expandable) nodes.
  final VoidCallback onTap;

  /// Creates the marker widget for [node]. Each build re-plays the
  /// 250ms fade+scale entrance (spec §5) because [build] keys it to
  /// [MapNode.id], so a fresh marker at a new level always animates in;
  /// the outgoing-fade/staggering half of §5 is intentionally not
  /// implemented (see round notes).
  const MapNodeMarker({required this.node, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final visual = MarkerVisual.forNode(node);
    final icon = _iconFor(node);
    final shape = _MarkerShapeSegment(visual);

    final content = TweenAnimationBuilder<double>(
      key: ValueKey('marker-enter-${node.id}'),
      tween: Tween(begin: _opacityBegin, end: _opacityEnd),
      duration: _enterDuration,
      curve: Curves.easeOut,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: _enterScaleBegin + (_enterScaleEnd - _enterScaleBegin) * t,
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: _labelGap,
        children: [
          SizedBox(
            width: visual.topSegmentSize,
            height: visual.topSegmentSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                shape,
                if (icon != null)
                  Icon(icon, size: visual.iconSize, color: _white),
              ],
            ),
          ),
          MarkerLabelPill(
            text: node.label,
            fontSize: visual.label.fontSize,
            fontWeight: visual.label.fontWeight,
            textColor: visual.label.color,
            showBackground: visual.label.showPill,
          ),
        ],
      ),
    );

    if (!node.isExpandable) {
      return IgnorePointer(child: content);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

/// The painted outline shape at the top of a [MapNodeMarker], factored
/// into its own widget rather than a function returning a widget so
/// Flutter can diff and rebuild it independently of the marker's label
/// and entrance animation.
final class _MarkerShapeSegment extends StatelessWidget {
  static const Color _shadowBase = Color(0xFF000000);
  static const double _diamondRotation = math.pi / 4;
  static const double _diamondInset = 0.75;

  static BoxShadow _shadowFor(MarkerShadow shadow) => BoxShadow(
    color: _shadowBase.withValues(alpha: shadow.opacity),
    blurRadius: shadow.blur,
    offset: Offset(0, shadow.offsetDy),
  );

  final MarkerVisual visual;

  const _MarkerShapeSegment(this.visual);

  @override
  Widget build(BuildContext context) {
    final style = visual.shapeStyle;

    return switch (style.shape) {
      MarkerShape.circle => Container(
        width: style.paintedDiameter,
        height: style.paintedDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: style.color,
          border: style.hasRing
              ? Border.all(color: MapNodeMarker._white, width: style.ringWidth)
              : null,
          boxShadow: [_shadowFor(visual.shadow)],
        ),
      ),
      MarkerShape.roundedSquare => Container(
        width: style.paintedDiameter,
        height: style.paintedDiameter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style.cornerRadius),
          color: style.color,
          boxShadow: [_shadowFor(visual.shadow)],
        ),
      ),
      MarkerShape.diamond => Transform.rotate(
        angle: _diamondRotation,
        child: Container(
          width: style.paintedDiameter * _diamondInset,
          height: style.paintedDiameter * _diamondInset,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(style.cornerRadius),
            color: style.color,
            boxShadow: [_shadowFor(visual.shadow)],
          ),
        ),
      ),
    };
  }
}

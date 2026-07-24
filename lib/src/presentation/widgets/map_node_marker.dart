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
  static const Color _shadowBase = Color(0xFF000000);
  static const double _diamondRotation = math.pi / 4;
  static const double _diamondInset = 0.75;

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

  /// The fixed box flutter_map must reserve for this marker — top shape
  /// segment + gap + label, matching exactly what [build] paints.
  static Size layoutSize(MapNode node) {
    final visual = MarkerVisual.forNode(node);
    return Size(
      visual.boxWidth,
      visual.topSegmentSize + _labelGap + visual.labelSegmentHeight,
    );
  }

  /// Where within [layoutSize] the geographic point sits: horizontally
  /// centered, vertically at the middle of the painted shape — not the
  /// box center — so the shape, not the label beneath it, anchors to
  /// the coordinate. Derived from flutter_map 8's `Marker` layout: for a
  /// box of total height `H` with the anchor shape of height `D` at the
  /// top, the y-alignment that puts the shape's own center on the point
  /// is `1 - D / H` (confirmed against `MarkerLayer`'s positioning math;
  /// the naive `D / H - 1` has the wrong sign and pins the label, not
  /// the shape, to the coordinate).
  static Alignment anchorAlignment(MapNode node) {
    final visual = MarkerVisual.forNode(node);
    final totalHeight =
        visual.topSegmentSize + _labelGap + visual.labelSegmentHeight;
    return Alignment(0, 1 - (visual.topSegmentSize / totalHeight));
  }

  static IconData? _iconFor(MapNode node) => switch (node) {
    CategoryNode(:final arm) => switch (arm) {
      CrossArm.top => Icons.public,
      CrossArm.bottom => Icons.flag,
      CrossArm.left => Icons.waves,
      CrossArm.right => Icons.beach_access,
    },
    PlaceNode(:final kind) => switch (kind) {
      PlaceKind.sea => Icons.waves,
      PlaceKind.island => Icons.terrain,
      PlaceKind.continent || PlaceKind.country || PlaceKind.city => null,
    },
  };

  static BoxShadow _shadowFor(MarkerVisual visual) => BoxShadow(
    color: _shadowBase.withValues(alpha: visual.shadowOpacity),
    blurRadius: visual.shadowBlur,
    offset: Offset(0, visual.shadowOffsetDy),
  );

  @override
  Widget build(BuildContext context) {
    final visual = MarkerVisual.forNode(node);
    final icon = _iconFor(node);
    final shape = switch (visual.shape) {
      MarkerShape.circle => Container(
        width: visual.paintedDiameter,
        height: visual.paintedDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: visual.color,
          border: visual.hasRing
              ? Border.all(color: _white, width: visual.ringWidth)
              : null,
          boxShadow: [_shadowFor(visual)],
        ),
      ),
      MarkerShape.roundedSquare => Container(
        width: visual.paintedDiameter,
        height: visual.paintedDiameter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(visual.cornerRadius),
          color: visual.color,
          boxShadow: [_shadowFor(visual)],
        ),
      ),
      MarkerShape.diamond => Transform.rotate(
        angle: _diamondRotation,
        child: Container(
          width: visual.paintedDiameter * _diamondInset,
          height: visual.paintedDiameter * _diamondInset,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(visual.cornerRadius),
            color: visual.color,
            boxShadow: [_shadowFor(visual)],
          ),
        ),
      ),
    };

    final content = TweenAnimationBuilder<double>(
      key: ValueKey('marker-enter-${node.id}'),
      tween: Tween(begin: _opacityBegin, end: _opacityEnd),
      duration: _enterDuration,
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
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
            fontSize: visual.labelFontSize,
            fontWeight: visual.labelFontWeight,
            textColor: visual.labelColor,
            showBackground: visual.showLabelPill,
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

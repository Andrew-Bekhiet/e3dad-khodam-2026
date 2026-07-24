import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';
import 'package:flutter/material.dart';

/// The fixed, per-node-kind painting recipe for `MapNodeMarker`: size,
/// shape, color, icon and shadow, taken from the design spec's marker
/// table (§2). Every instance is a compile-time constant, since none of
/// this varies at runtime — only which profile applies to a given node.
final class MarkerVisual {
  static const MarkerVisual _category = MarkerVisual(
    topSegmentSize: 56,
    paintedDiameter: 56,
    shape: MarkerShape.circle,
    cornerRadius: 0,
    color: Color(0xFF123C69),
    icon: null,
    iconSize: 28,
    hasRing: true,
    ringWidth: 2,
    shadowBlur: 8,
    shadowOffsetDy: 2,
    shadowOpacity: 0.3,
    boxWidth: 110,
    labelSegmentHeight: 23,
    labelFontSize: 15,
    labelFontWeight: FontWeight.w700,
    labelColor: Color(0xFF1A1A1A),
    showLabelPill: true,
  );

  static const MarkerVisual _continent = MarkerVisual(
    topSegmentSize: 48,
    paintedDiameter: 44,
    shape: MarkerShape.circle,
    cornerRadius: 0,
    color: Color(0xFF2E7D32),
    icon: null,
    iconSize: 0,
    hasRing: false,
    ringWidth: 0,
    shadowBlur: 6,
    shadowOffsetDy: 2,
    shadowOpacity: 0.22,
    boxWidth: 150,
    labelSegmentHeight: 21,
    labelFontSize: 13,
    labelFontWeight: FontWeight.w600,
    labelColor: Color(0xFF1A1A1A),
    showLabelPill: true,
  );

  static const MarkerVisual _country = MarkerVisual(
    topSegmentSize: 48,
    paintedDiameter: 44,
    shape: MarkerShape.roundedSquare,
    cornerRadius: 10,
    color: Color(0xFFC77B00),
    icon: null,
    iconSize: 0,
    hasRing: false,
    ringWidth: 0,
    shadowBlur: 6,
    shadowOffsetDy: 2,
    shadowOpacity: 0.22,
    boxWidth: 150,
    labelSegmentHeight: 21,
    labelFontSize: 13,
    labelFontWeight: FontWeight.w600,
    labelColor: Color(0xFF1A1A1A),
    showLabelPill: true,
  );

  static const MarkerVisual _sea = MarkerVisual(
    topSegmentSize: 48,
    paintedDiameter: 40,
    shape: MarkerShape.diamond,
    cornerRadius: 6,
    color: Color(0xFF0288D1),
    icon: Icons.waves,
    iconSize: 18,
    hasRing: false,
    ringWidth: 0,
    shadowBlur: 5,
    shadowOffsetDy: 1,
    shadowOpacity: 0.18,
    boxWidth: 150,
    labelSegmentHeight: 21,
    labelFontSize: 13,
    labelFontWeight: FontWeight.w600,
    labelColor: Color(0xFF1A1A1A),
    showLabelPill: true,
  );

  static const MarkerVisual _island = MarkerVisual(
    topSegmentSize: 48,
    paintedDiameter: 40,
    shape: MarkerShape.circle,
    cornerRadius: 0,
    color: Color(0xFFC2703D),
    icon: Icons.terrain,
    iconSize: 18,
    hasRing: false,
    ringWidth: 0,
    shadowBlur: 5,
    shadowOffsetDy: 1,
    shadowOpacity: 0.18,
    boxWidth: 150,
    labelSegmentHeight: 21,
    labelFontSize: 13,
    labelFontWeight: FontWeight.w600,
    labelColor: Color(0xFF1A1A1A),
    showLabelPill: true,
  );

  static const MarkerVisual _city = MarkerVisual(
    topSegmentSize: 18,
    paintedDiameter: 18,
    shape: MarkerShape.circle,
    cornerRadius: 0,
    color: Color(0xFF455A64),
    icon: null,
    iconSize: 0,
    hasRing: false,
    ringWidth: 0,
    shadowBlur: 0,
    shadowOffsetDy: 0,
    shadowOpacity: 0,
    boxWidth: 90,
    labelSegmentHeight: 14,
    labelFontSize: 11,
    labelFontWeight: FontWeight.w500,
    labelColor: Color(0xFF2B2B2B),
    showLabelPill: false,
  );

  /// Square footprint of the painted shape's bounding box; also the
  /// minimum Material tap-target size for non-leaf markers (city markers
  /// have no enlarged target, so this equals [paintedDiameter] for them).
  final double topSegmentSize;

  /// The shape's own painted size, which can be smaller than
  /// [topSegmentSize] when the tap target is padded out to 48dp.
  final double paintedDiameter;

  /// Which outline [MarkerShape] to paint.
  final MarkerShape shape;

  /// Corner radius for [MarkerShape.roundedSquare]/[MarkerShape.diamond];
  /// unused for a plain circle.
  final double cornerRadius;

  /// The kind's fixed fill color (spec §3) — constant across light/dark
  /// app themes since the OSM basemap is always light.
  final Color color;

  /// Centered white icon, or null for a plain disc/shape.
  final IconData? icon;

  /// Size of [icon]; unused when [icon] is null.
  final double iconSize;

  /// Whether to paint the 2dp white separator ring (category markers
  /// only), which visually ranks them above lower levels.
  final bool hasRing;

  /// Width of the ring described by [hasRing].
  final double ringWidth;

  /// Drop-shadow blur radius.
  final double shadowBlur;

  /// Drop-shadow vertical offset (shadows in this spec are never
  /// horizontally offset).
  final double shadowOffsetDy;

  /// Drop-shadow opacity, `0`–`1`; `0` paints no shadow (city markers).
  final double shadowOpacity;

  /// Fixed marker box width flutter_map must reserve — wide enough for
  /// this tier's longest known Arabic label at [labelFontSize].
  final double boxWidth;

  /// Fixed height reserved below the shape (and gap) for the label.
  /// Derived, not guessed: `ceil(labelFontSize * MarkerLabelPill.lineHeight)`,
  /// plus `2 * MarkerLabelPill._pillVerticalPadding` (2 * 2 = 4) when
  /// [showLabelPill] is true. Bare city labels skip the padding term.
  final double labelSegmentHeight;

  /// Label font size in logical pixels (spec §4).
  final double labelFontSize;

  /// Label font weight (spec §4).
  final FontWeight labelFontWeight;

  /// Label text color — on the white pill for non-city kinds, or the
  /// bare on-tile color for city labels.
  final Color labelColor;

  /// Whether the label sits on a white pill background, or bare on the
  /// tile (city markers only, per spec §2's legibility rationale).
  final bool showLabelPill;

  /// Creates a fixed visual profile; see individual field docs.
  const MarkerVisual({
    required this.topSegmentSize,
    required this.paintedDiameter,
    required this.shape,
    required this.cornerRadius,
    required this.color,
    required this.icon,
    required this.iconSize,
    required this.hasRing,
    required this.ringWidth,
    required this.shadowBlur,
    required this.shadowOffsetDy,
    required this.shadowOpacity,
    required this.boxWidth,
    required this.labelSegmentHeight,
    required this.labelFontSize,
    required this.labelFontWeight,
    required this.labelColor,
    required this.showLabelPill,
  });

  /// Picks the fixed profile for [node]'s kind: one shared profile for
  /// every root [CategoryNode], and one per [PlaceKind] for [PlaceNode]s.
  static MarkerVisual forNode(MapNode node) => switch (node) {
    CategoryNode() => _category,
    PlaceNode(:final kind) => switch (kind) {
      PlaceKind.continent => _continent,
      PlaceKind.country => _country,
      PlaceKind.sea => _sea,
      PlaceKind.island => _island,
      PlaceKind.city => _city,
    },
  };
}

/// The shape a [MarkerVisual] paints its top segment as.
enum MarkerShape {
  /// A plain filled circle (optionally ringed, for category markers).
  circle,

  /// A filled rounded-corner square.
  roundedSquare,

  /// A rotated square rendered as a diamond.
  diamond,
}

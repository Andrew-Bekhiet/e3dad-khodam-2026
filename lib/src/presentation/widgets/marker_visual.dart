import 'package:e3dad_khodam_2026/src/domain/map_node.dart';
import 'package:e3dad_khodam_2026/src/domain/place_kind.dart';
import 'package:flutter/material.dart';

/// The fixed, per-node-kind painting recipe for `MapNodeMarker`: size,
/// shape, color and shadow, taken from the design spec's marker table
/// (§2). Every instance is a compile-time constant, since none of this
/// varies at runtime — only which profile applies to a given node.
final class MarkerVisual {
  static const MarkerVisual _category = MarkerVisual(
    topSegmentSize: 56,
    shapeStyle: MarkerShapeStyle(
      shape: MarkerShape.circle,
      paintedDiameter: 56,
      cornerRadius: 0,
      color: Color(0xFF123C69),
      hasRing: true,
      ringWidth: 2,
    ),
    iconSize: 28,
    shadow: MarkerShadow(blur: 8, offsetDy: 2, opacity: 0.3),
    boxWidth: 110,
    label: MarkerLabelStyle(
      segmentHeight: 23,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A1A),
      showPill: true,
    ),
  );

  static const MarkerVisual _continent = MarkerVisual(
    topSegmentSize: 48,
    shapeStyle: MarkerShapeStyle(
      shape: MarkerShape.circle,
      paintedDiameter: 44,
      cornerRadius: 0,
      color: Color(0xFF2E7D32),
      hasRing: false,
      ringWidth: 0,
    ),
    iconSize: 0,
    shadow: MarkerShadow(blur: 6, offsetDy: 2, opacity: 0.22),
    boxWidth: 150,
    label: MarkerLabelStyle(
      segmentHeight: 21,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      showPill: true,
    ),
  );

  static const MarkerVisual _country = MarkerVisual(
    topSegmentSize: 48,
    shapeStyle: MarkerShapeStyle(
      shape: MarkerShape.roundedSquare,
      paintedDiameter: 44,
      cornerRadius: 10,
      color: Color(0xFFC77B00),
      hasRing: false,
      ringWidth: 0,
    ),
    iconSize: 0,
    shadow: MarkerShadow(blur: 6, offsetDy: 2, opacity: 0.22),
    boxWidth: 150,
    label: MarkerLabelStyle(
      segmentHeight: 21,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      showPill: true,
    ),
  );

  static const MarkerVisual _sea = MarkerVisual(
    topSegmentSize: 48,
    shapeStyle: MarkerShapeStyle(
      shape: MarkerShape.diamond,
      paintedDiameter: 40,
      cornerRadius: 6,
      color: Color(0xFF0288D1),
      hasRing: false,
      ringWidth: 0,
    ),
    iconSize: 18,
    shadow: MarkerShadow(blur: 5, offsetDy: 1, opacity: 0.18),
    boxWidth: 150,
    label: MarkerLabelStyle(
      segmentHeight: 21,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      showPill: true,
    ),
  );

  static const MarkerVisual _island = MarkerVisual(
    topSegmentSize: 48,
    shapeStyle: MarkerShapeStyle(
      shape: MarkerShape.circle,
      paintedDiameter: 40,
      cornerRadius: 0,
      color: Color(0xFFC2703D),
      hasRing: false,
      ringWidth: 0,
    ),
    iconSize: 18,
    shadow: MarkerShadow(blur: 5, offsetDy: 1, opacity: 0.18),
    boxWidth: 150,
    label: MarkerLabelStyle(
      segmentHeight: 21,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      showPill: true,
    ),
  );

  static const MarkerVisual _city = MarkerVisual(
    topSegmentSize: 18,
    shapeStyle: MarkerShapeStyle(
      shape: MarkerShape.circle,
      paintedDiameter: 18,
      cornerRadius: 0,
      color: Color(0xFF455A64),
      hasRing: false,
      ringWidth: 0,
    ),
    iconSize: 0,
    shadow: MarkerShadow(blur: 0, offsetDy: 0, opacity: 0),
    boxWidth: 116,
    label: MarkerLabelStyle(
      segmentHeight: 18,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF14243A),
      showPill: false,
    ),
  );

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

  /// Square footprint of the painted shape's bounding box; also the
  /// minimum Material tap-target size for non-leaf markers (city markers
  /// have no enlarged target, so this equals [MarkerShapeStyle.paintedDiameter]
  /// for them).
  final double topSegmentSize;

  /// How to paint the marker's outline shape.
  final MarkerShapeStyle shapeStyle;

  /// Size of the centered icon `MapNodeMarker` overlays on the shape;
  /// unused when that icon is null.
  final double iconSize;

  /// Fixed marker box width the marker layer reserves — wide enough for
  /// this tier's longest known Arabic label at [MarkerLabelStyle.fontSize].
  final double boxWidth;

  /// The shape's drop shadow.
  final MarkerShadow shadow;

  /// How to paint the marker's label.
  final MarkerLabelStyle label;

  /// Creates a fixed visual profile; see individual field docs.
  const MarkerVisual({
    required this.topSegmentSize,
    required this.shapeStyle,
    required this.iconSize,
    required this.boxWidth,
    required this.shadow,
    required this.label,
  });
}

/// The shape a [MarkerVisual] paints its top segment as, and the fixed
/// look (fill, corner treatment, ring) it's painted with.
final class MarkerShapeStyle {
  /// Which outline [MarkerShape] to paint.
  final MarkerShape shape;

  /// The shape's own painted size, which can be smaller than
  /// [MarkerVisual.topSegmentSize] when the tap target is padded out to
  /// 48dp.
  final double paintedDiameter;

  /// Corner radius for [MarkerShape.roundedSquare]/[MarkerShape.diamond];
  /// unused for a plain circle.
  final double cornerRadius;

  /// The kind's fixed fill color (spec §3) — constant across light/dark
  /// app themes since the Mapbox basemap style is always light.
  final Color color;

  /// Whether to paint the 2dp white separator ring (category markers
  /// only), which visually ranks them above lower levels.
  final bool hasRing;

  /// Width of the ring described by [hasRing].
  final double ringWidth;

  /// Creates a shape style; see individual field docs.
  const MarkerShapeStyle({
    required this.shape,
    required this.paintedDiameter,
    required this.cornerRadius,
    required this.color,
    required this.hasRing,
    required this.ringWidth,
  });
}

/// A [MarkerVisual]'s drop shadow.
final class MarkerShadow {
  /// Drop-shadow blur radius.
  final double blur;

  /// Drop-shadow vertical offset (shadows in this spec are never
  /// horizontally offset).
  final double offsetDy;

  /// Drop-shadow opacity, `0`–`1`; `0` paints no shadow (city markers).
  final double opacity;

  /// Creates a shadow; see individual field docs.
  const MarkerShadow({
    required this.blur,
    required this.offsetDy,
    required this.opacity,
  });
}

/// A [MarkerVisual]'s label styling.
final class MarkerLabelStyle {
  /// Fixed height reserved below the shape (and gap) for the label.
  /// Derived, not guessed: `ceil(fontSize * MarkerLabelPill.lineHeight)`,
  /// plus `2 * MarkerLabelPill._pillVerticalPadding` (2 * 2 = 4) when
  /// [showPill] is true. Bare city labels skip the padding term.
  final double segmentHeight;

  /// Label font size in logical pixels (spec §4).
  final double fontSize;

  /// Label font weight (spec §4).
  final FontWeight fontWeight;

  /// Label text color — on the white pill for non-city kinds, or the
  /// bare on-tile color for city labels.
  final Color color;

  /// Whether the label sits on a white pill background, or bare on the
  /// tile (city markers only, per spec §2's legibility rationale).
  final bool showPill;

  /// Creates a label style; see individual field docs.
  const MarkerLabelStyle({
    required this.segmentHeight,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.showPill,
  });
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

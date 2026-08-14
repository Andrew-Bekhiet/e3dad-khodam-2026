import 'dart:ui';

import 'package:equatable/equatable.dart';

/// How one class of marker looks. Each distinct [id] becomes exactly one
/// style image in the renderer, shared by every marker using it.
final class MapMarkerStyle extends Equatable {
  /// Style-image id the symbol layer's `icon-image` resolves to.
  final String id;

  /// The outline rasterised into the style image.
  final MapMarkerShapeStyle shape;

  /// Drop shadow beneath the shape, or null for none.
  final MapMarkerShadow? shadow;

  /// Glyph drawn centred on the shape, or null for a bare shape.
  final MapMarkerGlyph? glyph;

  /// How the marker's label is drawn.
  final MapMarkerLabelStyle label;

  /// Edge length of the painted shape in logical pixels.
  double get diameter => shape.diameter;

  @override
  List<Object?> get props => [id, shape, shadow, glyph, label];

  /// Creates a marker style.
  const MapMarkerStyle({
    required this.id,
    required this.shape,
    required this.shadow,
    required this.glyph,
    required this.label,
  });
}

/// A [MapMarkerStyle]'s outline.
final class MapMarkerShapeStyle extends Equatable {
  /// Which outline to rasterise.
  final MapMarkerShape shape;

  /// Edge length of the painted shape in logical pixels.
  final double diameter;

  /// Fill colour.
  final Color color;

  /// Ignored for [MapMarkerShape.circle].
  final double cornerRadius;

  /// Ring drawn just inside the shape's edge; `0` draws none.
  final double ringWidth;

  /// Colour of the ring described by [ringWidth].
  final Color ringColor;

  @override
  List<Object?> get props => [
    shape,
    diameter,
    color,
    cornerRadius,
    ringWidth,
    ringColor,
  ];

  /// Creates a shape style.
  const MapMarkerShapeStyle({
    required this.shape,
    required this.diameter,
    required this.color,
    this.cornerRadius = 0,
    this.ringWidth = 0,
    this.ringColor = const Color(0xFFFFFFFF),
  });
}

/// The outline a [MapMarkerStyle] rasterises.
enum MapMarkerShape {
  /// A plain filled circle.
  circle,

  /// A filled rounded-corner square.
  roundedSquare,

  /// A rounded square rotated 45°.
  diamond,
}

/// A [MapMarkerStyle]'s drop shadow.
final class MapMarkerShadow extends Equatable {
  /// Gaussian blur radius, in logical pixels.
  final double blur;

  /// Vertical offset; these shadows are never offset horizontally.
  final double offsetDy;

  /// Shadow opacity, `0`–`1`.
  final double opacity;

  @override
  List<Object?> get props => [blur, offsetDy, opacity];

  /// Creates a shadow.
  const MapMarkerShadow({
    required this.blur,
    required this.offsetDy,
    required this.opacity,
  });
}

/// An icon glyph painted onto a marker's shape.
final class MapMarkerGlyph extends Equatable {
  /// The glyph's code point in [fontFamily].
  final int codePoint;

  /// Font the glyph is drawn from, e.g. `MaterialIcons`.
  final String fontFamily;

  /// Package the font ships in, or null when it ships with the app.
  final String? fontPackage;

  /// Em size the glyph is drawn at.
  final double size;

  /// Colour the glyph is drawn in.
  final Color color;

  @override
  List<Object?> get props => [codePoint, fontFamily, fontPackage, size, color];

  /// Creates a glyph.
  const MapMarkerGlyph({
    required this.codePoint,
    required this.fontFamily,
    required this.fontPackage,
    required this.size,
    required this.color,
  });
}

/// How a marker's label is drawn by the symbol layer.
///
/// A halo rather than the design's white pill: a pill needs a second,
/// stretchable style image driven by `icon-text-fit`, which cannot share
/// a symbol layer with the marker's own icon.
final class MapMarkerLabelStyle extends Equatable {
  /// Passed straight to `text-size`.
  final double fontSize;

  /// Fill colour of the text.
  final Color color;

  /// Colour of the halo standing the text off the basemap.
  final Color haloColor;

  /// Halo width in logical pixels.
  final double haloWidth;

  /// Gap in logical pixels between the shape's bottom edge and the label.
  final double gap;

  @override
  List<Object?> get props => [fontSize, color, haloColor, haloWidth, gap];

  /// Creates a label style.
  const MapMarkerLabelStyle({
    required this.fontSize,
    required this.color,
    required this.haloColor,
    required this.haloWidth,
    required this.gap,
  });
}

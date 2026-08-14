import 'dart:ui';

import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:equatable/equatable.dart';

/// A character standing somewhere on the map: the round portrait token
/// that marks where someone currently is.
///
/// Every token is independent, so a spec can carry as many as there are
/// characters on the move.
final class MapTokenSpec extends Equatable {
  /// Stable identifier, unique among the tokens in one spec — normally
  /// the character's id.
  final String id;

  /// Where the character currently stands.
  final GeoPosition position;

  /// The token's artwork recipe.
  final MapTokenStyle style;

  /// Screen-space nudge from [position], in logical pixels, positive
  /// right and down. This is how characters travelling together stand
  /// side by side instead of exactly on top of each other, without
  /// pretending they are in different cities.
  final Offset offset;

  @override
  List<Object?> get props => [id, position, style, offset];

  /// Creates a token.
  const MapTokenSpec({
    required this.id,
    required this.position,
    required this.style,
    this.offset = Offset.zero,
  });
}

/// How a [MapTokenSpec] is drawn: a portrait cropped into a circle inside
/// a ring, as in the design mockup.
///
/// Like `MapMarkerStyle`, one [id] means exactly one registered image, so
/// two characters sharing a portrait also share a single sprite.
final class MapTokenStyle extends Equatable {
  /// Identifier of the image the renderer registers for this style.
  final String id;

  /// Asset path of the portrait, cropped to fill the circle. Rendering
  /// falls back to a plain [fallbackColor] disc if it cannot be loaded,
  /// so a character whose art has not arrived yet still shows up.
  final String portraitAsset;

  /// Outer diameter of the token in logical pixels, ring included.
  final double diameter;

  /// Ring colour.
  final Color ringColor;

  /// Ring thickness in logical pixels.
  final double ringWidth;

  /// Disc colour used when [portraitAsset] cannot be decoded.
  final Color fallbackColor;

  @override
  List<Object?> get props => [
    id,
    portraitAsset,
    diameter,
    ringColor,
    ringWidth,
    fallbackColor,
  ];

  /// Creates a token style.
  const MapTokenStyle({
    required this.id,
    required this.portraitAsset,
    required this.diameter,
    required this.ringColor,
    required this.ringWidth,
    required this.fallbackColor,
  });
}

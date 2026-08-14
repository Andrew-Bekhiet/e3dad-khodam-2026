import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:flutter/material.dart';

/// The three states a stop can be in on the game map, plus the round
/// portrait token a character stands on it as.
///
/// Kept to a closed set for the same reason `MarkerStyles` is: one style
/// id is one rasterised image, so fourteen levels still cost three
/// marker images and one image per character.
final class GameMapStyles {
  /// The stop the current level is about: the big one, with the letter
  /// still to be delivered.
  static final MapMarkerStyle current = MapMarkerStyle(
    id: 'game-stop-current',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 46,
      color: GamePalette.accent,
      ringWidth: 3,
    ),
    shadow: const MapMarkerShadow(blur: 8, offsetDy: 2, opacity: 0.32),
    glyph: _glyph(Icons.mail_outline, size: 24),
    label: _label,
  );

  /// A stop whose letter has already been delivered.
  static final MapMarkerStyle cleared = MapMarkerStyle(
    id: 'game-stop-cleared',
    shape: const MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 30,
      color: GamePalette.cleared,
      ringWidth: 2,
    ),
    shadow: const MapMarkerShadow(blur: 5, offsetDy: 1, opacity: 0.22),
    glyph: _glyph(Icons.check, size: 16),
    label: _label,
  );

  /// The next stop, previewed but not yet reached.
  static const MapMarkerStyle locked = MapMarkerStyle(
    id: 'game-stop-locked',
    shape: MapMarkerShapeStyle(
      shape: MapMarkerShape.circle,
      diameter: 20,
      color: GamePalette.locked,
    ),
    shadow: null,
    glyph: null,
    label: MapMarkerLabelStyle(
      fontSize: 12,
      color: GamePalette.locked,
      haloColor: GamePalette.white,
      haloWidth: 1.5,
      gap: 3,
    ),
  );

  static const MapMarkerLabelStyle _label = MapMarkerLabelStyle(
    fontSize: 14,
    color: GamePalette.ink,
    haloColor: GamePalette.white,
    haloWidth: 2,
    gap: 4,
  );

  /// The round portrait token [character] stands on the map as. The style
  /// id folds in the character, so two characters never share one image.
  static MapTokenStyle tokenFor(GameCharacter character) => MapTokenStyle(
    id: 'game-token-${character.id}',
    portraitAsset: character.portraitAsset,
    diameter: 54,
    ringColor: GamePalette.white,
    ringWidth: 4,
    fallbackColor: GamePalette.accent,
  );

  static MapMarkerGlyph _glyph(IconData icon, {required double size}) =>
      MapMarkerGlyph(
        codePoint: icon.codePoint,
        fontFamily: icon.fontFamily ?? 'MaterialIcons',
        fontPackage: icon.fontPackage,
        size: size,
        color: GamePalette.white,
      );

  const GameMapStyles._();
}

import 'package:e3dad_khodam_2026/src/map_engine/mapbox/pixel_style_source.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/marker_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/tokens/token_sprite.dart';

/// Selects and scales the sprites a map style needs before provider handoff.
final class MapSpriteRegistrations {
  static const double _patternScale = 1;

  /// Builds registrations for every sprite referenced by [style].
  static Future<List<MapSpriteRegistration>> forStyle(PixelStyle style) async =>
      [
        for (final sprite in style.sprites)
          MapSpriteRegistration(sprite: sprite, scale: _patternScale),
        for (final sprite in await MarkerSprite.renderAll(style.markerStyles))
          MapSpriteRegistration(sprite: sprite, scale: MarkerSprite.scale),
        for (final sprite in await TokenSprite.renderAll(style.tokenStyles))
          MapSpriteRegistration(sprite: sprite, scale: TokenSprite.scale),
      ];

  const MapSpriteRegistrations._();
}

/// A sprite and the scale the renderer must use to register it.
final class MapSpriteRegistration {
  /// The generated sprite to hand to the map provider.
  final PixelSprite sprite;

  /// The provider image scale for [sprite].
  final double scale;

  /// Creates a registration ready for provider handoff.
  const MapSpriteRegistration({required this.sprite, required this.scale});
}

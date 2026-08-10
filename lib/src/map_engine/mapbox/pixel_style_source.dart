import 'dart:convert';

import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_palette.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_style_builder.dart';
import 'package:flutter/services.dart';

/// The finished pixel basemap: the style document to hand a renderer,
/// and the pattern images it references.
final class PixelStyle {
  /// The transformed style, as the JSON string both renderers accept.
  final String json;

  /// Patterns the style's `fill-pattern`/`background-pattern` names
  /// refer to. A renderer must register every one of these, or the
  /// patterned fills draw as nothing.
  final List<PixelSprite> sprites;

  /// Creates a built style.
  const PixelStyle({required this.json, required this.sprites});
}

/// Builds the pixel basemap from the bundled stock Mapbox style.
///
/// The stock style ships as an asset rather than being fetched from the
/// Styles API: the app has an offline-friendly first frame, and the
/// basemap can't change shape underneath the layer rules without someone
/// re-exporting the asset on purpose.
final class PixelStyleSource {
  /// Asset path of the unmodified Mapbox Streets style this is built on.
  ///
  /// Re-export it with:
  /// `curl "https://api.mapbox.com/styles/v1/<user>/<style>?access_token=<pk>"`
  static const String baseStyleAsset =
      'assets/map/mapbox_streets_base_style.json';

  const PixelStyleSource._();

  /// Loads the base style and rewrites it into the pixel look.
  static Future<PixelStyle> load({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(baseStyleAsset);
    final palette = PixelPalette.tuned();
    final style = PixelStyleBuilder.build(
      jsonDecode(source) as JsonMap,
      palette,
    );

    return PixelStyle(
      json: jsonEncode(style),
      sprites: PixelSprites.build(palette),
    );
  }
}

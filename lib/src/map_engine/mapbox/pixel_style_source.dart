import 'dart:convert';

import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/marker_layer.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_palette.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_style_builder.dart';
import 'package:flutter/services.dart';

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

  /// Loads the base style, rewrites it into the pixel look, and appends
  /// the marker source and layer holding [markers].
  ///
  /// Markers go into the style document rather than being added to a
  /// live map so the very first rendered frame already has them, and so
  /// the mobile and web surfaces share one definition of what a marker
  /// looks like.
  static Future<PixelStyle> load({
    required List<MapMarkerSpec> markers,
    AssetBundle? bundle,
  }) async {
    final source = await (bundle ?? rootBundle).loadString(baseStyleAsset);
    final palette = PixelPalette.tuned();
    final style = PixelStyleBuilder.build(
      jsonDecode(source) as JsonMap,
      palette,
    );
    _appendMarkerLayer(style, markers);

    return PixelStyle(
      json: jsonEncode(style),
      sprites: PixelSprites.build(palette),
      markerStyles: MarkerLayer.stylesOf(markers),
    );
  }

  /// Adds the marker source and layer last, so markers draw over every
  /// basemap layer including the place labels.
  static void _appendMarkerLayer(JsonMap style, List<MapMarkerSpec> markers) {
    final sources = switch (style['sources']) {
      final Map<Object?, Object?> existing => JsonMap.from(existing),
      _ => <String, Object?>{},
    };
    sources[MarkerLayer.sourceId] = MarkerLayer.source(markers);
    style['sources'] = sources;

    final layers = [
      for (final layer in (style['layers'] as List<Object?>? ?? const []))
        layer,
      MarkerLayer.layer(),
    ];
    style['layers'] = layers;
  }

  const PixelStyleSource._();
}

/// The finished pixel basemap: the style document to hand a renderer,
/// and the pattern images it references.
final class PixelStyle {
  /// The transformed style, as the JSON string both renderers accept.
  final String json;

  /// Patterns the style's `fill-pattern`/`background-pattern` names
  /// refer to. A renderer must register every one of these, or the
  /// patterned fills draw as nothing.
  final List<PixelSprite> sprites;

  /// Marker styles the symbol layer's `icon-image` names. A renderer
  /// must rasterise and register each one, or the markers draw as bare
  /// labels with no shape.
  final List<MapMarkerStyle> markerStyles;

  /// Creates a built style.
  const PixelStyle({
    required this.json,
    required this.sprites,
    required this.markerStyles,
  });
}

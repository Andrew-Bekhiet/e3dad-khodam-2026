import 'package:e3dad_khodam_2026/src/map_engine/geo_json_encoder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_style_builder.dart';

/// Builds the GeoJSON source and symbol layer the character tokens are
/// drawn by.
///
/// Mirrors `MarkerLayer`: one source, one layer, artwork resolved per
/// feature — so a second or third character on the map costs one more
/// feature, not one more layer.
final class TokenLayer {
  /// Id of the `geojson` source holding the token features.
  static const String sourceId = '${PixelStyleBuilder.addedLayerPrefix}tokens';

  /// Id of the `symbol` layer drawing them.
  static const String layerId =
      '${PixelStyleBuilder.addedLayerPrefix}token-symbols';

  /// Feature property naming the token's style image.
  static const String spriteProperty = 'tokenSprite';

  static const String _offsetProperty = 'tokenOffset';

  /// The `geojson` source definition, whose data is replaced wholesale
  /// whenever a character moves.
  static JsonMap source(List<MapTokenSpec> tokens) => {
    'type': 'geojson',
    'data': featureCollection(tokens),
  };

  /// The symbol layer. Added last of all, so a character always stands
  /// in front of the markers and labels of the place they are visiting.
  static JsonMap layer() => {
    'id': layerId,
    'type': 'symbol',
    'source': sourceId,
    'layout': <String, Object?>{
      'icon-image': <Object?>['get', spriteProperty],
      'icon-anchor': 'center',
      // `get` is typed `value`; icon-offset rejects it unasserted.
      'icon-offset': <Object?>[
        'array',
        'number',
        2,
        <Object?>['get', _offsetProperty],
      ],
      // A character must never be hidden or nudged aside by label
      // collision: where they stand is the whole point of the token.
      'icon-allow-overlap': true,
      'icon-ignore-placement': true,
      'symbol-z-order': 'source',
    },
  };

  /// The token features as a GeoJSON `FeatureCollection`.
  static JsonMap featureCollection(List<MapTokenSpec> tokens) =>
      GeoJsonEncoder.tokens(tokens);

  /// The distinct styles [tokens] refer to; each needs a style image.
  static List<MapTokenStyle> stylesOf(List<MapTokenSpec> tokens) {
    final byId = <String, MapTokenStyle>{
      for (final token in tokens) token.style.id: token.style,
    };

    return byId.values.toList();
  }

  const TokenLayer._();
}

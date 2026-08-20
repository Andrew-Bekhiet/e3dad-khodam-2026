import 'package:e3dad_khodam_2026/src/map_engine/geo_json_encoder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_style_builder.dart';

/// Builds the GeoJSON source and symbol layer the markers are drawn by.
///
/// One `geojson` source and one `symbol` layer that resolves each
/// feature's icon and label from its own properties. Shared by both
/// surfaces, since a style document means the same thing to the native
/// SDK and to GL JS.
final class MarkerLayer {
  /// Id of the `geojson` source holding the marker features.
  static const String sourceId = '${PixelStyleBuilder.addedLayerPrefix}markers';

  /// Id of the `symbol` layer drawing them; also what tap queries name.
  static const String layerId =
      '${PixelStyleBuilder.addedLayerPrefix}marker-symbols';

  /// Feature property carrying [MapMarkerSpec.id].
  static const String idProperty = 'markerId';

  /// Feature property naming the marker's style image.
  static const String spriteProperty = 'sprite';

  /// Feature property carrying the label text.
  static const String labelProperty = 'label';

  /// Font stack for every marker label. The last entry is what actually
  /// draws the Arabic text, the DIN faces being Latin-only, so it must
  /// stay a Unicode face the style's `glyphs` endpoint serves.
  static const List<String> fontStack = [
    'DIN Pro Bold',
    'Arial Unicode MS Bold',
  ];

  static const String _fontSizeProperty = 'fontSize';
  static const String _offsetProperty = 'labelOffsetEms';
  static const String _colorProperty = 'labelColor';
  static const String _haloColorProperty = 'labelHaloColor';
  static const String _haloWidthProperty = 'labelHaloWidth';
  static const String _interactiveProperty = 'interactive';

  /// Widest a label may run before wrapping, in ems.
  static const double _maxLabelWidthEms = 8.0;

  /// Restricts tap hit-testing to markers that want taps.
  static const List<Object?> interactiveFilter = [
    '==',
    <Object?>['get', _interactiveProperty],
    true,
  ];

  /// The `geojson` source definition, whose data is replaced wholesale
  /// whenever the visible markers change.
  static JsonMap source(List<MapMarkerSpec> markers) => {
    'type': 'geojson',
    'data': featureCollection(markers),
  };

  /// The symbol layer. Visual properties are data-driven off the
  /// feature, so one layer serves every marker kind.
  static JsonMap layer() => {
    'id': layerId,
    'type': 'symbol',
    'source': sourceId,
    'layout': <String, Object?>{
      'icon-image': <Object?>['get', spriteProperty],
      'icon-anchor': 'center',
      // All markers must stay visible and must not slide to dodge each
      // other, or the root cross stops reading as a cross.
      'icon-allow-overlap': true,
      'icon-ignore-placement': true,
      'text-field': <Object?>['get', labelProperty],
      'text-font': fontStack,
      'text-size': <Object?>['get', _fontSizeProperty],
      'text-anchor': 'top',
      // `get` is typed `value`; text-offset rejects it unasserted.
      'text-offset': <Object?>[
        'array',
        'number',
        2,
        <Object?>['get', _offsetProperty],
      ],
      'text-allow-overlap': true,
      'text-ignore-placement': true,
      'text-max-width': _maxLabelWidthEms,
      'symbol-z-order': 'source',
    },
    'paint': <String, Object?>{
      'text-color': <Object?>['get', _colorProperty],
      'text-halo-color': <Object?>['get', _haloColorProperty],
      'text-halo-width': <Object?>['get', _haloWidthProperty],
    },
  };

  /// The marker features as a GeoJSON `FeatureCollection`.
  static JsonMap featureCollection(List<MapMarkerSpec> markers) =>
      GeoJsonEncoder.markers(markers);

  /// The distinct styles [markers] refer to; each needs a style image.
  static List<MapMarkerStyle> stylesOf(List<MapMarkerSpec> markers) {
    final byId = <String, MapMarkerStyle>{
      for (final marker in markers) marker.style.id: marker.style,
    };

    return byId.values.toList();
  }

  /// The marker id in a hit feature's properties, or null if absent.
  static String? idOf(Map<String, Object?> properties) =>
      properties[idProperty] as String?;

  /// Whether a hit feature wants taps. Needed on web, whose layer-scoped
  /// `click` takes no filter, unlike the native interaction.
  static bool isInteractive(Map<String, Object?> properties) =>
      properties[_interactiveProperty] == true;

  const MarkerLayer._();
}

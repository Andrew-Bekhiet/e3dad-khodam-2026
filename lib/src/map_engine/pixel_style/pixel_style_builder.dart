import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_palette.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';

/// A decoded Mapbox style JSON object.
typedef JsonMap = Map<String, Object?>;

/// Rewrites a stock Mapbox style into the app's pixel-art basemap.
///
/// This is the port of the `apply()` / `style.load` logic in the
/// `pixel-map-test.html` tuner, moved from live calls against a
/// renderer to a transformation of the style document itself. Two
/// reasons for the move: the resulting style JSON is identical on
/// mobile (Mapbox Maps SDK) and web (Mapbox GL JS), so the look is
/// defined exactly once; and it replaces ~120 per-layer platform-channel
/// calls at startup with one `setStyleJSON`.
///
/// Layers are classified by their `source-layer` exactly as the tuner
/// does, never by hard-coded layer ids, so a re-published Studio style
/// with different layer names still comes out right.
final class PixelStyleBuilder {
  /// Prefix marking the layers this builder adds. Existing layers never
  /// use it, so it doubles as the "don't re-process my own output"
  /// guard.
  static const String addedLayerPrefix = 'px-';

  /// Id of the black outline drawn around every water polygon.
  static const String coastLayerId = '${addedLayerPrefix}coast';

  static const String _grassLayerId = '${addedLayerPrefix}lc-grass';
  static const String _woodLayerId = '${addedLayerPrefix}lc-wood';
  static const String _snowLayerId = '${addedLayerPrefix}lc-snow';

  static const String _landcoverSourceLayer = 'landcover';
  static const String _waterSourceLayer = 'water';
  static const String _landuseSourceLayer = 'landuse';
  static const String _placeLabelSourceLayer = 'place_label';

  /// Source layers carrying road-like geometry, hidden together.
  static const Set<String> _roadSourceLayers = {
    'road',
    'aeroway',
    'motorway_junction',
  };

  /// Source layers carrying administrative boundaries.
  static const Set<String> _adminSourceLayers = {'admin'};

  /// Label layers that are pure clutter at this app's zooms, hidden
  /// regardless of the label-rank setting.
  static const Set<String> _noiseLabelSourceLayers = {
    'poi_label',
    'transit_stop_label',
    'airport_label',
    'housenum_label',
    'natural_label',
    'motorway_junction',
  };

  /// Landcover classes painted, per [PixelTuning.greenness]. Index is
  /// the greenness level; higher levels green more of the map. Level 3
  /// additionally shows the `landuse` layer (see [_showLanduse]).
  static const List<({List<String> wood, List<String> grass})> _greenLevels = [
    (wood: ['wood'], grass: <String>[]),
    (wood: ['wood', 'scrub'], grass: <String>[]),
    (wood: ['wood', 'scrub'], grass: ['grass', 'crop']),
    (wood: ['wood', 'scrub'], grass: ['grass', 'crop']),
  ];

  static const List<String> _snowClasses = ['snow'];
  static const String _coastColor = '#000000';
  static const int _landuseGreenLevel = 3;

  const PixelStyleBuilder._();

  /// Returns [baseStyle] rewritten into the pixel-art style.
  ///
  /// [baseStyle] is consumed, not preserved: its layer list is rebuilt
  /// and individual layers are edited in place. Decode a fresh copy per
  /// call (the app decodes the bundled asset each time it builds a
  /// style).
  static JsonMap build(JsonMap baseStyle, PixelPalette palette) {
    final layers = _layersOf(baseStyle);
    final sourceId = _sourceIdFor(layers, _landcoverSourceLayer);

    for (final layer in layers) {
      _applyToExistingLayer(layer, palette);
    }

    if (sourceId != null) {
      layers.insertAll(
        _indexOfFirstSourceLayer(layers, _waterSourceLayer) ?? layers.length,
        _landcoverLayers(sourceId, palette),
      );
    }
    final waterSourceId = _sourceIdFor(layers, _waterSourceLayer);
    if (waterSourceId != null && PixelTuning.coastLineWidth > 0) {
      layers.insert(
        _indexOfFirstSymbolLayer(layers) ?? layers.length,
        _coastLayer(waterSourceId),
      );
    }
    baseStyle['layers'] = layers;

    return baseStyle;
  }

  static List<JsonMap> _layersOf(JsonMap style) => [
    for (final layer in (style['layers'] as List<Object?>? ?? const []))
      if (layer is Map) JsonMap.from(layer),
  ];

  /// The id of whichever source supplies [sourceLayer]. The stock style
  /// serves everything from one `composite` source, but reading it back
  /// keeps this working if that ever splits.
  static String? _sourceIdFor(List<JsonMap> layers, String sourceLayer) {
    for (final layer in layers) {
      if (layer['source-layer'] == sourceLayer && layer['source'] is String) {
        return layer['source']! as String;
      }
    }

    return null;
  }

  static int? _indexOfFirstSourceLayer(
    List<JsonMap> layers,
    String sourceLayer,
  ) {
    final index = layers.indexWhere(
      (layer) => layer['source-layer'] == sourceLayer,
    );

    return index < 0 ? null : index;
  }

  static int? _indexOfFirstSymbolLayer(List<JsonMap> layers) {
    final index = layers.indexWhere((layer) => layer['type'] == 'symbol');

    return index < 0 ? null : index;
  }

  static void _applyToExistingLayer(JsonMap layer, PixelPalette palette) {
    final id = layer['id'];
    if (id is String && id.startsWith(addedLayerPrefix)) {
      return;
    }
    if (layer['type'] == 'background') {
      _setPaint(layer, {
        'background-color': palette.sand.base.hex,
        'background-pattern': _pattern(PixelSprites.sand),
      });

      return;
    }

    final sourceLayer = layer['source-layer'];
    if (sourceLayer is! String) {
      return;
    }
    if (sourceLayer == _landcoverSourceLayer) {
      // Replaced wholesale by the three px-lc-* layers below.
      _setVisible(layer, false);

      return;
    }
    if (_roadSourceLayers.contains(sourceLayer)) {
      _setVisible(layer, !PixelTuning.hideRoads);

      return;
    }
    if (_adminSourceLayers.contains(sourceLayer)) {
      _setVisible(layer, !PixelTuning.hideBoundaries);

      return;
    }
    if (layer['type'] == 'symbol') {
      _applyToSymbolLayer(layer, sourceLayer);

      return;
    }
    if (layer['type'] != 'fill') {
      return;
    }
    if (sourceLayer == _waterSourceLayer) {
      _setPaint(layer, {
        'fill-color': palette.water.base.hex,
        'fill-pattern': _pattern(PixelSprites.water),
        'fill-antialias': false,
      });

      return;
    }
    if (sourceLayer == _landuseSourceLayer) {
      _setVisible(layer, _showLanduse);
      _setPaint(layer, {
        'fill-color': palette.grass.base.hex,
        'fill-pattern': _pattern(PixelSprites.grass),
        'fill-antialias': false,
      });
    }
  }

  static void _applyToSymbolLayer(JsonMap layer, String sourceLayer) {
    if (_noiseLabelSourceLayers.contains(sourceLayer)) {
      _setVisible(layer, false);

      return;
    }
    if (sourceLayer == _placeLabelSourceLayer) {
      _setVisible(layer, true);
      // Replaces the stock filter outright, as the tuner does: rank is
      // the only criterion that matters once the app supplies its own
      // labels.
      layer['filter'] = <Object?>[
        '<=',
        <Object?>['get', 'symbolrank'],
        PixelTuning.labelRank,
      ];

      return;
    }
    // Road shields, oneway arrows, ferry labels and friends: they only
    // make sense alongside the road geometry they annotate.
    _setVisible(layer, !PixelTuning.hideRoads);
  }

  static bool get _showLanduse => PixelTuning.greenness >= _landuseGreenLevel;

  static List<JsonMap> _landcoverLayers(String sourceId, PixelPalette palette) {
    final level = _greenLevels[PixelTuning.greenness.clamp(
      0,
      _greenLevels.length - 1,
    )];

    return [
      _landcoverLayer(
        id: _grassLayerId,
        sourceId: sourceId,
        classes: level.grass,
        color: palette.grass.base.hex,
        pattern: PixelSprites.grass,
      ),
      _landcoverLayer(
        id: _woodLayerId,
        sourceId: sourceId,
        classes: level.wood,
        color: palette.forest.base.hex,
        pattern: PixelSprites.forest,
      ),
      _landcoverLayer(
        id: _snowLayerId,
        sourceId: sourceId,
        classes: _snowClasses,
        color: palette.snow.base.hex,
        pattern: PixelSprites.snow,
      ),
    ];
  }

  static JsonMap _landcoverLayer({
    required String id,
    required String sourceId,
    required List<String> classes,
    required String color,
    required String pattern,
  }) => {
    'id': id,
    'type': 'fill',
    'source': sourceId,
    'source-layer': _landcoverSourceLayer,
    'filter': <Object?>[
      'in',
      <Object?>['get', 'class'],
      <Object?>['literal', classes],
    ],
    'paint': <String, Object?>{
      'fill-antialias': false,
      'fill-color': color,
      'fill-pattern': _pattern(pattern),
    },
  };

  static JsonMap _coastLayer(String sourceId) => {
    'id': coastLayerId,
    'type': 'line',
    'source': sourceId,
    'source-layer': _waterSourceLayer,
    'layout': <String, Object?>{'line-join': 'miter', 'line-cap': 'butt'},
    'paint': <String, Object?>{
      'line-color': _coastColor,
      'line-width': PixelTuning.coastLineWidth,
    },
  };

  /// The pattern image id, or null when patterns are switched off — the
  /// same key set either way, so a disabled pattern clears any value
  /// inherited from the stock style instead of leaving it behind.
  static String? _pattern(String spriteId) =>
      PixelTuning.patternsEnabled ? spriteId : null;

  static void _setVisible(JsonMap layer, bool visible) {
    final layout = switch (layer['layout']) {
      final Map<Object?, Object?> existing => JsonMap.from(existing),
      _ => <String, Object?>{},
    };
    layout['visibility'] = visible ? 'visible' : 'none';
    layer['layout'] = layout;
  }

  static void _setPaint(JsonMap layer, Map<String, Object?> properties) {
    final paint = switch (layer['paint']) {
      final Map<Object?, Object?> existing => JsonMap.from(existing),
      _ => <String, Object?>{},
    };
    for (final entry in properties.entries) {
      if (entry.value == null) {
        paint.remove(entry.key);
      } else {
        paint[entry.key] = entry.value;
      }
    }
    layer['paint'] = paint;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_palette.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_rgb.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_style_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bundled stock style, read straight off disk: these are pure-Dart
/// tests with no Flutter binding, so `rootBundle` isn't available.
JsonMap _baseStyle() {
  const path = 'assets/map/mapbox_streets_base_style.json';

  return jsonDecode(File(path).readAsStringSync()) as JsonMap;
}

List<JsonMap> _layers(JsonMap style) =>
    (style['layers']! as List<Object?>).cast<JsonMap>();

String? _visibility(JsonMap layer) =>
    (layer['layout'] as JsonMap?)?['visibility'] as String?;

Object? _paint(JsonMap layer, String property) =>
    (layer['paint'] as JsonMap?)?[property];

void main() {
  group('PixelRgb', () {
    test('adjustedMatchesTunerOutput', () {
      // Expected values produced by the tuner's own adjust() at the
      // approved saturation/lightness, so any drift in the HSL port
      // shows up as a colour change rather than a silent shift.
      const cases = <(PixelRgb, String)>[
        (PixelRgb(58, 126, 199), '#34608f'),
        (PixelRgb(104, 184, 72), '#52853e'),
        (PixelRgb(48, 112, 48), '#295129'),
        (PixelRgb(222, 200, 150), '#bfa05c'),
        (PixelRgb(244, 248, 255), '#87aff4'),
      ];
      for (final (color, expected) in cases) {
        expect(
          color
              .adjusted(
                saturation: PixelTuning.saturation,
                lightness: PixelTuning.lightness,
              )
              .hex,
          expected,
        );
      }
    });

    test('greyStaysGrey', () {
      const grey = PixelRgb(128, 128, 128);
      expect(grey.adjusted(saturation: 2.0, lightness: 1.0), grey);
    });

    test('mixedWithEndpoints', () {
      const from = PixelRgb(0, 0, 0);
      const to = PixelRgb(100, 200, 250);
      expect(from.mixedWith(to, 0), from);
      expect(from.mixedWith(to, 1), to);
      expect(from.mixedWith(to, 0.5), const PixelRgb(50, 100, 125));
    });
  });

  group('PixelSprites', () {
    test('buildsOneOpaqueSquarePerMaterial', () {
      final sprites = PixelSprites.build(PixelPalette.tuned());
      const expectedSize = PixelSprites.artSize * PixelTuning.artScale;

      expect(sprites.map((s) => s.id), [
        PixelSprites.water,
        PixelSprites.grass,
        PixelSprites.forest,
        PixelSprites.sand,
        PixelSprites.snow,
      ]);
      for (final sprite in sprites) {
        expect(sprite.width, expectedSize);
        expect(sprite.height, expectedSize);
        expect(sprite.rgba.length, expectedSize * expectedSize * 4);
        for (var i = 3; i < sprite.rgba.length; i += 4) {
          expect(sprite.rgba[i], 255, reason: 'alpha at byte $i');
        }
      }
    });

    test('isDeterministic', () {
      final first = PixelSprites.build(PixelPalette.tuned());
      final second = PixelSprites.build(PixelPalette.tuned());
      for (var i = 0; i < first.length; i++) {
        expect(first[i].rgba, second[i].rgba);
      }
    });

    test('upscalesInSolidBlocks', () {
      // Every art pixel becomes an artScale x artScale block, so
      // neighbours inside a block are identical — the property that
      // makes the result read as pixel art rather than as noise.
      final water = PixelSprites.build(PixelPalette.tuned()).first;
      const scale = PixelTuning.artScale;
      int byteAt(int x, int y) => (y * water.width + x) * 4;
      for (var y = 0; y < water.height; y += scale) {
        for (var x = 0; x < water.width; x += scale) {
          final origin = byteAt(x, y);
          for (var dy = 0; dy < scale; dy++) {
            for (var dx = 0; dx < scale; dx++) {
              final offset = byteAt(x + dx, y + dy);
              expect(
                water.rgba.sublist(offset, offset + 3),
                water.rgba.sublist(origin, origin + 3),
              );
            }
          }
        }
      }
    });

    test('containsBothBaseAndAccent', () {
      final palette = PixelPalette.tuned();
      final water = PixelSprites.build(palette).first;
      final colors = <String>{};
      for (var i = 0; i < water.rgba.length; i += 4) {
        colors.add(
          PixelRgb(water.rgba[i], water.rgba[i + 1], water.rgba[i + 2]).hex,
        );
      }

      expect(colors, contains(palette.water.base.hex));
      expect(
        colors,
        contains(
          palette.water.shadedAccent(PixelTuning.shadingContrast).hex,
        ),
      );
    });
  });

  group('PixelStyleBuilder', () {
    test('hidesRoadsBoundariesAndNoiseLabels', () {
      final layers = _layers(
        PixelStyleBuilder.build(_baseStyle(), PixelPalette.tuned()),
      );
      final hidden = {
        for (final layer in layers)
          if (_visibility(layer) == 'none') layer['id']! as String,
      };

      expect(hidden, contains('road-motorway-trunk'));
      expect(hidden, contains('admin-0-boundary'));
      expect(hidden, contains('poi-label'));
      expect(hidden, contains('road-label'));
      expect(hidden, contains('landcover'));
    });

    test('keepsPlaceLabelsFilteredByRank', () {
      final layers = _layers(
        PixelStyleBuilder.build(_baseStyle(), PixelPalette.tuned()),
      );
      final country = layers.firstWhere((l) => l['id'] == 'country-label');

      expect(_visibility(country), 'visible');
      expect(country['filter'], [
        '<=',
        ['get', 'symbolrank'],
        PixelTuning.labelRank,
      ]);
    });

    test('paintsWaterAndBackgroundWithPatterns', () {
      final palette = PixelPalette.tuned();
      final layers = _layers(PixelStyleBuilder.build(_baseStyle(), palette));
      final land = layers.firstWhere((l) => l['type'] == 'background');
      final water = layers.firstWhere((l) => l['id'] == 'water');

      expect(_paint(land, 'background-color'), palette.sand.base.hex);
      expect(_paint(land, 'background-pattern'), PixelSprites.sand);
      expect(_paint(water, 'fill-color'), palette.water.base.hex);
      expect(_paint(water, 'fill-pattern'), PixelSprites.water);
      expect(_paint(water, 'fill-antialias'), false);
    });

    test('addsLandcoverLayersAboveNothingButBelowWater', () {
      final layers = _layers(
        PixelStyleBuilder.build(_baseStyle(), PixelPalette.tuned()),
      );
      final ids = [for (final layer in layers) layer['id']! as String];
      final firstWater = layers.indexWhere(
        (l) =>
            l['source-layer'] == 'water' &&
            !(l['id']! as String).startsWith(
              PixelStyleBuilder.addedLayerPrefix,
            ),
      );

      expect(ids, containsAll(['px-lc-grass', 'px-lc-wood', 'px-lc-snow']));
      for (final id in ['px-lc-grass', 'px-lc-wood', 'px-lc-snow']) {
        expect(ids.indexOf(id), lessThan(firstWater));
      }
    });

    test('addsCoastLineBelowTheFirstLabel', () {
      final layers = _layers(
        PixelStyleBuilder.build(_baseStyle(), PixelPalette.tuned()),
      );
      final ids = [for (final layer in layers) layer['id']! as String];
      final firstSymbol = layers.indexWhere((l) => l['type'] == 'symbol');
      final coast = layers.firstWhere(
        (l) => l['id'] == PixelStyleBuilder.coastLayerId,
      );

      expect(
        ids.indexOf(PixelStyleBuilder.coastLayerId),
        lessThan(firstSymbol),
      );
      expect(_paint(coast, 'line-width'), PixelTuning.coastLineWidth);
      expect(coast['source-layer'], 'water');
    });

    test('greennessSelectsLandcoverClasses', () {
      final layers = _layers(
        PixelStyleBuilder.build(_baseStyle(), PixelPalette.tuned()),
      );
      final wood = layers.firstWhere((l) => l['id'] == 'px-lc-wood');
      final grass = layers.firstWhere((l) => l['id'] == 'px-lc-grass');

      expect(wood['filter'], [
        'in',
        ['get', 'class'],
        [
          'literal',
          ['wood', 'scrub'],
        ],
      ]);
      expect(grass['filter'], [
        'in',
        ['get', 'class'],
        [
          'literal',
          ['grass', 'crop'],
        ],
      ]);
    });

    test('leavesSourcesUntouched', () {
      final base = _baseStyle();
      final sources = JsonMap.from(base['sources']! as JsonMap);
      final built = PixelStyleBuilder.build(base, PixelPalette.tuned());

      expect(built['sources'], sources);
    });
  });
}

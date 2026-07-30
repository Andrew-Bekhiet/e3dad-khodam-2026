import 'dart:typed_data';

import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_palette.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_rgb.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';

/// A generated pixel-art tile, ready to be registered with a map
/// renderer as a `fill-pattern` image.
final class PixelSprite {
  /// Image id the style's `fill-pattern`/`background-pattern` refers to.
  final String id;

  /// Width in pixels; always equal to [height] (patterns are square).
  final int width;

  /// Height in pixels.
  final int height;

  /// Row-major RGBA bytes, four per pixel, fully opaque. Opaque means
  /// straight and premultiplied RGBA are identical here, which is what
  /// the native SDK expects.
  final Uint8List rgba;

  /// Creates a sprite from its id, size and pixel data.
  const PixelSprite({
    required this.id,
    required this.width,
    required this.height,
    required this.rgba,
  });
}

/// The complete set of generated patterns, keyed by the ids the style
/// JSON refers to.
final class PixelSprites {
  /// Water fill pattern id.
  static const String water = 'px-water';

  /// Open-green-land fill pattern id.
  static const String grass = 'px-grass';

  /// Wooded-land fill pattern id.
  static const String forest = 'px-forest';

  /// Bare-land (and map background) pattern id.
  static const String sand = 'px-sand';

  /// Snow fill pattern id.
  static const String snow = 'px-snow';

  /// Art pixels along one edge of a pattern, before [PixelTuning.artScale]
  /// upscales it. The unit the motifs are drawn in.
  static const int artSize = 16;

  static const int _bytesPerPixel = 4;
  static const int _opaque = 255;

  const PixelSprites._();

  /// Builds every pattern for [palette] at the tuned settings.
  static List<PixelSprite> build(PixelPalette palette) => [
    _sprite(water, palette.water, _Motif.wave, _waveSeed),
    _sprite(grass, palette.grass, _Motif.speckle, _grassSeed),
    _sprite(forest, palette.forest, _Motif.tree, _treeSeed),
    _sprite(sand, palette.sand, _Motif.speckle, _sandSeed),
    _sprite(snow, palette.snow, _Motif.speckle, _snowSeed),
  ];

  // Per-pattern seeds. Fixed, not derived from anything that changes at
  // runtime: a texture that reshuffles when an unrelated setting moves
  // reads as a rendering bug rather than as style.
  static const int _waveSeed = 11;
  static const int _grassSeed = 23;
  static const int _treeSeed = 37;
  static const int _sandSeed = 51;
  static const int _snowSeed = 67;

  static PixelSprite _sprite(
    String id,
    PixelMaterial material,
    _Motif motif,
    int seed,
  ) {
    final accent = material.shadedAccent(PixelTuning.shadingContrast);
    final art = List<PixelRgb>.filled(artSize * artSize, material.base);
    for (final point in motif.pixels(PixelTuning.textureDensity, seed)) {
      if (point.x < 0 ||
          point.y < 0 ||
          point.x >= artSize ||
          point.y >= artSize) {
        continue;
      }
      art[point.y * artSize + point.x] = accent;
    }

    return _upscale(id, art);
  }

  /// Nearest-neighbour upscale — the "art scale" knob. Interpolation
  /// would defeat the entire look, so every source pixel becomes a solid
  /// `artScale × artScale` block.
  static PixelSprite _upscale(String id, List<PixelRgb> art) {
    const scale = PixelTuning.artScale;
    const size = artSize * scale;
    final rgba = Uint8List(size * size * _bytesPerPixel);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final color = art[(y ~/ scale) * artSize + (x ~/ scale)];
        final offset = (y * size + x) * _bytesPerPixel;
        rgba[offset] = color.red;
        rgba[offset + 1] = color.green;
        rgba[offset + 2] = color.blue;
        rgba[offset + 3] = _opaque;
      }
    }

    return PixelSprite(id: id, width: size, height: size, rgba: rgba);
  }
}

/// A single accent pixel's position inside the `artSize × artSize` grid.
typedef _Point = ({int x, int y});

/// How a material scatters its accent colour over the base fill.
enum _Motif {
  /// Loose single-pixel noise: land textures.
  speckle,

  /// Short horizontal 3-pixel dashes: the water's ripples.
  wave,

  /// Small canopy clusters at fixed spots: woodland.
  tree;

  static const int _speckleMax = 14;
  static const int _waveMax = 7;
  static const int _waveLength = 3;
  static const List<_Point> _canopySpots = [
    (x: 7, y: 2),
    (x: 2, y: 8),
    (x: 12, y: 8),
    (x: 7, y: 12),
    (x: 13, y: 14),
  ];

  /// The accent pixels this motif paints at [density] (`0`–`1` of its
  /// maximum), using [seed] to stay deterministic.
  List<_Point> pixels(double density, int seed) => switch (this) {
    _Motif.speckle => _speckle(density, seed),
    _Motif.wave => _wave(density, seed),
    _Motif.tree => _tree(density),
  };

  static List<_Point> _speckle(double density, int seed) {
    final random = _PixelRandom(seed);
    final count = (density * _speckleMax).round();
    final points = <_Point>[];
    for (var i = 0; i < count; i++) {
      // Both draws happen, in this order, for every speckle — the x
      // draw must not be skipped even when the point lands off-grid,
      // or every later point shifts.
      final x = random.nextIndex(PixelSprites.artSize);
      final y = random.nextIndex(PixelSprites.artSize);
      points.add((x: x, y: y));
    }

    return points;
  }

  static List<_Point> _wave(double density, int seed) {
    final random = _PixelRandom(seed);
    final count = (density * _waveMax).round();
    final points = <_Point>[];
    for (var i = 0; i < count; i++) {
      final x = random.nextIndex(PixelSprites.artSize - _waveLength);
      final y = random.nextIndex(PixelSprites.artSize);
      for (var d = 0; d < _waveLength; d++) {
        points.add((x: x + d, y: y));
      }
    }

    return points;
  }

  static List<_Point> _tree(double density) {
    final count = (density * _canopySpots.length).round().clamp(
      0,
      _canopySpots.length,
    );

    return [for (final spot in _canopySpots.take(count)) ..._canopy(spot)];
  }

  /// One tree: a 1-3-5-1 pixel blob, drawn top row down.
  static List<_Point> _canopy(_Point center) => [
    (x: center.x, y: center.y - 1),
    (x: center.x - 1, y: center.y),
    (x: center.x, y: center.y),
    (x: center.x + 1, y: center.y),
    (x: center.x - 2, y: center.y + 1),
    (x: center.x - 1, y: center.y + 1),
    (x: center.x, y: center.y + 1),
    (x: center.x + 1, y: center.y + 1),
    (x: center.x + 2, y: center.y + 1),
    (x: center.x, y: center.y + 2),
  ];
}

/// The tuner's seeded PRNG (a Mulberry32 variant), ported so a given
/// seed lays out exactly the same texture here as it does in the HTML
/// prototype.
///
/// `dart:math`'s `Random` would be just as deterministic but would
/// produce a *different* arrangement, silently changing the artwork the
/// design was signed off on.
final class _PixelRandom {
  static const int _increment = 0x6D2B79F5;
  static const int _mask32 = 0xFFFFFFFF;
  static const int _mask16 = 0xFFFF;
  static const int _halfWordBits = 16;
  static const double _twoPow32 = 4294967296.0;

  int _state;

  _PixelRandom(int seed) : _state = seed & _mask32;

  /// The next value in `[0, 1)`, matching one call of the JavaScript
  /// closure.
  double nextDouble() {
    _state = (_state + _increment) & _mask32;
    final seeded = _mul32(_state ^ (_state >>> 15), 1 | _state);
    // `t = (t + imul(t ^ (t >>> 7), 61 | t)) ^ t` — the trailing `^ t`
    // reads the value from *before* the assignment.
    final mixed =
        ((seeded + _mul32(seeded ^ (seeded >>> 7), 61 | seeded)) & _mask32) ^
        seeded;

    return ((mixed ^ (mixed >>> 14)) & _mask32) / _twoPow32;
  }

  /// The next integer in `[0, bound)`.
  int nextIndex(int bound) => (nextDouble() * bound).floor();

  /// `Math.imul`: the low 32 bits of `a * b`. Split into half-words
  /// because on the web Dart ints are doubles, and a full 32×32 product
  /// overflows the 53 bits of exact integer precision they carry.
  static int _mul32(int a, int b) {
    final low = a & _mask16;
    final high = (a >>> _halfWordBits) & _mask16;

    return (low * b + (((high * b) & _mask16) << _halfWordBits)) & _mask32;
  }
}

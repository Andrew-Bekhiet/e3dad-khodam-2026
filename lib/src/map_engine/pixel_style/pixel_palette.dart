import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_rgb.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_tuning.dart';

/// One terrain material's two colours: the flat fill and the accent the
/// motif speckles over it.
final class PixelMaterial {
  /// The fill colour the tile is flooded with.
  final PixelRgb base;

  /// The accent colour motif pixels are drawn in, before
  /// [PixelTuning.shadingContrast] pulls it back toward [base].
  final PixelRgb accent;

  /// Creates a material from its two colours.
  const PixelMaterial({required this.base, required this.accent});

  /// This material with both colours pushed through
  /// [PixelRgb.adjusted].
  PixelMaterial adjusted({
    required double saturation,
    required double lightness,
  }) => PixelMaterial(
    base: base.adjusted(saturation: saturation, lightness: lightness),
    accent: accent.adjusted(saturation: saturation, lightness: lightness),
  );

  /// The accent as actually painted: [base] blended toward [accent] by
  /// `contrast`, so the shading knob fades the motif out rather than
  /// removing it.
  PixelRgb shadedAccent(double contrast) => base.mixedWith(accent, contrast);
}

/// The five terrain materials of the pixel basemap, after the
/// saturation/lightness knobs have been applied.
///
/// Note what is *missing*: there is no desert material. Mapbox's
/// `landcover` data only knows wood/scrub/grass/crop/snow, so bare land
/// is the sand colour painted as the map background, and everything
/// green is layered on top of it.
final class PixelPalette {
  static const PixelMaterial _baseWater = PixelMaterial(
    base: PixelRgb(58, 126, 199),
    accent: PixelRgb(110, 175, 235),
  );
  static const PixelMaterial _baseGrass = PixelMaterial(
    base: PixelRgb(104, 184, 72),
    accent: PixelRgb(72, 144, 56),
  );
  static const PixelMaterial _baseForest = PixelMaterial(
    base: PixelRgb(48, 112, 48),
    accent: PixelRgb(26, 72, 36),
  );
  static const PixelMaterial _baseSand = PixelMaterial(
    base: PixelRgb(222, 200, 150),
    accent: PixelRgb(198, 172, 120),
  );
  static const PixelMaterial _baseSnow = PixelMaterial(
    base: PixelRgb(244, 248, 255),
    accent: PixelRgb(200, 218, 240),
  );

  /// Sea, lakes and rivers.
  final PixelMaterial water;

  /// Open green land — grass and cropland.
  final PixelMaterial grass;

  /// Wooded land, the darker green.
  final PixelMaterial forest;

  /// Bare land, and the colour the whole map is backed with.
  final PixelMaterial sand;

  /// Permanent snow.
  final PixelMaterial snow;

  /// Creates a palette from its five materials.
  const PixelPalette({
    required this.water,
    required this.grass,
    required this.forest,
    required this.sand,
    required this.snow,
  });

  /// The palette as tuned in the design (see [PixelTuning]).
  factory PixelPalette.tuned() => PixelPalette.adjusted(
    saturation: PixelTuning.saturation,
    lightness: PixelTuning.lightness,
  );

  /// The base palette with the saturation/lightness knobs applied.
  factory PixelPalette.adjusted({
    required double saturation,
    required double lightness,
  }) => PixelPalette(
    water: _baseWater.adjusted(saturation: saturation, lightness: lightness),
    grass: _baseGrass.adjusted(saturation: saturation, lightness: lightness),
    forest: _baseForest.adjusted(saturation: saturation, lightness: lightness),
    sand: _baseSand.adjusted(saturation: saturation, lightness: lightness),
    snow: _baseSnow.adjusted(saturation: saturation, lightness: lightness),
  );
}

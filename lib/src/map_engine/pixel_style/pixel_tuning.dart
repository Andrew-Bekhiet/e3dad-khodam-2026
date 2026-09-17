/// The settings the pixel-art look was tuned to in the standalone
/// `pixel-map-test.html` tuner, frozen as the app's basemap design.
///
/// Every field here was a slider or checkbox in that page; the values
/// are the ones from the approved screenshot. They live in one class so
/// re-tuning means editing numbers here rather than hunting through the
/// sprite generator and the style builder.
final class PixelTuning {
  /// Nearest-neighbour upscale factor for the generated sprites. Powers
  /// of two only — anything else leaves seams where a pattern tiles.
  static const int artScale = 4;

  /// How many accent pixels each motif draws, `0`–`1` of its maximum.
  static const double textureDensity = 1.0;

  /// How far the accent colour travels from the base colour, `0`–`1`.
  /// At `0` a tile is flat; at `1` the accent is used undiluted.
  static const double shadingContrast = 0.72;

  /// HSL saturation multiplier applied to every base colour.
  static const double saturation = 1;

  /// HSL lightness multiplier applied to every base colour.
  static const double lightness = 1;

  /// How much of the landcover data is painted green, `0`–`3`:
  /// see `PixelStyleBuilder` for the class lists each level selects.
  /// At `3` the `landuse` layer is painted too, which at these zooms
  /// mostly adds noise, hence `2`.
  static const int greenness = 2;

  /// Width, in pixels, of the inked coastline drawn around every water
  /// polygon — the single most recognisable element of the look. `0`
  /// hides it.
  static const double coastLineWidth = 2;

  /// Colour of the coastline: a dark sepia ink rather than black, so
  /// the line reads as drawn on the parchment instead of printed over
  /// it.
  static const String coastLineColor = '#3e2612';

  /// Only basemap place labels with `symbolrank <= labelRank` survive.
  /// `1` keeps just the highest-rank handful, since this app draws its
  /// own Arabic labels on top and competing text reads as clutter.
  static const int labelRank = 1;

  /// Whether road/aeroway geometry (and the road-ish symbol layers that
  /// go with it) is hidden.
  static const bool hideRoads = true;

  /// Whether administrative boundary lines are hidden.
  static const bool hideBoundaries = true;

  /// Whether fills use the generated pixel patterns. `false` leaves the
  /// same palette as flat colour — useful when chasing a rendering bug.
  static const bool patternsEnabled = true;

  /// Zoom levels the camera settles onto after a gesture. Snapping to
  /// whole levels keeps the sprites pixel-aligned; between levels the
  /// renderer scales patterns and the art blurs.
  static const double zoomSnap = 0.05;

  const PixelTuning._();
}

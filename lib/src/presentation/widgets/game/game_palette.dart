import 'package:flutter/widgets.dart';

/// The game overlay's fixed colours.
///
/// Deliberately not taken from the M3 `ColorScheme`: the overlays are
/// pixel-art game chrome sitting on top of the pixel basemap, and they
/// must read the same in light and dark, like the markers do.
final class GamePalette {
  /// Panel and border ink — the same navy the marker labels use.
  static const Color ink = Color(0xFF14243A);

  /// Guide panel fill.
  static const Color parchment = Color(0xFFFFF6E0);

  /// Highlight used for the current level and the guide's name.
  static const Color accent = Color(0xFFC77B00);

  /// Cleared-level green.
  static const Color cleared = Color(0xFF2E7D32);

  /// Not-yet-reached grey.
  static const Color locked = Color(0xFF6B7A8F);

  /// Narrator band fill.
  static const Color narratorInk = Color(0xFF0B1220);

  /// Narrator band text.
  static const Color narratorText = Color(0xFFF4E9D0);

  /// Scrim laid over the map while the narrator is speaking.
  static const Color scrim = Color(0x66000000);

  /// White, for rings and haloes.
  static const Color white = Color(0xFFFFFFFF);

  const GamePalette._();
}

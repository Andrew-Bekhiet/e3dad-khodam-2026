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

  /// Narrator card fill — aged vellum.
  ///
  /// Darker and browner than the guide's [parchment] on purpose: the two
  /// voices separate by era rather than by light against dark. The guide
  /// is a note passed to you now, the narrator the chronicle it was
  /// copied from. The near-black this replaced was the only thing on
  /// screen belonging to no material, which is what made it read as
  /// alien.
  static const Color narratorVellum = Color(0xFFE4D2A8);

  /// Narrator body text. 9.7:1 on [narratorVellum].
  static const Color narratorSepia = Color(0xFF3B2412);

  /// Narrator border, rules, name and title. 4.3:1 on [narratorVellum],
  /// which carries the large text it is used for but not body copy.
  static const Color narratorOchre = Color(0xFFA63A1E);

  /// Narrator inner rule. Decoration only — at 2:1 on [narratorVellum]
  /// it must never be given text.
  static const Color narratorGilt = Color(0xFFC08A2E);

  /// Scrim laid over the map while someone is speaking. Lighter than the
  /// vellum card needs, so the map stays readable underneath it.
  static const Color scrim = Color(0x59000000);

  /// White, for rings and haloes.
  static const Color white = Color(0xFFFFFFFF);

  const GamePalette._();
}

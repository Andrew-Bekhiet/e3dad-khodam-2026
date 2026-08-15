import 'package:flutter/widgets.dart';

/// How much room the game has to draw in.
///
/// The game is played two ways: thrown on a big screen in front of a
/// room, where the story text has to read from the back, and held in one
/// hand, where that same type is a wall of words. Every game surface
/// picks its sizes off this rather than off a raw width.
///
/// The number that matters is the *short* side. A phone turned sideways
/// is the widest phone viewport there is and the shortest one — 844 by
/// 390 — so a rule reading width alone calls it a desktop and hands it
/// projector type in 390 pixels of height, which is the one case that
/// was already clipping.
///
/// Which values each surface uses is the surface's own business: this
/// says only how big the screen is, never what to draw on it.
enum GameScreenSize {
  /// A phone, held either way up.
  compact,

  /// A tablet, a desktop window, or whatever the projector is plugged
  /// into. The size the story text is authored for.
  large;

  /// Shortest side, in logical pixels, at or above which the game draws
  /// at full size.
  ///
  /// Above the conventional 600 tablet line. At 600 exactly the full-size
  /// app bar is 136 of the viewport's 600 pixels and the narration is set
  /// at 45 — together more than such a window can hold. 700 is the point
  /// where the big layout still leaves the map more room than the chrome.
  static const double _largeShortestSide = 700.0;

  /// The size class of the screen [context] is being laid out on.
  static GameScreenSize of(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= _largeShortestSide
      ? GameScreenSize.large
      : GameScreenSize.compact;

  /// [large] on a big screen, [compact] on a phone.
  ///
  /// A hard switch rather than an interpolation, so the value a big
  /// screen gets is written out literally and can be read straight off
  /// the call rather than trusted to arithmetic.
  T pick<T>({required T compact, required T large}) =>
      this == GameScreenSize.large ? large : compact;
}

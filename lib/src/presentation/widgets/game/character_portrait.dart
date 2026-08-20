import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:flutter/material.dart';

/// A character's portrait in a chunky pixel-art frame.
///
/// Falls back to a placeholder silhouette when the image is missing, so a
/// character can be scripted and shipped before their artwork arrives.
final class CharacterPortrait extends StatelessWidget {
  static const double _borderWidth = 3.0;
  static const double _shadowOffset = 4.0;
  static const double _placeholderRatio = 0.5;

  /// Whose portrait to show.
  final GameCharacter character;

  /// Edge length of the framed square, in logical pixels.
  final double size;

  /// Frame fill, seen behind a transparent or missing portrait.
  final Color background;

  /// Creates a framed portrait.
  const CharacterPortrait({
    required this.character,
    required this.size,
    this.background = GamePalette.parchment,
    super.key,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    width: size,
    height: size,
    alignment: AlignmentDirectional.topStart,
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: background,
      border: Border.all(color: GamePalette.ink, width: _borderWidth),
      // A hard, unblurred offset shadow: the pixel-art equivalent of
      // elevation, and the same trick the panels use.
      boxShadow: const [
        BoxShadow(
          color: GamePalette.ink,
          offset: Offset(_shadowOffset, _shadowOffset),
        ),
      ],
    ),
    child: ClipRect(
      child: Image.asset(
        character.portraitAsset,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.person_outline,
            size: size * CharacterPortrait._placeholderRatio,
            color: GamePalette.ink.withValues(alpha: 0.35),
          ),
        ),
      ),
    ),
  );
}

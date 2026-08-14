import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The in-world guide talking: a framed portrait beside a pixel speech
/// panel, anchored to the bottom of the screen.
///
/// The narrator gets a deliberately different treatment
/// (`NarratorBand`) so the two voices are never confused for each other.
final class GuideDialoguePanel extends StatelessWidget {
  static const double _portraitSize = 92.0;
  static const double _maxWidth = 720.0;

  /// Who is speaking.
  final GameCharacter character;

  /// The line being spoken.
  final StoryBeat beat;

  /// Creates the guide's dialogue panel.
  const GuideDialoguePanel({
    required this.character,
    required this.beat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = beat.title;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          // The bottom inset clears the on-screen step arrows, which sit
          // in the same corner and must stay tappable while someone is
          // talking.
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 72),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CharacterPortrait(
                  character: character,
                  size: _portraitSize,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PixelPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: GamePalette.accent,
                          ),
                        ),
                        if (title != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: GamePalette.ink,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          beat.text,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: GamePalette.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _ContinueHint(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The "press forward to continue" cue, in both overlays.
final class _ContinueHint extends StatelessWidget {
  const _ContinueHint();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        AppStrings.continueHint,
        style: TextStyle(
          fontSize: 12,
          color: GamePalette.ink.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(width: 4),
      Icon(
        Icons.play_arrow,
        size: 14,
        color: GamePalette.ink.withValues(alpha: 0.6),
      ),
    ],
  );
}

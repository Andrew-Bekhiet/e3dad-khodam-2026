import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:flutter/material.dart';

/// The narrator speaking: a dark letterboxed band across the whole
/// screen, over a dimmed map.
///
/// Same idea as `GuideDialoguePanel` — a portrait, a name and a line —
/// but staged as a cutscene rather than a conversation, so the player can
/// tell an out-of-world voice from the in-world guide at a glance.
final class NarratorBand extends StatelessWidget {
  static const double _portraitSize = 56.0;
  static const double _maxWidth = 760.0;
  static const double _ruleHeight = 2.0;

  /// Who is narrating.
  final GameCharacter character;

  /// The line being narrated.
  final StoryBeat beat;

  /// Creates the narrator band.
  const NarratorBand({
    required this.character,
    required this.beat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = beat.title;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const _Rule(),
        ColoredBox(
          color: GamePalette.narratorInk,
          child: SafeArea(
            top: false,
            child: Padding(
              // The deeper bottom inset clears the on-screen step arrows,
              // which sit over this band.
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 64),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CharacterPortrait(
                        character: character,
                        size: _portraitSize,
                        background: GamePalette.narratorInk,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              character.name,
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600,
                                color: GamePalette.narratorText.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            if (title != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: GamePalette.narratorText,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              beat.text,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                                color: GamePalette.narratorText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The thin accent rule that closes the letterbox off from the map.
final class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Container(
    height: NarratorBand._ruleHeight,
    color: GamePalette.accent,
  );
}

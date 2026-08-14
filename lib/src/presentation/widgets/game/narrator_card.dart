import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The narrator speaking: the same centred, large card as the guide's,
/// but staged as a cutscene — dark, letterboxed by accent rules, with
/// the portrait above the line rather than beside it, so an out-of-world
/// voice never reads as the in-world guide.
final class NarratorCard extends StatelessWidget {
  static const double _portraitSize = 160.0;
  static const double _maxWidth = 860.0;
  static const double _ruleHeight = 3.0;

  /// Who is narrating.
  final GameCharacter character;

  /// The line being narrated.
  final StoryBeat beat;

  /// Creates the narrator card.
  const NarratorCard({
    required this.character,
    required this.beat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = beat.title;

    return Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: PixelPanel(
              color: GamePalette.narratorInk,
              border: GamePalette.accent,
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Rule(),
                  const SizedBox(height: 18),
                  CharacterPortrait(
                    character: character,
                    size: _portraitSize,
                    background: GamePalette.narratorInk,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    character.name,
                    style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: GamePalette.narratorText.withValues(alpha: 0.7),
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: GamePalette.narratorText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        beat.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.8,
                          fontStyle: FontStyle.italic,
                          color: GamePalette.narratorText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const ContinueChevron(color: GamePalette.narratorText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The thin accent rule that letterboxes the card.
final class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Container(
    height: NarratorCard._ruleHeight,
    color: GamePalette.accent,
  );
}

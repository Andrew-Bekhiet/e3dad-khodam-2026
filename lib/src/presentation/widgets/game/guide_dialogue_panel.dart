import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The in-world guide talking: a large framed portrait beside a pixel
/// speech panel, centred on the screen over a dimmed map.
///
/// The narrator gets a deliberately different treatment
/// (`NarratorCard`) so the two voices are never confused for each other.
final class GuideDialoguePanel extends StatelessWidget {
  static const double _portraitSize = 180.0;
  static const double _maxWidth = 900.0;

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

    return Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: PixelPanel(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CharacterPortrait(
                    character: character,
                    size: _portraitSize,
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: GamePalette.accent,
                          ),
                        ),
                        if (title != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: GamePalette.ink,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              beat.text,
                              style: const TextStyle(
                                fontSize: 21,
                                height: 1.7,
                                color: GamePalette.ink,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: ContinueChevron(),
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
    );
  }
}

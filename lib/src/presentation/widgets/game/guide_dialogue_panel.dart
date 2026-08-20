import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The in-world guide talking: a large framed portrait beside a pixel
/// speech panel, centred on the screen over a dimmed map.
///
/// The narrator gets a deliberately different treatment
/// (`NarratorCard`) so the two voices are never confused for each other.
final class GuideDialoguePanel extends StatelessWidget {
  /// She stands beside her words rather than above them, so on a phone
  /// the portrait is competing with the line for width, not height.
  static const double _portraitSizeLarge = 180.0;
  static const double _portraitSizeCompact = 104.0;
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
    final text = TextTheme.of(context);
    final screen = GameScreenSize.of(context);

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
                    size: screen.pick(
                      compact: _portraitSizeCompact,
                      large: _portraitSizeLarge,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          character.name,
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: GamePalette.accent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          beat.text,
                          style: screen
                              .pick(
                                compact: text.titleMedium,
                                large: text.headlineLarge,
                              )
                              ?.copyWith(height: 1.6, color: GamePalette.ink),
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

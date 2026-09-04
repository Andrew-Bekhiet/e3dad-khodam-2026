import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The in-world guide talking: a centred card staged like the narrator's
/// — portrait above the name, over a dimmed map — but in her own
/// parchment/ink/accent palette, so the two voices are never confused for
/// each other.
///
/// The line itself is never painted: an actor performs it live on stage,
/// so [StoryBeat.text] is read for the record but not shown here.
final class GuideDialoguePanel extends StatelessWidget {
  static const double _portraitSizeLarge = 160.0;
  static const double _portraitSizeCompact = 72.0;
  static const double _maxWidth = 860.0;
  static const double _gapLarge = 12.0;
  static const double _gapCompact = 4.0;

  /// Who is speaking.
  final GameCharacter character;

  /// The line being spoken. Its text is not shown; see the class doc.
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
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: screen.pick(compact: 8, large: 24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: PixelPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CharacterPortrait(
                    character: character,
                    size: screen.pick(
                      compact: _portraitSizeCompact,
                      large: _portraitSizeLarge,
                    ),
                  ),
                  SizedBox(
                    height: screen.pick(compact: _gapCompact, large: _gapLarge),
                  ),
                  Text(
                    character.name,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: GamePalette.accent,
                    ),
                  ),
                  SizedBox(height: screen.pick(compact: 6.0, large: 18.0)),
                  const ContinueChevron(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

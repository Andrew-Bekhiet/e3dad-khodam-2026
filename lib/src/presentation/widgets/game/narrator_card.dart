import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The narrator speaking: the same centred, large card as the guide's,
/// but staged as a cutscene — dark, letterboxed by accent rules, with
/// the portrait above the line rather than beside it, so an out-of-world
/// voice never reads as the in-world guide.
final class NarratorCard extends StatelessWidget {
  /// The portrait is the card's largest single piece, so it is the first
  /// thing to give when the screen is a phone rather than a room.
  static const double _portraitSizeLarge = 160.0;
  static const double _portraitSizeCompact = 72.0;

  /// The card's own breathing room. Generous on a big screen, close to
  /// nothing on a phone turned sideways: 390 pixels of height is less
  /// than this card's padding and gaps used to add up to, so the spacing
  /// has to give as well as the type.
  static const EdgeInsets _paddingLarge = EdgeInsets.fromLTRB(26, 0, 26, 20);
  static const EdgeInsets _paddingCompact = EdgeInsets.fromLTRB(16, 0, 16, 8);
  static const double _gapLarge = 12.0;
  static const double _gapCompact = 4.0;
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
              color: GamePalette.narratorVellum,
              border: GamePalette.narratorOchre,
              padding: screen.pick(
                compact: _paddingCompact,
                large: _paddingLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(
                    thickness: NarratorCard._ruleHeight,
                    height: NarratorCard._ruleHeight,
                    color: GamePalette.narratorGilt,
                    endIndent: 0,
                    indent: 0,
                  ),
                  SizedBox(height: screen.pick(compact: 6.0, large: 18.0)),
                  CharacterPortrait(
                    character: character,
                    size: screen.pick(
                      compact: _portraitSizeCompact,
                      large: _portraitSizeLarge,
                    ),
                    background: GamePalette.narratorVellum,
                  ),
                  SizedBox(
                    height: screen.pick(compact: _gapCompact, large: _gapLarge),
                  ),
                  Text(
                    character.name,
                    style: text.titleLarge?.copyWith(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: GamePalette.narratorOchre,
                    ),
                  ),
                  SizedBox(
                    height: screen.pick(compact: _gapCompact, large: _gapLarge),
                  ),
                  Text(
                    beat.text,
                    textAlign: TextAlign.center,
                    style: screen
                        .pick(
                          compact: text.titleMedium,
                          large: text.displayMedium,
                        )
                        ?.copyWith(
                          height: screen.pick(compact: 1.35, large: 1.7),
                          fontStyle: FontStyle.italic,
                          color: GamePalette.narratorSepia,
                        ),
                  ),
                  SizedBox(height: screen.pick(compact: 2.0, large: 10.0)),
                  const ContinueChevron(color: GamePalette.narratorOchre),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

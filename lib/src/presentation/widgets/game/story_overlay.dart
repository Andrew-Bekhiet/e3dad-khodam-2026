import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/guide_dialogue_panel.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/narrator_band.dart';
import 'package:flutter/widgets.dart';

/// The story layer over the map: the guide's panel, the narrator's band,
/// or nothing at all while a level is being played.
///
/// While a beat is showing, a tap anywhere advances — the same thing the
/// forward arrow and the right arrow key do — so a story overlay
/// deliberately swallows taps meant for the map underneath.
final class StoryOverlay extends StatelessWidget {
  static const Duration _switchDuration = Duration(milliseconds: 220);

  /// The character shown for [StorySpeaker.guide] beats.
  final GameCharacter guide;

  /// The character shown for [StorySpeaker.narrator] beats.
  final GameCharacter narrator;

  /// The line to show, or null to leave the map unobstructed.
  final StoryBeat? beat;

  /// Called when the player taps to move on.
  final VoidCallback onAdvance;

  /// Creates the story layer.
  const StoryOverlay({
    required this.guide,
    required this.narrator,
    required this.onAdvance,
    this.beat,
    super.key,
  });

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: _switchDuration,
    child: switch (beat) {
      null => const SizedBox.shrink(),
      final current => GestureDetector(
        key: ValueKey('${current.speaker}:${current.text}'),
        behavior: HitTestBehavior.opaque,
        onTap: onAdvance,
        child: _forBeat(current),
      ),
    },
  );

  Widget _forBeat(StoryBeat current) => switch (current.speaker) {
    StorySpeaker.guide => GuideDialoguePanel(
      character: guide,
      beat: current,
    ),
    // The narrator dims the whole map behind the band: these beats are
    // between levels, not about the place currently on screen.
    StorySpeaker.narrator => ColoredBox(
      color: GamePalette.scrim,
      child: NarratorBand(character: narrator, beat: current),
    ),
  };
}

import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/guide_dialogue_panel.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/narrator_card.dart';
import 'package:flutter/widgets.dart';

/// The story layer over the map: the guide's panel, the narrator's band,
/// or nothing at all while a level is being played.
///
/// While a beat is showing, a tap anywhere advances — the same thing the
/// forward arrow and the right arrow key do — so a story overlay
/// deliberately swallows taps meant for the map underneath.
final class StoryOverlay extends StatelessWidget {
  static const Duration _switchDuration = Duration(milliseconds: 420);

  /// The outgoing line clears out over the first third, and the incoming
  /// one only starts once it has gone.
  ///
  /// Two panels cross-fading through each other looks like a smear, and
  /// it is worse than it sounds here because a beat often arrives on the
  /// same press that raises the destination card — so without this there
  /// were three things fading over one another at once. Handing each its
  /// own slice of the same window keeps them sequential without needing
  /// a second clock.
  static const Curve _fadeOut = Interval(0, 0.34, curve: Curves.easeIn);
  static const Curve _fadeIn = Interval(0.55, 1, curve: Curves.easeOut);

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
    switchInCurve: _fadeIn,
    switchOutCurve: _fadeOut,
    child: switch (beat) {
      null => const SizedBox.shrink(),
      final current => GestureDetector(
        key: ValueKey('${current.speaker}:${current.text}'),
        behavior: HitTestBehavior.opaque,
        onTap: onAdvance,
        // Both voices dim the map behind them: a beat is something to
        // read, not something happening at the place on screen.
        child: ColoredBox(
          color: GamePalette.scrim,
          child: _forBeat(current),
        ),
      ),
    },
  );

  Widget _forBeat(StoryBeat current) => switch (current.speaker) {
    StorySpeaker.guide => GuideDialoguePanel(character: guide, beat: current),
    StorySpeaker.narrator => NarratorCard(character: narrator, beat: current),
  };
}

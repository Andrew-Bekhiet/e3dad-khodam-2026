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
  /// Long enough to hold both a fade-out and a fade-in end to end, plus
  /// the wait that lets the destination card finish first.
  static const Duration switchDuration = Duration(milliseconds: 700);

  /// The outgoing line clears over the first fifth. Nothing new appears
  /// until [_fadeIn] starts, well after the card has settled.
  static const Curve _fadeOut = Interval(0, 0.2, curve: Curves.easeIn);

  /// The incoming line waits out `DestinationCard.growDuration` before it
  /// begins.
  ///
  /// A beat usually arrives on the same press that raises the card, and
  /// two panels growing and fading through one another reads as a smear.
  /// The card goes first and finishes; only then does anyone speak.
  /// `0.6 × 700ms = 420ms`, comfortably past the card's 260ms.
  static const Curve _fadeIn = Interval(0.6, 1, curve: Curves.easeOut);

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
    duration: switchDuration,
    switchInCurve: _fadeIn,
    switchOutCurve: _fadeOut,
    child: switch (beat) {
      null => const SizedBox.shrink(),
      final current => GestureDetector(
        key: ValueKey(current),
        behavior: HitTestBehavior.opaque,
        onTap: onAdvance,
        // Both voices dim the map behind them: a beat is something to
        // read, not something happening at the place on screen.
        child: ColoredBox(
          color: GamePalette.scrim,
          child: switch (current.speaker) {
            StorySpeaker.guide => GuideDialoguePanel(
              character: guide,
              beat: current,
            ),
            StorySpeaker.narrator => NarratorCard(
              character: narrator,
              beat: current,
            ),
          },
        ),
      ),
    },
  );
}

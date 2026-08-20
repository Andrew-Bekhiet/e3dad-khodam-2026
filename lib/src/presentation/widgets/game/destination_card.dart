import 'package:collection/collection.dart';
import 'package:e3dad_khodam_2026/src/app/arabic_numerals.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The level's card, laid over the map once the sweep has landed.
///
/// It opens one part at a time: the **sign** — the destination's name and
/// year, the play's own لافتة — then the verses one at a time. The card
/// only ever grows, which is why one number says how far it is open.
///
/// Named for the destination rather than for a city: several of them are
/// provinces, and كريت is an island.
///
/// Only the card takes taps, so the map around it stays live.
final class DestinationCard extends StatelessWidget {
  static const Duration _growDuration = Duration(milliseconds: 260);

  /// The level being played.
  final GameLevel level;

  /// The name of the destination the level is delivered to.
  final String destinationLabel;

  /// The verses revealed so far.
  final List<String> verses;

  /// Whose words those verses are; shown once above them.
  final GameCharacter versesSpeaker;

  /// Whether another part of the card is waiting behind a press.
  final bool hasMore;

  /// Opens the card one part further.
  final VoidCallback onReveal;

  /// Steps the script. Taken instead of [onReveal] once the card has
  /// nothing left to give, so a card that fills a phone is never a dead
  /// spot the player has to tap around.
  final VoidCallback onAdvance;

  /// Creates the card.
  const DestinationCard({
    required this.level,
    required this.destinationLabel,
    required this.verses,
    required this.versesSpeaker,
    required this.hasMore,
    required this.onReveal,
    required this.onAdvance,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screen = GameScreenSize.of(context);

    return Center(
      child: SafeArea(
        child: AnimatedSize(
          duration: _growDuration,
          curve: Curves.easeOutBack,
          child: GestureDetector(
            onTap: hasMore ? onReveal : onAdvance,
            child: PixelPanel(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: screen.pick(compact: 0, large: 22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Sign(destinationLabel: destinationLabel, year: level.year),
                    _Verses(verses: verses, speaker: versesSpeaker),
                    if (hasMore) ...[
                      const SizedBox(height: 10),
                      const Center(
                        widthFactor: 1,
                        child: ContinueChevron(icon: Icons.keyboard_arrow_down),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The لافتة: where the letter was delivered, and when it was written.
///
/// The play stages exactly this — `لافتة كبيرة مكتوب عليها تسالونيكي 52م`
/// — so it is the one thing on screen naming the place, and the top panel
/// it replaced carried a progress bar nobody needed.
final class _Sign extends StatelessWidget {
  final String destinationLabel;
  final int? year;
  const _Sign({
    required this.destinationLabel,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final text = TextTheme.of(context);
    final screen = GameScreenSize.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          destinationLabel,
          textAlign: TextAlign.center,
          style: screen
              .pick(compact: text.headlineSmall, large: text.displaySmall)
              ?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: GamePalette.ink,
              ),
        ),
        if (year case final writtenYear?) ...[
          const SizedBox(height: 4),
          Text(
            '${ArabicNumerals.format(writtenYear)} م',
            textAlign: TextAlign.center,
            style: screen
                .pick(compact: text.titleMedium, large: text.titleLarge)
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: GamePalette.accent,
                ),
          ),
        ],
      ],
    );
  }
}

/// The verses revealed so far, under the name of whoever wrote them.
final class _Verses extends StatelessWidget {
  final List<String> verses;
  final GameCharacter speaker;
  const _Verses({
    required this.verses,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: GameScreenSize.of(context).pick(compact: 0, large: 14.0),
      ),
      AnimatedSize(
        duration: DestinationCard._growDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: verses
              .mapIndexed((i, v) => _Verse(index: i, text: v))
              .toList(),
        ),
      ),
    ],
  );
}

/// One revealed verse, ruled off from the one before it.
final class _Verse extends StatelessWidget {
  final int index;
  final String text;
  const _Verse({
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TextTheme.of(context);
    final screen = GameScreenSize.of(context);
    final numberFormat = NumberFormat('#', 'ar-EG');

    return Padding(
      padding: EdgeInsets.only(top: screen.pick(compact: 0, large: 10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 2, color: GamePalette.ink.withValues(alpha: 0.2)),
          Text(
            '${numberFormat.format(index + 1)}. $text',
            textAlign: TextAlign.center,
            // Verses are the one thing on this card that has no upper
            // bound: a city can collect two letters' worth, and they all
            // have to be on screen at once because nothing here scrolls.
            // Hence the tighter leading on a phone as well as the
            // smaller face — the line height is doing as much of the
            // work as the size is.
            style: screen
                .pick(compact: theme.bodyLarge, large: theme.displaySmall)
                ?.copyWith(
                  height: screen.pick(compact: 1.25, large: 1.8),
                  color: GamePalette.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

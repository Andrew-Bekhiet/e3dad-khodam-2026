import 'package:e3dad_khodam_2026/src/app/arabic_numerals.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The level's card, laid over the map once the sweep has landed.
///
/// It opens in three parts, one press each: the **sign** — the
/// destination's name and year, the play's own لافتة — then the level's
/// artwork behind it, then the verses one at a time. The card only ever
/// grows, which is why one number says how far it is open.
///
/// Named for the destination rather than for a city: several of them are
/// provinces, and كريت is an island.
///
/// Only the card takes taps, so the map around it stays live.
final class DestinationCard extends StatelessWidget {
  /// How tall the card stands once its artwork is showing. Set this to
  /// the viewport height and the card covers the whole map — that is the
  /// single number the full-screen question turns on.
  ///
  /// A constant on a big screen, where 400 is a comfortable third of the
  /// window. On a phone it is a share of the viewport instead: 400 fixed
  /// pixels is most of a phone held sideways, and this is only a *floor*
  /// — the verses push past it and would have nowhere to go.
  static const double _openHeightLarge = 400.0;
  static const double _openHeightCompactRatio = 0.55;

  static const Duration _growDuration = Duration(milliseconds: 260);

  /// The level being played.
  final GameLevel level;

  /// The name of the destination the level is delivered to.
  final String destinationLabel;

  /// Whether the artwork has been revealed.
  final bool showsImage;

  /// The verses revealed so far.
  final List<String> verses;

  /// Whose words those verses are; shown once above them.
  final GameCharacter versesSpeaker;

  /// Whether another part of the card is waiting behind a press.
  final bool hasMore;

  /// Opens the card one part further.
  final VoidCallback onReveal;

  /// Creates the card.
  const DestinationCard({
    required this.level,
    required this.destinationLabel,
    required this.showsImage,
    required this.verses,
    required this.versesSpeaker,
    required this.hasMore,
    required this.onReveal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screen = GameScreenSize.of(context);
    final openHeight = screen.pick(
      compact: MediaQuery.sizeOf(context).height * _openHeightCompactRatio,
      large: _openHeightLarge,
    );

    return Center(
      child: SafeArea(
        child: AnimatedSize(
          duration: _growDuration,
          curve: Curves.easeOutBack,
          child: GestureDetector(
            onTap: hasMore ? onReveal : null,
            child: PixelPanel(
              padding: EdgeInsets.zero,
              color: showsImage ? GamePalette.ink : GamePalette.parchment,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  if (showsImage)
                    Positioned.fill(
                      child: _Artwork(
                        asset: level.imageAsset,
                        label: destinationLabel,
                      ),
                    ),
                  if (showsImage)
                    const Positioned.fill(
                      child: ColoredBox(color: GamePalette.scrim),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: showsImage ? openHeight : 0,
                      minWidth: showsImage ? double.infinity : 0,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: screen.pick(compact: 8, large: 22),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Sign(
                            destinationLabel: destinationLabel,
                            year: level.year,
                            onImage: showsImage,
                          ),
                          _Verses(
                            verses: verses,
                            speaker: versesSpeaker,
                            onImage: showsImage,
                          ),
                          if (hasMore) ...[
                            const SizedBox(height: 10),
                            const Center(
                              widthFactor: 1,
                              child: ContinueChevron(
                                icon: Icons.keyboard_arrow_down,
                              ),
                            ),
                          ],
                        ],
                      ),
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

/// The لافتة: where the letter was delivered, and when it was written.
///
/// The play stages exactly this — `لافتة كبيرة مكتوب عليها تسالونيكي 52م`
/// — so it is the one thing on screen naming the place, and the top panel
/// it replaced carried a progress bar nobody needed.
final class _Sign extends StatelessWidget {
  final String destinationLabel;
  final int? year;
  final bool onImage;

  const _Sign({
    required this.destinationLabel,
    required this.year,
    required this.onImage,
  });

  @override
  Widget build(BuildContext context) {
    final ink = onImage ? GamePalette.parchment : GamePalette.ink;
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
                color: ink,
              ),
        ),
        if (year != null) ...[
          const SizedBox(height: 4),
          Text(
            '${ArabicNumerals.format(year!)} م',
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
  final bool onImage;

  const _Verses({
    required this.verses,
    required this.speaker,
    required this.onImage,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: GameScreenSize.of(context).pick(compact: 4.0, large: 14.0),
      ),
      AnimatedSize(
        duration: DestinationCard._growDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final verse in verses) _Verse(text: verse, onImage: onImage),
          ],
        ),
      ),
    ],
  );
}

/// One revealed verse, ruled off from the one before it.
final class _Verse extends StatelessWidget {
  final String text;
  final bool onImage;

  const _Verse({required this.text, required this.onImage});

  @override
  Widget build(BuildContext context) {
    final ink = onImage ? GamePalette.parchment : GamePalette.ink;
    final theme = TextTheme.of(context);
    final screen = GameScreenSize.of(context);

    return Padding(
      padding: EdgeInsets.only(top: screen.pick(compact: 4, large: 10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 2, color: ink.withValues(alpha: 0.2)),
          Text(
            text,
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
                  height: screen.pick(compact: 1.3, large: 1.8),
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// The level's picture, or a plain stand-in until one is drawn.
///
/// Every level names an artwork file and none of them exists yet, so the
/// stand-in is what the game actually shows today. It is a deliberate
/// panel rather than an empty frame: the operator presses the same number
/// of times either way, and a blank looks like a fault in front of a
/// room.
final class _Artwork extends StatelessWidget {
  /// Fills picked so consecutive levels do not repeat, deep enough that
  /// the scrim and the parchment text stay readable over them.
  static const List<Color> _standInFills = [
    Color(0xFF243B55),
    Color(0xFF3E2C41),
    Color(0xFF1F4037),
    Color(0xFF4A2C2A),
    Color(0xFF2C3E50),
  ];

  final String asset;
  final String label;

  const _Artwork({required this.asset, required this.label});

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => _StandIn(label: label),
  );
}

/// The stand-in drawn when a level's artwork file is missing.
final class _StandIn extends StatelessWidget {
  final String label;

  const _StandIn({required this.label});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _Artwork._standInFills[label.length % _Artwork._standInFills.length],
    child: Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextTheme.of(context).displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: GamePalette.parchment.withValues(alpha: 0.14),
        ),
      ),
    ),
  );
}

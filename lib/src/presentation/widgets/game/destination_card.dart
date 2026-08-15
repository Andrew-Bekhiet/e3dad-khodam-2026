import 'package:e3dad_khodam_2026/src/app/arabic_numerals.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
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
  static const double _maxWidth = 820.0;
  static const double _maxHeightFactor = 0.72;

  /// How tall the card stands once its artwork is showing. Set this to
  /// the viewport height and the card covers the whole map — that is the
  /// single number the full-screen question turns on.
  static const double _openHeight = 400.0;

  static const double _speakerPortraitSize = 56.0;
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
  Widget build(BuildContext context) => Center(
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 88, 20, 88),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _maxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
          ),
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
                    _Body(
                      level: level,
                      destinationLabel: destinationLabel,
                      showsImage: showsImage,
                      verses: verses,
                      versesSpeaker: versesSpeaker,
                      hasMore: hasMore,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The card's text, over whatever the background happens to be.
final class _Body extends StatelessWidget {
  final GameLevel level;
  final String destinationLabel;
  final bool showsImage;
  final List<String> verses;
  final GameCharacter versesSpeaker;
  final bool hasMore;

  const _Body({
    required this.level,
    required this.destinationLabel,
    required this.showsImage,
    required this.verses,
    required this.versesSpeaker,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: showsImage ? DestinationCard._openHeight : 0,
      minWidth: showsImage ? double.infinity : 0,
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sign(
            destinationLabel: destinationLabel,
            year: level.year,
            onImage: showsImage,
          ),
          if (verses.isNotEmpty)
            Flexible(
              child: _Verses(
                verses: verses,
                speaker: versesSpeaker,
                onImage: showsImage,
              ),
            ),
          if (hasMore) ...[
            const SizedBox(height: 10),
            const Center(child: ContinueChevron(icon: Icons.keyboard_arrow_down)),
          ],
        ],
      ),
    ),
  );
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          destinationLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
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
            style: const TextStyle(
              fontSize: 19,
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
      const SizedBox(height: 14),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CharacterPortrait(
            character: speaker,
            size: DestinationCard._speakerPortraitSize,
          ),
          const SizedBox(width: 10),
          Text(
            speaker.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: GamePalette.accent,
            ),
          ),
        ],
      ),
      Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Keyed on the text so an already-revealed verse keeps its
              // state when the next one arrives, and only the new one
              // plays its entrance.
              for (final verse in verses)
                _Verse(key: ValueKey(verse), text: verse, onImage: onImage),
            ],
          ),
        ),
      ),
    ],
  );
}

/// One revealed verse, ruled off from the one before it.
///
/// It animates itself in rather than relying on the card growing around
/// it. Once the artwork is showing, the card stands at a fixed height, so
/// adding a verse no longer changes its size and `AnimatedSize` has
/// nothing to animate — which is exactly why the reveal stopped reading
/// as an event. This puts the movement on the verse itself, where it
/// belongs, and it now works whether the card grows or not.
final class _Verse extends StatefulWidget {
  static const Duration _enterDuration = Duration(milliseconds: 420);

  /// How far the verse rises as it fades in, in logical pixels.
  static const double _rise = 18.0;

  final String text;
  final bool onImage;

  const _Verse({required this.text, required this.onImage, super.key});

  @override
  State<_Verse> createState() => _VerseState();
}

class _VerseState extends State<_Verse> with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: _Verse._enterDuration,
  )..forward();

  late final Animation<double> _eased = CurvedAnimation(
    parent: _enter,
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final ink = widget.onImage ? GamePalette.parchment : GamePalette.ink;

    return FadeTransition(
      opacity: _eased,
      child: AnimatedBuilder(
        animation: _eased,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - _eased.value) * _Verse._rise),
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 2, color: ink.withValues(alpha: 0.2)),
              const SizedBox(height: 10),
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, height: 1.8, color: ink),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
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
        style: TextStyle(
          fontSize: 84,
          fontWeight: FontWeight.w700,
          color: GamePalette.parchment.withValues(alpha: 0.14),
        ),
      ),
    ),
  );
}

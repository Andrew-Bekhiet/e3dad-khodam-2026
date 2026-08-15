import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The level's city card, laid over the map while the level is being
/// played: its artwork, its name, and the verses the play quotes for it,
/// revealed one at a time by the down arrow or a tap on the card.
///
/// Only the card takes taps, so the map around it stays live.
final class CityOverlay extends StatelessWidget {
  static const double _maxWidth = 820.0;
  static const double _maxHeightFactor = 0.66;
  static const double _imageHeight = 260.0;
  static const double _speakerPortraitSize = 56.0;
  static const Duration _revealDuration = Duration(milliseconds: 220);

  /// The level being played.
  final GameLevel level;

  /// The name of the city the level is delivered to.
  final String cityLabel;

  /// The verses revealed so far.
  final List<String> verses;

  /// Whose words those verses are; shown once above them.
  final GameCharacter versesSpeaker;

  /// Whether another verse is waiting behind the down arrow.
  final bool hasMoreVerses;

  /// Reveals the next verse.
  final VoidCallback onRevealVerse;

  /// Creates the city card.
  const CityOverlay({
    required this.level,
    required this.cityLabel,
    required this.verses,
    required this.versesSpeaker,
    required this.hasMoreVerses,
    required this.onRevealVerse,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Visibility(
      visible: verses.isNotEmpty,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 96, 20, 80),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _maxWidth,
              maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
            ),
            child: AnimatedSize(
              duration: _revealDuration,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: hasMoreVerses ? onRevealVerse : null,
                child: PixelPanel(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Artwork(asset: level.imageAsset),
                      const SizedBox(height: 12),
                      Text(
                        cityLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: GamePalette.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: GamePalette.ink,
                        ),
                      ),
                      if (verses.isNotEmpty)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CharacterPortrait(
                                  character: versesSpeaker,
                                  size: _speakerPortraitSize,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  versesSpeaker.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: GamePalette.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final verse in verses)
                                    _Verse(text: verse),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (hasMoreVerses) ...[
                        const SizedBox(height: 8),
                        const Center(
                          child: ContinueChevron(
                            icon: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The level's picture, or nothing at all when its file has not been
/// added yet — an empty frame would say less than the city name already
/// does.
final class _Artwork extends StatelessWidget {
  final String asset;

  const _Artwork({required this.asset});

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    height: CityOverlay._imageHeight,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
  );
}

/// One revealed verse, ruled off from the one before it.
final class _Verse extends StatelessWidget {
  final String text;

  const _Verse({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 2, color: GamePalette.ink.withValues(alpha: 0.15)),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            height: 1.8,
            color: GamePalette.ink,
          ),
        ),
      ],
    ),
  );
}

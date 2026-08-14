import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/app/arabic_numerals.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The heads-up display: which level the player is on, what it is about,
/// and how far through the fourteen letters they are.
final class LevelHud extends StatelessWidget {
  static const double _maxWidth = 520.0;
  static const double _progressHeight = 8.0;

  /// The playthrough state being displayed.
  final GameJourneyState state;

  /// Creates the HUD.
  const LevelHud({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final level = state.level;

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: PixelPanel(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    level == null
                        ? AppStrings.gameTitle
                        : '${AppStrings.levelWord} '
                              '${ArabicNumerals.format(state.levelNumber)}'
                              ' / '
                              '${ArabicNumerals.format(state.levelCount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: GamePalette.accent,
                    ),
                  ),
                  if (level != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      level.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: GamePalette.ink,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _ProgressBar(progress: state.progress),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A flat, square-cornered progress bar — a filled strip inside an ink
/// outline, matching the panels rather than Material's rounded one.
final class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) => Container(
    height: LevelHud._progressHeight,
    decoration: BoxDecoration(
      border: Border.all(color: GamePalette.ink, width: 2),
    ),
    child: FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: progress.clamp(0, 1),
      child: const ColoredBox(color: GamePalette.cleared),
    ),
  );
}

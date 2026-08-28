import 'package:e3dad_khodam_2026/src/app/arabic_numerals.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// A quiet presenter-only count of the current level's positions.
final class LevelStepCounter extends StatelessWidget {
  /// Current progress, absent outside a level.
  final LevelStepProgress? progress;

  /// Creates the presenter counter.
  const LevelStepCounter({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    final current = progress;
    if (current == null) {
      return const SizedBox.shrink();
    }
    final screen = GameScreenSize.of(context);
    final text = TextTheme.of(context);
    final counter =
        '${ArabicNumerals.format(current.current)} / ${ArabicNumerals.format(current.total)}';

    return IgnorePointer(
      child: Semantics(
        label:
            'الخطوة ${ArabicNumerals.format(current.current)} من ${ArabicNumerals.format(current.total)}',
        child: PixelPanel(
          color: GamePalette.parchment.withValues(alpha: 0.72),
          border: GamePalette.ink.withValues(alpha: 0.42),
          padding: EdgeInsets.symmetric(
            horizontal: screen.pick(compact: 8, large: 10),
            vertical: screen.pick(compact: 4, large: 5),
          ),
          child: Text(
            counter,
            textDirection: TextDirection.ltr,
            style: screen
                .pick(compact: text.labelSmall, large: text.labelMedium)
                ?.copyWith(color: GamePalette.ink.withValues(alpha: 0.68)),
          ),
        ),
      ),
    );
  }
}

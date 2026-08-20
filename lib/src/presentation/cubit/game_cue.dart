import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/step_direction.dart';

enum GameCue { levelCleared }

/// Selects the sound earned by a move; playback stays with the cubit.
final class GameCueSheet {
  const GameCueSheet();

  GameCue? cueFor(GameTransition transition) => switch (transition) {
    GameTransition(
      direction: StepDirection.forward,
      arrival: ClearanceStep(),
      isFirstClearance: true,
    ) =>
      GameCue.levelCleared,
    GameTransition() => null,
  };
}

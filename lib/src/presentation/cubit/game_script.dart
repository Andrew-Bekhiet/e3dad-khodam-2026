import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';

/// The ordered, flattened Play Script the journey walks.
final class GameScript {
  static List<GameStep> _buildSteps(LevelScript script) => [
    const OpeningStep(),
    for (final beat in script.prologue) PrologueStep(beat),
    for (final (index, level) in script.levels.indexed) ...[
      for (final beat in level.briefing) BriefingStep(index, beat),
      PlayingStep(index),
      for (final beat in level.clearance) ClearanceStep(index, beat),
    ],
    for (final beat in script.epilogue) EpilogueStep(beat),
  ];

  final LevelScript script;
  final List<GameStep> steps;

  GameScript(this.script) : steps = _buildSteps(script);

  GameStep stepAt(int index) => steps[index];

  bool isLevelOpening(int index) {
    final step = steps[index];
    if (step is PrologueStep) {
      return index > 0 && steps[index - 1] is! PrologueStep;
    }
    if (step is LevelStep) {
      return _levelStepOpens(index, step);
    }

    return false;
  }

  bool _levelStepOpens(int index, LevelStep step) {
    if (index == 0) {
      return true;
    }
    if (step.levelIndex == 0 && steps[index - 1] is PrologueStep) {
      return false;
    }

    return switch (steps[index - 1]) {
      LevelStep(levelIndex: final previousLevelIndex) =>
        previousLevelIndex != step.levelIndex,
      OpeningStep() || PrologueStep() || EpilogueStep() => true,
    };
  }

  bool isFirstClearanceStep(int index) => switch (steps[index]) {
    ClearanceStep() => index == 0 || steps[index - 1] is! ClearanceStep,
    OpeningStep() ||
    PrologueStep() ||
    BriefingStep() ||
    PlayingStep() ||
    EpilogueStep() => false,
  };

  int? firstStepForStop(String stopId, {required int reachedLevelCount}) {
    for (final (index, step) in steps.indexed) {
      if (switch (step) {
        LevelStep(:final levelIndex) when levelIndex < reachedLevelCount =>
          script.levels[levelIndex].destination.id == stopId,
        OpeningStep() || PrologueStep() || EpilogueStep() => false,
        LevelStep() => false,
      }) {
        return index;
      }
    }

    return null;
  }
}

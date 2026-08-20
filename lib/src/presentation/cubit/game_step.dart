import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:equatable/equatable.dart';

export 'game_phase.dart';

sealed class GameStep extends Equatable {
  GamePhase get phase;

  const GameStep();
}

final class OpeningStep extends GameStep {
  @override
  GamePhase get phase => GamePhase.opening;

  @override
  List<Object?> get props => [phase];

  const OpeningStep();
}

final class PrologueStep extends GameStep {
  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.prologue;

  @override
  List<Object?> get props => [phase, beat];

  const PrologueStep(this.beat);
}

sealed class LevelStep extends GameStep {
  final int levelIndex;

  @override
  List<Object?> get props => [phase, levelIndex];

  const LevelStep(this.levelIndex);
}

final class BriefingStep extends LevelStep {
  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.briefing;

  @override
  List<Object?> get props => [phase, levelIndex, beat];

  const BriefingStep(super.levelIndex, this.beat);
}

final class PlayingStep extends LevelStep {
  @override
  GamePhase get phase => GamePhase.playing;

  const PlayingStep(super.levelIndex);
}

final class ClearanceStep extends LevelStep {
  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.clearance;

  @override
  List<Object?> get props => [phase, levelIndex, beat];

  const ClearanceStep(super.levelIndex, this.beat);
}

final class EpilogueStep extends GameStep {
  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.epilogue;

  @override
  List<Object?> get props => [phase, beat];

  const EpilogueStep(this.beat);
}

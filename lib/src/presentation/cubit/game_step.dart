import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:equatable/equatable.dart';

export 'game_phase.dart';

sealed class GameStep extends Equatable {
  const GameStep();

  GamePhase get phase;
}

final class OpeningStep extends GameStep {
  const OpeningStep();

  @override
  GamePhase get phase => GamePhase.opening;

  @override
  List<Object?> get props => [phase];
}

final class PrologueStep extends GameStep {
  const PrologueStep(this.beat);

  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.prologue;

  @override
  List<Object?> get props => [phase, beat];
}

sealed class LevelStep extends GameStep {
  const LevelStep(this.levelIndex);

  final int levelIndex;

  @override
  List<Object?> get props => [phase, levelIndex];
}

final class BriefingStep extends LevelStep {
  const BriefingStep(super.levelIndex, this.beat);

  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.briefing;

  @override
  List<Object?> get props => [phase, levelIndex, beat];
}

final class PlayingStep extends LevelStep {
  const PlayingStep(super.levelIndex);

  @override
  GamePhase get phase => GamePhase.playing;
}

final class ClearanceStep extends LevelStep {
  const ClearanceStep(super.levelIndex, this.beat);

  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.clearance;

  @override
  List<Object?> get props => [phase, levelIndex, beat];
}

final class EpilogueStep extends GameStep {
  const EpilogueStep(this.beat);

  final StoryBeat beat;

  @override
  GamePhase get phase => GamePhase.epilogue;

  @override
  List<Object?> get props => [phase, beat];
}

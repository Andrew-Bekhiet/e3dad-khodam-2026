import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:equatable/equatable.dart';

/// Which part of the playthrough a [GameStep] belongs to.
enum GamePhase {
  /// Opening beats, before the first level.
  prologue,

  /// Beats introducing the level the player is about to play.
  briefing,

  /// The level itself: the map, with no overlay in the way.
  playing,

  /// Beats confirming the level was cleared.
  clearance,

  /// Closing beats, after the last level.
  epilogue,
}

/// One position in the playthrough — a single story beat, or the playable
/// map of one level.
///
/// The whole game is a flat list of these, which is what lets the
/// forward/backward controls (arrow keys and on-screen arrows alike) be
/// one `±1` on an index, whether the next thing is another line of
/// dialogue or a whole new level.
final class GameStep extends Equatable {
  /// Which part of the playthrough this step belongs to.
  final GamePhase phase;

  /// Index into `LevelScript.levels`, or null during the prologue and
  /// epilogue, which belong to no level.
  final int? levelIndex;

  /// The line to show, or null when [phase] is [GamePhase.playing] and
  /// the map is meant to be unobstructed.
  final StoryBeat? beat;

  @override
  List<Object?> get props => [phase, levelIndex, beat];

  /// Creates a step. A playing step carries no beat; every other phase
  /// carries exactly one.
  const GameStep({required this.phase, this.levelIndex, this.beat})
    : assert((phase == GamePhase.playing) == (beat == null));
}

import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/character_trail.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:equatable/equatable.dart';

/// A snapshot of the guided playthrough: which step is showing, what the
/// map should draw for it, and where the camera should look.
final class GameJourneyState extends Equatable {
  /// The step currently showing.
  final GameStep step;

  /// Position of [step] in the flat list of steps, and the total — what
  /// the progress bar is drawn from.
  final int stepIndex;

  /// How many steps the whole playthrough has.
  final int stepCount;

  /// The level being briefed, played or cleared; null in the prologue and
  /// epilogue.
  final GameLevel? level;

  /// 1-based number of [level], or 0 when there is none.
  final int levelNumber;

  /// How many levels the script has.
  final int levelCount;

  /// Stops already delivered to, drawn as cleared markers.
  final List<JourneyStop> clearedStops;

  /// The stop this step is about, drawn as the highlighted marker.
  final JourneyStop? currentStop;

  /// The next stop in the script, drawn dimmed as a preview of where the
  /// journey goes next; null on the last level.
  final JourneyStop? nextStop;

  /// One entry per character on the move: their route so far and where
  /// they stand now.
  final List<CharacterTrail> trails;

  /// Where the map should be looking.
  final MapCameraTarget camera;

  /// How long the map surface should take to animate to [camera].
  final Duration cameraAnimationDuration;

  /// The line to show over the map, or null while the level's map is
  /// being played with no overlay.
  StoryBeat? get beat => step.beat;

  /// Whether the map is currently unobstructed.
  bool get isPlaying => step.phase == GamePhase.playing;

  /// Whether there is anything before this step.
  bool get isAtStart => stepIndex <= 0;

  /// Whether there is anything after this step.
  bool get isAtEnd => stepIndex >= stepCount - 1;

  /// Playthrough progress in `0..1`, for the HUD's progress bar.
  double get progress => stepCount <= 1 ? 1 : stepIndex / (stepCount - 1);

  @override
  List<Object?> get props => [
    step,
    stepIndex,
    stepCount,
    level,
    levelNumber,
    levelCount,
    clearedStops,
    currentStop,
    nextStop,
    trails,
    camera,
    cameraAnimationDuration,
  ];

  /// Creates a playthrough state.
  const GameJourneyState({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.levelNumber,
    required this.levelCount,
    required this.clearedStops,
    required this.trails,
    required this.camera,
    required this.cameraAnimationDuration,
    this.level,
    this.currentStop,
    this.nextStop,
  });
}

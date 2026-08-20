import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/reveal.dart';
import 'package:equatable/equatable.dart';

/// A snapshot of the guided playthrough: which step is showing, how much
/// of the destination card is open, what the map should draw, and where
/// the camera should look.
final class GameJourneyState extends Equatable {
  /// The step currently showing.
  final GameStep step;

  /// Position of [step] in the flat list of steps, and the total.
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

  /// Whether [step] is the first step of its level — the one the sweep
  /// runs on, and the only one that starts with a blank screen.
  final bool isLevelOpening;

  /// Stops already delivered to, drawn as cleared markers.
  final List<JourneyStop> clearedStops;

  /// The stop this step is about, drawn as the highlighted marker.
  final JourneyStop? currentStop;

  /// The next stop in the script, drawn dimmed as a preview of where the
  /// journey goes next; null on the last level.
  final JourneyStop? nextStop;

  /// Everyone on the move and the one route they share: the stops behind
  /// them, and the geometry to draw for any point of the leg they are
  /// walking now.
  final CourierParty party;

  /// Where the map should be looking.
  final MapCameraTarget camera;

  /// How long the map surface should take to animate to [camera]. A
  /// [SweepCameraTarget] ignores this and times its own three parts.
  final Duration cameraAnimationDuration;

  /// How far the destination card is open on this step.
  final Reveal reveal;

  /// Verses already read in this destination, from earlier levels
  /// delivered to the same place.
  ///
  /// كورنثوس and تسالونيكي each receive two letters. Their verses belong
  /// to one city and are read in one sitting, so the second letter's
  /// verses are added below the first letter's rather than replacing
  /// them. Cleared only when the journey sweeps to somewhere new.
  final List<String> carriedVerses;

  /// Whether this step starts with a blank map.
  ///
  /// Only a level that is *swept* into does. Two letters to the same
  /// city are not swept between, so there is nothing for a blank screen
  /// to hide and the sign simply stays up.
  bool get opensBlank => isLevelOpening && camera is SweepCameraTarget;

  /// The sweep this step runs, or null when the camera holds still.
  SweepCameraTarget? get sweep =>
      camera is SweepCameraTarget ? camera as SweepCameraTarget : null;

  /// The line to show over the map. Nothing speaks while the level is
  /// still arriving: the sweep owns the screen until it is acknowledged.
  StoryBeat? get beat {
    if (reveal.isArriving(opensBlank: opensBlank)) {
      return null;
    }

    return switch (step) {
      PrologueStep(:final beat) ||
      BriefingStep(:final beat) ||
      ClearanceStep(:final beat) ||
      EpilogueStep(:final beat) => beat,
      OpeningStep() || PlayingStep() => null,
    };
  }

  /// Whether the map is currently unobstructed.
  bool get isPlaying => step is PlayingStep;

  /// Whether there is anything before this step.
  bool get isAtStart => stepIndex <= 0;

  /// Whether there is anything after this step.
  bool get isAtEnd => stepIndex >= stepCount - 1;

  @override
  List<Object?> get props => [
    step,
    stepIndex,
    stepCount,
    level,
    levelNumber,
    levelCount,
    isLevelOpening,
    clearedStops,
    currentStop,
    nextStop,
    party,
    camera,
    cameraAnimationDuration,
    reveal,
    carriedVerses,
  ];

  /// Creates a playthrough state.
  const GameJourneyState({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.levelNumber,
    required this.levelCount,
    required this.isLevelOpening,
    required this.clearedStops,
    required this.party,
    required this.camera,
    required this.cameraAnimationDuration,
    this.reveal = const CardHidden(),
    this.carriedVerses = const [],
    this.level,
    this.currentStop,
    this.nextStop,
  });

  GameJourneyState copyWith({Reveal? reveal}) => GameJourneyState(
    step: step,
    stepIndex: stepIndex,
    stepCount: stepCount,
    level: level,
    levelNumber: levelNumber,
    levelCount: levelCount,
    isLevelOpening: isLevelOpening,
    clearedStops: clearedStops,
    currentStop: currentStop,
    nextStop: nextStop,
    party: party,
    camera: camera,
    cameraAnimationDuration: cameraAnimationDuration,
    reveal: reveal ?? this.reveal,
    carriedVerses: carriedVerses,
  );
}

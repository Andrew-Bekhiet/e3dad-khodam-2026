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
  final ({
    GameStep step,
    int stepIndex,
    int stepCount,
    int levelNumber,
    int levelCount,
    bool isLevelOpening,
  })
  position;

  final ({
    List<JourneyStop> clearedStops,
    JourneyStop? currentStop,
    JourneyStop? nextStop,
    CourierParty party,
    MapCameraTarget camera,
    Duration cameraAnimationDuration,
  })
  map;

  /// The level being briefed, played or cleared; null in the prologue and
  /// epilogue.
  final GameLevel? level;

  /// How far the destination card is open on this step.
  final Reveal reveal;

  /// The step currently showing.
  GameStep get step => position.step;

  /// Position of [step] in the flat list of steps, and the total.
  int get stepIndex => position.stepIndex;

  /// How many steps the whole playthrough has.
  int get stepCount => position.stepCount;

  /// 1-based number of [level], or 0 when there is none.
  int get levelNumber => position.levelNumber;

  /// How many levels the script has.
  int get levelCount => position.levelCount;

  /// Whether [step] is the first step of its level — the one the sweep
  /// runs on, and the only one that starts with a blank screen.
  bool get isLevelOpening => position.isLevelOpening;

  /// Stops already delivered to, drawn as cleared markers.
  List<JourneyStop> get clearedStops => map.clearedStops;

  /// The stop this step is about, drawn as the highlighted marker.
  JourneyStop? get currentStop => map.currentStop;

  /// The next stop in the script, drawn dimmed as a preview of where the
  /// journey goes next; null on the last level.
  JourneyStop? get nextStop => map.nextStop;

  /// Everyone on the move and the one route they share: the stops behind
  /// them, and the geometry to draw for any point of the leg they are
  /// walking now.
  CourierParty get party => map.party;

  /// Where the map should be looking.
  MapCameraTarget get camera => map.camera;

  /// How long the map surface should take to animate to [camera]. A
  /// [SweepCameraTarget] ignores this and times its own three parts.
  Duration get cameraAnimationDuration => map.cameraAnimationDuration;

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

  /// The presenter's position among this level's beats and card reveals.
  LevelStepProgress? get levelProgress {
    final currentLevel = level;
    if (currentLevel == null) {
      return null;
    }
    final briefingCount = currentLevel.briefing.length;
    final cardCount = 1 + currentLevel.verses.length;
    final total = briefingCount + cardCount + currentLevel.clearance.length;

    final current = switch (step) {
      BriefingStep(:final beat) => currentLevel.briefing.indexOf(beat) + 1,
      PlayingStep() => briefingCount + 1 + reveal.versesShown,
      ClearanceStep(:final beat) =>
        briefingCount + cardCount + currentLevel.clearance.indexOf(beat) + 1,
      OpeningStep() || PrologueStep() || EpilogueStep() => null,
    };
    if (current == null) {
      return null;
    }

    return LevelStepProgress(current: current, total: total);
  }

  /// Whether there is anything before this step.
  bool get isAtStart => stepIndex <= 0;

  /// Whether there is anything after this step.
  bool get isAtEnd => stepIndex >= stepCount - 1;

  @override
  List<Object?> get props => [
    position,
    level,
    map,
    reveal,
  ];

  /// Creates a playthrough state.
  const GameJourneyState({
    required this.position,
    required this.map,
    this.reveal = const CardHidden(),
    this.level,
  });

  GameJourneyState copyWith({Reveal? reveal}) => GameJourneyState(
    position: position,
    level: level,
    map: map,
    reveal: reveal ?? this.reveal,
  );
}

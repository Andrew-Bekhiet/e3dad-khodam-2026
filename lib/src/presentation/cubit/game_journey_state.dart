import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/character_trail.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:equatable/equatable.dart';

/// A snapshot of the guided playthrough: which step is showing, how much
/// of the destination card is open, what the map should draw, and where
/// the camera should look.
final class GameJourneyState extends Equatable {
  /// Reveal at which the card shows its sign — the destination's name
  /// and year.
  static const int signReveal = 1;

  /// Reveal at which the card's background artwork appears. Every reveal
  /// above this one is a verse.
  static const int imageReveal = 2;

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

  /// One entry per character on the move: their route so far and where
  /// they stand now.
  final List<CharacterTrail> trails;

  /// Where the map should be looking.
  final MapCameraTarget camera;

  /// How long the map surface should take to animate to [camera]. A
  /// [SweepCameraTarget] ignores this and times its own three parts.
  final Duration cameraAnimationDuration;

  /// How far the destination card is open on this step.
  ///
  /// `0` is nothing at all, then the sign, then the artwork, then one
  /// more for each verse. A single number because the card only ever
  /// grows, and because that lets forward and backward walk it with the
  /// same `±1` they use on steps.
  final int reveal;

  /// The highest [reveal] this step can reach. Beyond it, a press moves
  /// to the next step instead.
  int get maxReveal => switch (step.phase) {
    GamePhase.prologue ||
    GamePhase.epilogue ||
    GamePhase.clearance => 0,
    GamePhase.briefing => signReveal,
    GamePhase.playing => imageReveal + (level?.verses.length ?? 0),
  };

  /// Whether the level has been entered but not yet acknowledged: the
  /// camera is sweeping in, or has just landed, and the screen carries
  /// nothing over the map.
  bool get isArriving => isLevelOpening && reveal == 0;

  /// Whether the card is showing its destination name and year.
  bool get showsSign => reveal >= signReveal;

  /// Whether the card is showing its background artwork.
  bool get showsImage => reveal >= imageReveal;

  /// How many of the level's verses are on the card.
  int get versesShown =>
      (reveal - imageReveal).clamp(0, level?.verses.length ?? 0);

  /// The verses revealed so far, in the order the script quotes them.
  List<String> get revealedVerses =>
      (level?.verses ?? const <String>[]).take(versesShown).toList();

  /// Whether this step still has something left to open.
  bool get hasMoreReveal => reveal < maxReveal;

  /// The sweep this step runs, or null when the camera holds still.
  SweepCameraTarget? get sweep =>
      camera is SweepCameraTarget ? camera as SweepCameraTarget : null;

  /// The line to show over the map. Nothing speaks while the level is
  /// still arriving: the sweep owns the screen until it is acknowledged.
  StoryBeat? get beat => isArriving ? null : step.beat;

  /// Whether the map is currently unobstructed.
  bool get isPlaying => step.phase == GamePhase.playing;

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
    trails,
    camera,
    cameraAnimationDuration,
    reveal,
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
    required this.trails,
    required this.camera,
    required this.cameraAnimationDuration,
    this.reveal = 0,
    this.level,
    this.currentStop,
    this.nextStop,
  });

  /// The same state with the card opened to [reveal]. Nothing else can
  /// change while the card is opening, so this is the one copy the game
  /// needs.
  GameJourneyState withReveal(int reveal) => GameJourneyState(
    step: step,
    stepIndex: stepIndex,
    stepCount: stepCount,
    levelNumber: levelNumber,
    levelCount: levelCount,
    isLevelOpening: isLevelOpening,
    clearedStops: clearedStops,
    trails: trails,
    camera: camera,
    cameraAnimationDuration: cameraAnimationDuration,
    level: level,
    currentStop: currentStop,
    nextStop: nextStop,
    reveal: reveal.clamp(0, maxReveal),
  );
}

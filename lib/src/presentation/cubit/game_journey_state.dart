import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:equatable/equatable.dart';

/// A snapshot of the guided playthrough: which step is showing, how much
/// of the destination card is open, what the map should draw, and where
/// the camera should look.
final class GameJourneyState extends Equatable {
  /// Reveal at which the card shows its sign — the destination's name
  /// and year.
  static const int signReveal = 1;

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
  ///
  /// `0` is nothing at all, then the sign, then one more for each verse.
  /// A single number because the card only ever
  /// grows, and because that lets forward and backward walk it with the
  /// same `±1` they use on steps.
  final int reveal;

  /// Verses already read in this destination, from earlier levels
  /// delivered to the same place.
  ///
  /// كورنثوس and تسالونيكي each receive two letters. Their verses belong
  /// to one city and are read in one sitting, so the second letter's
  /// verses are added below the first letter's rather than replacing
  /// them. Cleared only when the journey sweeps to somewhere new.
  final List<String> carriedVerses;

  /// The highest [reveal] this step can reach. Beyond it, a press moves
  /// to the next step instead.
  ///
  /// A cleared level keeps everything it had open. The level has not
  /// changed, so taking the card away and putting it back would flicker
  /// something the player is still reading.
  int get maxReveal => switch (step) {
    OpeningStep() || EpilogueStep() => 0,
    // One press past the arrival, which is what takes the blank map away
    // and lets the guide speak. Never further: the prologue has no card.
    PrologueStep() || BriefingStep() => signReveal,
    PlayingStep() ||
    ClearanceStep() => signReveal + (level?.verses.length ?? 0),
  };

  /// Whether this step starts with a blank map.
  ///
  /// Only a level that is *swept* into does. Two letters to the same
  /// city are not swept between, so there is nothing for a blank screen
  /// to hide and the sign simply stays up.
  bool get opensBlank => isLevelOpening && camera is SweepCameraTarget;

  /// The lowest [reveal] this step settles at once acknowledged.
  ///
  /// A city already carrying verses opens straight to its sign: the
  /// player is part-way through reading that city, and dropping back to
  /// the bare sign would take away what they are still looking at.
  int get minReveal {
    if (step is OpeningStep || opensBlank) {
      return 0;
    }
    return signReveal;
  }

  /// Whether the level has been entered but not yet acknowledged: the
  /// camera is sweeping in, or has just landed, and the screen carries
  /// nothing over the map.
  bool get isArriving => opensBlank && reveal == 0;

  /// Whether the card is showing its destination name and year.
  bool get showsSign => reveal >= signReveal;

  /// Whether the card is on screen at all.
  ///
  /// A swept-into level's briefing gets the map to itself: the arrival
  /// and the line explaining it are one moment, and raising the sign
  /// underneath puts a second thing on screen to read. The card comes up
  /// on the press that leaves the briefing. A level with no briefing has
  /// nothing to wait for, so its sign rises on arrival as before — and a
  /// level that is not swept into keeps whatever card was already up,
  /// which is the rule against blinking.
  /// The prologue is spoken over the first city on arrival and belongs to
  /// that level, but it is the journey being introduced rather than the
  /// letter — so it never raises the card.
  bool get showsCard => level != null && showsSign && step is! PrologueStep;

  /// How many of the level's verses are on the card.
  int get versesShown =>
      (reveal - signReveal).clamp(0, level?.verses.length ?? 0);

  /// Every verse on the card: those already read in this city, then this
  /// level's own as they are revealed.
  List<String> get revealedVerses => [
    ...carriedVerses,
    ...(level?.verses ?? const <String>[]).take(versesShown),
  ];

  /// Whether this step still has something left to open.
  bool get hasMoreReveal => reveal < maxReveal;

  /// The sweep this step runs, or null when the camera holds still.
  SweepCameraTarget? get sweep =>
      camera is SweepCameraTarget ? camera as SweepCameraTarget : null;

  /// The line to show over the map. Nothing speaks while the level is
  /// still arriving: the sweep owns the screen until it is acknowledged.
  StoryBeat? get beat {
    if (isArriving) {
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
    this.reveal = 0,
    this.carriedVerses = const [],
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
    party: party,
    camera: camera,
    cameraAnimationDuration: cameraAnimationDuration,
    level: level,
    currentStop: currentStop,
    nextStop: nextStop,
    carriedVerses: carriedVerses,
    reveal: reveal.clamp(0, maxReveal),
  );
}

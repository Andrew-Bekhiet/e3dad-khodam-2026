import 'package:bloc/bloc.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/sweep_framing.dart';
import 'package:flutter/widgets.dart';

/// Walks the guided playthrough one step at a time.
///
/// The whole script — prologue beats, then briefing/level/clearance for
/// each level, then epilogue beats — is flattened once into a list of
/// [GameStep]s, so both the arrow keys and the on-screen arrows are the
/// same `±1` on one index no matter what the next thing happens to be.
///
/// The cubit stays synchronous. A sweep takes nearly two seconds, but it
/// is emitted as a [SweepCameraTarget] for the surface to fly rather than
/// timed here — a timer would make the widest point a state the player
/// could stop on, and would put fake async into every test in the suite.
final class GameJourneyCubit extends Cubit<GameJourneyState> {
  /// The frame every sweep pulls out to before diving on its
  /// destination.
  ///
  /// Provisionally the same four numbers as the cross map's root bounds.
  /// It is a constant of its own because the two maps are not the same
  /// map: the cross map's bounds come from mnemonic placements, which are
  /// deliberately not real positions, and the journey must not inherit
  /// them by accident. Changing this is a one-line change.
  static const GeoBounds sweepFrame = GeoBounds(
    south: 30.89,
    west: 10.0,
    north: 43.57,
    east: 26.0,
  );

  /// Zoom the camera settles on over a destination. High enough to make
  /// the city the subject, low enough to keep its coastline in frame.
  static const double arrivalZoom = 10.0;

  /// The three parts of a sweep. Coming in is longer than going out on
  /// purpose: going out is travel, coming in is arrival.
  static const Duration sweepOut = Duration(milliseconds: 700);

  /// How long the camera rests at [sweepFrame].
  ///
  /// This is the whole point of pulling out: the couriers walk their leg
  /// during this pause, with the entire route on screen, and only then
  /// does the camera dive.
  ///
  /// Shorter than it was: framing the leg alone rather than the whole
  /// basin makes the walk legible straight away, so the pause no longer
  /// has to hold long enough for the eye to find two dots in a sea.
  static const Duration sweepHold = Duration(milliseconds: 1000);

  /// How long the camera takes to come in on its destination.
  static const Duration sweepIn = Duration(milliseconds: 900);

  /// Breathing room around a leg-framed sweep, in degrees, so the two
  /// cities are inside the frame rather than on its edges. Degrees rather
  /// than pixels because a short leg and a long one need the frame opened
  /// up by the same *fraction*, not the same number of pixels.
  static const double _legMargin = 0.6;

  /// Screen-space inset for a leg-framed sweep. Smaller than
  /// [_overviewPadding]: this only ever runs on a phone, where that much
  /// inset is most of the viewport.
  static const EdgeInsets _legPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 72,
  );

  /// Screen-space inset used when framing the whole journey, which only
  /// happens in the prologue and the epilogue.
  static const EdgeInsets _overviewPadding = EdgeInsets.only(
    top: 120,
    left: 64,
    right: 64,
    bottom: 104,
  );

  /// Duration for a camera move that is not a sweep.
  static const Duration _stepDuration = Duration(milliseconds: 550);

  /// Flattens [script] into the ordered steps the playthrough walks.
  static List<GameStep> _buildSteps(LevelScript script) => [
    // The map, framed on the post office, with nobody talking over it.
    const GameStep(phase: GamePhase.opening),
    // Belongs to the first level, so it opens that level -- which is what
    // flies the couriers out of الإسماعيلية before a word is said. The
    // guide explains the journey on arrival, not before it.
    for (final beat in script.prologue)
      GameStep(phase: GamePhase.prologue, levelIndex: 0, beat: beat),
    for (final (index, level) in script.levels.indexed) ...[
      for (final beat in level.briefing)
        GameStep(phase: GamePhase.briefing, levelIndex: index, beat: beat),
      GameStep(phase: GamePhase.playing, levelIndex: index),
      for (final beat in level.clearance)
        GameStep(phase: GamePhase.clearance, levelIndex: index, beat: beat),
    ],
    for (final beat in script.epilogue)
      GameStep(phase: GamePhase.epilogue, beat: beat),
  ];

  /// Builds the state showing step [index] of [steps].
  ///
  /// [backward] opens the card fully on arrival: someone stepping back is
  /// returning to something they have already seen, and making them press
  /// through five verses again to reach the line before them is a way of
  /// losing the room.
  ///
  /// [from] is the state being left, or null for the state the game opens
  /// on. The camera needs it: a sweep is a *departure*, so whether one
  /// runs is a fact about the move rather than about the step arrived at.
  static GameJourneyState _stateAt(
    LevelScript script,
    List<GameStep> steps,
    int index, {
    required bool backward,
    required SweepFraming framing,
    GameJourneyState? from,
  }) {
    final step = steps[index];
    final levels = script.levels;
    final levelIndex = _levelIndexOf(step, levels.length);
    // The epilogue is the one step with nowhere to be: the letters are
    // all delivered, so no stop is the current one.
    final currentStop = step.phase == GamePhase.epilogue
        ? null
        : levels[levelIndex].destination;
    final clearedCount = switch (step.phase) {
      GamePhase.epilogue => levels.length,
      GamePhase.clearance => levelIndex + 1,
      _ => levelIndex,
    };
    final isLevelOpening = _isLevelOpening(steps, index);

    final state = GameJourneyState(
      step: step,
      stepIndex: index,
      stepCount: steps.length,
      level: step.levelIndex == null ? null : levels[levelIndex],
      levelNumber: step.levelIndex == null ? 0 : levelIndex + 1,
      levelCount: levels.length,
      isLevelOpening: isLevelOpening,
      clearedStops: _clearedStops(levels, clearedCount, currentStop),
      currentStop: currentStop,
      nextStop: _nextStop(levels, levelIndex, step),
      party: _partyThrough(script, levelIndex, step),
      camera: _cameraFor(
        script,
        levelIndex,
        step,
        from: from,
        backward: backward,
        framing: framing,
      ),
      cameraAnimationDuration: _stepDuration,
      carriedVerses: _carriedVerses(levels, levelIndex, step),
    );

    // Stepping back returns to something already seen, and a cleared
    // level has just been read: both open the card fully rather than
    // making the operator press through verses again to reach the line
    // they were on.
    if (backward || step.phase == GamePhase.clearance) {
      return state.withReveal(state.maxReveal);
    }

    // A swept-into level opens on a blank map: the sweep owns the screen
    // until the next press acknowledges the arrival. Everything else
    // keeps its sign, so the card never blinks inside one level.
    return state.withReveal(state.minReveal);
  }

  /// Verses read in this destination before this level.
  ///
  /// A city receiving two letters reads their verses in one sitting —
  /// كورنثوس and تسالونيكي both do — so the second letter's verses are
  /// added below the first's instead of replacing them. Only the levels
  /// *before* this one contribute; this level's own arrive one press at
  /// a time as always.
  static List<String> _carriedVerses(
    List<GameLevel> levels,
    int levelIndex,
    GameStep step,
  ) {
    if (step.levelIndex == null) {
      return const [];
    }
    final destination = levels[levelIndex].destination;

    return [
      for (final level in levels.take(levelIndex))
        if (level.destination.id == destination.id) ...level.verses,
    ];
  }

  /// Whether step [index] is the first of its level.
  static bool _isLevelOpening(List<GameStep> steps, int index) {
    final levelIndex = steps[index].levelIndex;
    if (levelIndex == null) {
      return false;
    }

    return index == 0 || steps[index - 1].levelIndex != levelIndex;
  }

  /// The level a step draws the map for: its own, or the first level for
  /// the prologue and the last one for the epilogue — those beats belong
  /// to no level but still need somewhere to look.
  static int _levelIndexOf(GameStep step, int levelCount) =>
      step.levelIndex ?? (step.phase == GamePhase.opening ? 0 : levelCount - 1);

  /// Destinations of the levels already delivered to, in order, minus
  /// [currentStop] (which is drawn as the highlighted marker instead) and
  /// with repeated cities collapsed.
  static List<JourneyStop> _clearedStops(
    List<GameLevel> levels,
    int clearedCount,
    JourneyStop? currentStop,
  ) {
    final byId = <String, JourneyStop>{};
    for (final level in levels.take(clearedCount)) {
      byId[level.destination.id] = level.destination;
    }
    byId.remove(currentStop?.id);

    return byId.values.toList(growable: false);
  }

  /// The stop after this one, shown dimmed as a preview; null once there
  /// is nothing left to preview.
  static JourneyStop? _nextStop(
    List<GameLevel> levels,
    int levelIndex,
    GameStep step,
  ) {
    if (step.phase == GamePhase.epilogue || levelIndex + 1 >= levels.length) {
      return null;
    }

    return levels[levelIndex + 1].destination;
  }

  /// The party as it stands after the levels up to and including
  /// [levelIndex]: their destinations in play order, with consecutive
  /// stays in the same city collapsed into one point.
  ///
  /// One journey, because everyone travels together — the roster is the
  /// script's and does not change from level to level.
  static CourierParty _partyThrough(
    LevelScript script,
    int levelIndex,
    GameStep step,
  ) {
    // The journey starts at the post office, and during the prologue that
    // is all of it: nobody has set off yet.
    final stops = <JourneyStop>[script.home];
    if (step.phase != GamePhase.opening) {
      for (final level in script.levels.take(levelIndex + 1)) {
        if (stops.last.id != level.destination.id) {
          stops.add(level.destination);
        }
      }
    }

    return CourierParty(
      couriers: script.couriers,
      stops: List.unmodifiable(stops),
    );
  }

  /// Where the camera looks for a step.
  ///
  /// Every step of a level answers the same thing, so the camera moves
  /// once per level and then holds while the guide talks and the verses
  /// are read. Reaching a new destination is a sweep; staying in the same
  /// city is not, since a sweep between the two letters to تسالونيكي
  /// would fly out to the whole basin and come back to the identical
  /// view.
  ///
  /// A sweep is only ever emitted for a move that is genuinely a
  /// departure — forwards, from one city to a different one. Everything
  /// else lands on the plain arrival, which the surface reaches with an
  /// ordinary pan.
  static MapCameraTarget _cameraFor(
    LevelScript script,
    int levelIndex,
    GameStep step, {
    required GameJourneyState? from,
    required bool backward,
    required SweepFraming framing,
  }) {
    final levels = script.levels;
    // The camera was decided when the level was entered, and a level's
    // steps must all carry the same one: handing the surface a different
    // target mid-level makes it fly to where it already is, and would let
    // a step back and forward inside a level re-run its whole sweep.
    if (from != null &&
        step.levelIndex != null &&
        from.step.levelIndex == step.levelIndex) {
      return from.camera;
    }
    // The map opens on the post office rather than flying to it: this is
    // where the couriers already are, and an arrival needs somewhere to
    // have arrived from.
    if (step.phase == GamePhase.opening) {
      return CenterZoomCameraTarget(
        center: script.home.position,
        zoom: arrivalZoom,
      );
    }
    if (step.levelIndex == null) {
      return FitBoundsCameraTarget(
        bounds: GeoBounds.containing([
          for (final level in levels) level.destination.position,
        ]),
        padding: _overviewPadding,
      );
    }

    final destination = levels[levelIndex].destination;
    final arrival = CenterZoomCameraTarget(
      center: destination.position,
      zoom: arrivalZoom,
    );
    // Stepping back is reviewing the journey, not making it again. The
    // clearance and departure stings are already kept quiet for the same
    // reason; a sweep would be louder than either, and it would fly out
    // to the whole basin over a card the operator is reading.
    if (backward) {
      return arrival;
    }
    // Nowhere to depart for. Two letters to تسالونيكي, a tap on the city
    // already on screen, a step out of the epilogue and back in: all of
    // them would otherwise pull out to the basin and dive on the view
    // already showing.
    if (from == null || from.party.destination.id == destination.id) {
      return arrival;
    }

    return SweepCameraTarget(
      widest: _widestFrame(from.party.destination, destination, framing),
      arrival: arrival,
      outLeg: sweepOut,
      hold: sweepHold,
      inLeg: sweepIn,
    );
  }

  /// The frame a sweep from [departure] to [destination] pulls out to.
  static FitBoundsCameraTarget _widestFrame(
    JourneyStop departure,
    JourneyStop destination,
    SweepFraming framing,
  ) => switch (framing) {
    SweepFraming.basin => const FitBoundsCameraTarget(
      bounds: sweepFrame,
      padding: EdgeInsets.zero,
    ),
    SweepFraming.leg => FitBoundsCameraTarget(
      bounds: GeoBounds.containing([
        departure.position,
        destination.position,
      ]).padded(_legMargin),
      padding: _legPadding,
    ),
  };

  final LevelScript _script;
  final GameSounds _sounds;
  final List<GameStep> _steps;

  /// How wide the next sweep pulls out. Set by whoever knows how much
  /// screen there is; only read when a sweep is built, so changing it
  /// never disturbs a flight already under way.
  SweepFraming sweepFraming;

  /// The character who fronts the guide overlay.
  GameCharacter get guide => _script.guide;

  /// The character credited on the narrator overlay.
  GameCharacter get narrator => _script.narrator;

  /// Whose words the destination cards' verses are.
  GameCharacter get letterWriter => _script.letterWriter;

  /// Loads the script once and starts on its first step.
  ///
  /// [sounds] is silent by default; pass a real player once the clearance
  /// jingle exists and it will fire on every level cleared.
  factory GameJourneyCubit(
    LevelScriptRepository repository, {
    required GameSounds sounds,
    SweepFraming framing = SweepFraming.basin,
  }) {
    final script = repository.loadLevelScript();

    return GameJourneyCubit._(script, sounds, _buildSteps(script), framing);
  }

  GameJourneyCubit._(
    LevelScript script,
    GameSounds sounds,
    List<GameStep> steps,
    SweepFraming framing,
  ) : _script = script,
      _sounds = sounds,
      _steps = steps,
      sweepFraming = framing,
      super(_stateAt(script, steps, 0, backward: false, framing: framing));

  /// Advances one press: opens the card a little further if it has
  /// anything left to show, otherwise moves to the next step.
  void forward() {
    if (state.hasMoreReveal) {
      emit(state.withReveal(state.reveal + 1));

      return;
    }
    _goTo(state.stepIndex + 1, backward: false);
  }

  /// Steps back one press, closing the card a part at a time before
  /// leaving the step.
  void backward() {
    if (state.reveal > state.minReveal) {
      emit(state.withReveal(state.reveal - 1));

      return;
    }
    _goTo(state.stepIndex - 1, backward: true);
  }

  /// Returns to the opening beat.
  void restart() {
    _goTo(0, backward: false);
  }

  /// Opens the card one part further — the sign, then the artwork, then
  /// the verses one at a time. Does nothing once it is fully open.
  void revealNext() {
    if (!state.hasMoreReveal) {
      return;
    }
    emit(state.withReveal(state.reveal + 1));
  }

  /// Closes the last part of the card again.
  void revealPrevious() {
    if (state.reveal == 0) {
      return;
    }
    emit(state.withReveal(state.reveal - 1));
  }

  /// Jumps to the level whose destination is [stopId], as long as the
  /// journey has already reached it — tapping a city ahead of the story
  /// does nothing.
  ///
  /// Lands on the level's *first* step rather than its map, so the jump
  /// arrives the way the story does: a sweep, then the sign, then the
  /// guide.
  void goToStop(String stopId) {
    final reached = switch (state.step.phase) {
      GamePhase.prologue => 0,
      GamePhase.epilogue => state.levelCount,
      _ => state.levelNumber,
    };
    final target = _steps.indexWhere(
      (step) => switch (step.levelIndex) {
        final int index when index < reached =>
          _script.levels[index].destination.id == stopId,
        _ => false,
      },
    );
    if (target >= 0) {
      _goTo(target, backward: false);
    }
  }

  /// Moves to [index], ignoring anything outside the script, and sounds
  /// what the move means — a level passed, or the party setting off.
  ///
  /// Both only going forwards. Stepping back over a moment is reviewing
  /// it, not living it again, and the sounds would pile up on an operator
  /// nudging back and forth to find their place.
  void _goTo(int index, {required bool backward}) {
    if (index < 0 || index >= _steps.length || index == state.stepIndex) {
      return;
    }
    final forward = index > state.stepIndex;
    if (forward && _isFirstClearanceStep(index)) {
      _sounds.playLevelCleared();
    }
    final next = _stateAt(
      _script,
      _steps,
      index,
      backward: backward,
      framing: sweepFraming,
      from: state,
    );
    emit(next);
  }

  /// Whether [index] is the moment a level is cleared: its first
  /// clearance beat, not the ones that merely follow it.
  bool _isFirstClearanceStep(int index) {
    final step = _steps[index];

    return step.phase == GamePhase.clearance &&
        (index == 0 || _steps[index - 1].phase != GamePhase.clearance);
  }
}

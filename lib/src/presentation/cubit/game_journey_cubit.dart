import 'package:bloc/bloc.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/character_trail.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
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
    west: 10.00,
    north: 43.57,
    east: 26.00,
  );

  /// Zoom the camera settles on over a destination. High enough to make
  /// the city the subject, low enough to keep its coastline in frame.
  static const double arrivalZoom = 8.0;

  /// The three parts of a sweep. Coming in is longer than going out on
  /// purpose: going out is travel, coming in is arrival.
  static const Duration sweepOut = Duration(milliseconds: 700);

  /// How long the camera rests at [sweepFrame]. Without this pause the
  /// Mediterranean never registers.
  static const Duration sweepHold = Duration(milliseconds: 150);

  /// How long the camera takes to come in on its destination.
  static const Duration sweepIn = Duration(milliseconds: 900);

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
    for (final beat in script.prologue)
      GameStep(phase: GamePhase.prologue, beat: beat),
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
  static GameJourneyState _stateAt(
    LevelScript script,
    List<GameStep> steps,
    int index, {
    required bool backward,
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
      trails: _trailsThrough(levels, levelIndex),
      camera: _cameraFor(levels, levelIndex, step),
      cameraAnimationDuration: _stepDuration,
    );

    if (backward) {
      return state.withReveal(state.maxReveal);
    }

    // A level opens on a blank map: the sweep owns the screen until the
    // next press acknowledges the arrival.
    return state.withReveal(
      isLevelOpening ? 0 : GameJourneyState.signReveal,
    );
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
      step.levelIndex ??
      (step.phase == GamePhase.prologue ? 0 : levelCount - 1);

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

  /// Every character's route through the levels up to and including
  /// [levelIndex], in the order they first appear, with consecutive stays
  /// in the same city collapsed into one point.
  static List<CharacterTrail> _trailsThrough(
    List<GameLevel> levels,
    int levelIndex,
  ) {
    final characters = <String, GameCharacter>{};
    final paths = <String, List<JourneyStop>>{};
    for (final level in levels.take(levelIndex + 1)) {
      for (final placement in level.placements) {
        for (final character in placement.characters) {
          characters[character.id] ??= character;
          final path = paths.putIfAbsent(character.id, () => <JourneyStop>[]);
          if (path.isEmpty || path.last.id != placement.stop.id) {
            path.add(placement.stop);
          }
        }
      }
    }

    return [
      for (final entry in paths.entries)
        CharacterTrail(
          character: characters[entry.key]!,
          path: List.unmodifiable(entry.value),
        ),
    ];
  }

  /// Where the camera looks for a step.
  ///
  /// Every step of a level answers the same thing, so the camera moves
  /// once per level and then holds while the guide talks and the verses
  /// are read. Reaching a new destination is a sweep; staying in the same
  /// city is not, since a sweep between the two letters to تسالونيكي
  /// would fly out to the whole basin and come back to the identical
  /// view.
  static MapCameraTarget _cameraFor(
    List<GameLevel> levels,
    int levelIndex,
    GameStep step,
  ) {
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
    final previous = levelIndex == 0
        ? null
        : levels[levelIndex - 1].destination;
    if (previous != null && previous.id == destination.id) {
      return arrival;
    }

    return SweepCameraTarget(
      widest: const FitBoundsCameraTarget(
        bounds: sweepFrame,
        padding: EdgeInsets.zero,
      ),
      arrival: arrival,
      outLeg: sweepOut,
      hold: sweepHold,
      inLeg: sweepIn,
    );
  }

  final LevelScript _script;
  final GameSounds _sounds;
  final List<GameStep> _steps;

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
    GameSounds sounds = const SilentGameSounds(),
  }) {
    final script = repository.loadLevelScript();

    return GameJourneyCubit._(script, sounds, _buildSteps(script));
  }

  GameJourneyCubit._(
    LevelScript script,
    GameSounds sounds,
    List<GameStep> steps,
  ) : _script = script,
      _sounds = sounds,
      _steps = steps,
      super(_stateAt(script, steps, 0, backward: false));

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
    final floor = state.isLevelOpening ? 0 : GameJourneyState.signReveal;
    if (state.reveal > floor) {
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
      (step) =>
          step.levelIndex != null &&
          step.levelIndex! < reached &&
          _script.levels[step.levelIndex!].destination.id == stopId,
    );
    if (target >= 0) {
      _goTo(target, backward: false);
    }
  }

  /// Moves to [index], ignoring anything outside the script, and rings
  /// the clearance sound when a level is passed going forwards.
  void _goTo(int index, {required bool backward}) {
    if (index < 0 || index >= _steps.length || index == state.stepIndex) {
      return;
    }
    if (index > state.stepIndex && _isFirstClearanceStep(index)) {
      _sounds.playLevelCleared();
    }
    emit(_stateAt(_script, _steps, index, backward: backward));
  }

  /// Whether [index] is the moment a level is cleared: its first
  /// clearance beat, not the ones that merely follow it.
  bool _isFirstClearanceStep(int index) {
    final step = _steps[index];

    return step.phase == GamePhase.clearance &&
        (index == 0 || _steps[index - 1].phase != GamePhase.clearance);
  }
}

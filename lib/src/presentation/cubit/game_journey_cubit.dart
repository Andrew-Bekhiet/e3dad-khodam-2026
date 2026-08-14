import 'package:bloc/bloc.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_bounds.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
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
final class GameJourneyCubit extends Cubit<GameJourneyState> {
  /// Screen-space inset used while the map is unobstructed.
  static const EdgeInsets _mapPadding = EdgeInsets.only(
    top: 120,
    left: 64,
    right: 64,
    bottom: 104,
  );

  /// Screen-space inset used while a story overlay is up: the dialogue
  /// panel owns the lower part of the screen, so the stops are fitted
  /// into what is left above it.
  static const EdgeInsets _storyPadding = EdgeInsets.only(
    top: 104,
    left: 56,
    right: 56,
    bottom: 300,
  );

  /// Degrees a single stop's zero-area box is padded by on every edge, so
  /// a lone city is framed as a region rather than zoomed to a point.
  static const double _singleStopPadding = 3.0;

  /// Degrees of breathing room around a multi-stop box.
  static const double _routeMargin = 1.0;

  /// One duration for every step: no direction of travel through the
  /// script is more "familiar" than the other.
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
  static GameJourneyState _stateAt(
    LevelScript script,
    List<GameStep> steps,
    int index,
  ) {
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

    return GameJourneyState(
      step: step,
      stepIndex: index,
      stepCount: steps.length,
      level: step.levelIndex == null ? null : levels[levelIndex],
      levelNumber: step.levelIndex == null ? 0 : levelIndex + 1,
      levelCount: levels.length,
      clearedStops: _clearedStops(levels, clearedCount, currentStop),
      currentStop: currentStop,
      nextStop: _nextStop(levels, levelIndex, step),
      trails: _trailsThrough(levels, levelIndex),
      camera: _cameraFor(
        _focusPositions(levels, levelIndex, step),
        step.beat == null ? _mapPadding : _storyPadding,
      ),
      cameraAnimationDuration: _stepDuration,
    );
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
        final id = placement.character.id;
        characters[id] ??= placement.character;
        final path = paths.putIfAbsent(id, () => <JourneyStop>[]);
        if (path.isEmpty || path.last.id != placement.stop.id) {
          path.add(placement.stop);
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

  /// What the camera must contain: the whole route while no level is
  /// showing, otherwise the hop just made — where the journey came from
  /// and where it is now.
  static List<GeoPosition> _focusPositions(
    List<GameLevel> levels,
    int levelIndex,
    GameStep step,
  ) {
    if (step.levelIndex == null) {
      return [for (final level in levels) level.destination.position];
    }
    final current = levels[levelIndex].destination;
    final previous = levelIndex == 0
        ? null
        : levels[levelIndex - 1].destination;

    return [
      current.position,
      if (previous != null && previous.id != current.id) previous.position,
    ];
  }

  static MapCameraTarget _cameraFor(
    List<GeoPosition> positions,
    EdgeInsets padding,
  ) {
    final bounds = GeoBounds.containing(positions);
    final isDegenerate =
        bounds.north == bounds.south || bounds.east == bounds.west;

    return FitBoundsCameraTarget(
      bounds: bounds.padded(
        isDegenerate ? _singleStopPadding : _routeMargin,
      ),
      padding: padding,
    );
  }

  final LevelScript _script;
  final GameSounds _sounds;
  final List<GameStep> _steps;

  /// The character who fronts the guide overlay.
  GameCharacter get guide => _script.guide;

  /// The character credited on the narrator overlay.
  GameCharacter get narrator => _script.narrator;

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
      super(_stateAt(script, steps, 0));

  /// Advances one step: the next line, the next level, or nothing at all
  /// once the epilogue has been reached.
  void forward() {
    _goTo(state.stepIndex + 1);
  }

  /// Steps back one, down to the very first beat.
  void backward() {
    _goTo(state.stepIndex - 1);
  }

  /// Returns to the opening beat.
  void restart() {
    _goTo(0);
  }

  /// Jumps to the playable map of the level whose destination is
  /// [stopId], as long as the journey has already reached it — tapping a
  /// city ahead of the story does nothing.
  void goToStop(String stopId) {
    final reached = switch (state.step.phase) {
      GamePhase.prologue => 0,
      GamePhase.epilogue => state.levelCount,
      _ => state.levelNumber,
    };
    final target = _steps.indexWhere(
      (step) =>
          step.phase == GamePhase.playing &&
          step.levelIndex != null &&
          step.levelIndex! < reached &&
          _script.levels[step.levelIndex!].destination.id == stopId,
    );
    if (target >= 0) {
      _goTo(target);
    }
  }

  /// Moves to [index], ignoring anything outside the script, and rings
  /// the clearance sound when a level is passed going forwards.
  void _goTo(int index) {
    if (index < 0 || index >= _steps.length || index == state.stepIndex) {
      return;
    }
    if (index > state.stepIndex && _isFirstClearanceStep(index)) {
      _sounds.playLevelCleared();
    }
    emit(_stateAt(_script, _steps, index));
  }

  /// Whether [index] is the moment a level is cleared: its first
  /// clearance beat, not the ones that merely follow it.
  bool _isFirstClearanceStep(int index) {
    final step = _steps[index];

    return step.phase == GamePhase.clearance &&
        (index == 0 || _steps[index - 1].phase != GamePhase.clearance);
  }
}

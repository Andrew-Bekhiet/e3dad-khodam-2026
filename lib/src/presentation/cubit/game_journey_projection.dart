import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_camera.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_script.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/step_direction.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/sweep_framing.dart';

/// Projects a Script and transition into the state the map and card draw.
final class GameJourneyProjection {
  const GameJourneyProjection(this._camera);

  final GameJourneyCamera _camera;

  GameTransition transitionTo(
    GameScript script,
    int index, {
    required GameJourneyState? from,
    required StepDirection direction,
  }) {
    final arrival = script.stepAt(index);
    return GameTransition(
      departure: from?.step,
      arrival: arrival,
      direction: direction,
      departureStop: from?.party.destination ?? script.script.home,
      arrivalStop: _stopFor(script, arrival),
      isFirstClearance: script.isFirstClearanceStep(index),
    );
  }

  GameJourneyState stateFor(
    GameScript script,
    int index,
    GameTransition transition, {
    required GameJourneyState? from,
    required SweepFraming framing,
  }) {
    final step = transition.arrival;
    final levels = script.script.levels;
    final mapLevelIndex = _mapLevelIndex(step, levels.length);
    final currentStop = _stopFor(script, step);
    final clearedCount = switch (step) {
      EpilogueStep() => levels.length,
      ClearanceStep(:final levelIndex) => levelIndex + 1,
      OpeningStep() || PrologueStep() => 0,
      BriefingStep(:final levelIndex) => levelIndex,
      PlayingStep(:final levelIndex) => levelIndex,
    };
    final level = switch (step) {
      LevelStep(:final levelIndex) => levels[levelIndex],
      OpeningStep() || PrologueStep() || EpilogueStep() => null,
    };
    final state = GameJourneyState(
      step: step,
      stepIndex: index,
      stepCount: script.steps.length,
      level: level ?? (step is PrologueStep ? levels.first : null),
      levelNumber: switch (step) {
        LevelStep(:final levelIndex) => levelIndex + 1,
        OpeningStep() || EpilogueStep() => 0,
        PrologueStep() => 1,
      },
      levelCount: levels.length,
      isLevelOpening: _isLevelOpening(script, index, transition),
      clearedStops: _clearedStops(levels, clearedCount, currentStop),
      currentStop: currentStop,
      nextStop: _nextStop(levels, mapLevelIndex, step),
      party: _partyThrough(script, mapLevelIndex, step),
      camera: _camera.targetFor(
        script.script,
        transition,
        previous: from?.camera,
        framing: framing,
      ),
      cameraAnimationDuration: GameJourneyCamera.stepDuration,
      carriedVerses: _carriedVerses(levels, step),
    );
    if (transition.direction == StepDirection.backward ||
        step is ClearanceStep) {
      return state.withReveal(state.maxReveal);
    }

    return state.withReveal(state.minReveal);
  }

  int _mapLevelIndex(GameStep step, int levelCount) => switch (step) {
    OpeningStep() || PrologueStep() => 0,
    LevelStep(:final levelIndex) => levelIndex,
    EpilogueStep() => levelCount - 1,
  };

  bool _isLevelOpening(
    GameScript script,
    int index,
    GameTransition transition,
  ) => switch (transition.arrival) {
    PrologueStep() => script.isLevelOpening(index),
    LevelStep(:final levelIndex) => switch (transition.departure) {
      PrologueStep() when levelIndex == 0 => false,
      LevelStep(levelIndex: final departureLevelIndex)
          when levelIndex == departureLevelIndex =>
        false,
      OpeningStep() ||
      PrologueStep() ||
      LevelStep() ||
      EpilogueStep() ||
      null => true,
    },
    OpeningStep() || EpilogueStep() => false,
  };

  JourneyStop? _stopFor(GameScript script, GameStep step) => switch (step) {
    OpeningStep() => script.script.levels.first.destination,
    PrologueStep() => script.script.levels.first.destination,
    LevelStep(:final levelIndex) =>
      script.script.levels[levelIndex].destination,
    EpilogueStep() => null,
  };

  List<String> _carriedVerses(List<GameLevel> levels, GameStep step) =>
      switch (step) {
        LevelStep(:final levelIndex) => [
          for (final level in levels.take(levelIndex))
            if (level.destination.id == levels[levelIndex].destination.id)
              ...level.verses,
        ],
        OpeningStep() || PrologueStep() || EpilogueStep() => const [],
      };

  List<JourneyStop> _clearedStops(
    List<GameLevel> levels,
    int clearedCount,
    JourneyStop? currentStop,
  ) {
    final byId = <String, JourneyStop>{
      for (final level in levels.take(clearedCount))
        level.destination.id: level.destination,
    };
    byId.remove(currentStop?.id);
    return byId.values.toList(growable: false);
  }

  JourneyStop? _nextStop(
    List<GameLevel> levels,
    int levelIndex,
    GameStep step,
  ) => switch (step) {
    EpilogueStep() => null,
    OpeningStep() || PrologueStep() || LevelStep() =>
      levelIndex + 1 < levels.length
          ? levels[levelIndex + 1].destination
          : null,
  };

  CourierParty _partyThrough(
    GameScript script,
    int levelIndex,
    GameStep step,
  ) {
    final stops = <JourneyStop>[script.script.home];
    if (step is! OpeningStep) {
      for (final level in script.script.levels.take(levelIndex + 1)) {
        if (stops.last.id != level.destination.id) {
          stops.add(level.destination);
        }
      }
    }
    return CourierParty(
      couriers: script.script.couriers,
      stops: List.unmodifiable(stops),
    );
  }
}

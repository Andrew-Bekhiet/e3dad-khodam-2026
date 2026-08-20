import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_camera.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_script.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/reveal.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/step_direction.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/sweep_framing.dart';

/// Projects a Script and transition into the state the map and card draw.
final class GameJourneyProjection {
  final GameJourneyCamera _camera;

  const GameJourneyProjection(this._camera);

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
    final clearedCount = _clearedCount(step, levels.length);
    final level = _levelFor(step, levels);
    final state = GameJourneyState(
      step: step,
      stepIndex: index,
      stepCount: script.steps.length,
      level: level ?? (step is PrologueStep ? levels.first : null),
      levelNumber: _levelNumber(step),
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
      return state.copyWith(
        reveal: Reveal.ceilingFor(
          step: step,
          verseCount: level?.verses.length ?? 0,
        ),
      );
    }

    return state.copyWith(
      reveal: Reveal.floorFor(step: step, opensBlank: state.opensBlank),
    );
  }

  int _mapLevelIndex(GameStep step, int levelCount) => switch (step) {
    OpeningStep() || PrologueStep() => 0,
    LevelStep(:final levelIndex) => levelIndex,
    EpilogueStep() => levelCount - 1,
  };

  int _clearedCount(GameStep step, int levelCount) => switch (step) {
    EpilogueStep() => levelCount,
    ClearanceStep(:final levelIndex) => levelIndex + 1,
    OpeningStep() || PrologueStep() => 0,
    BriefingStep(:final levelIndex) || PlayingStep(:final levelIndex) =>
      levelIndex,
  };

  GameLevel? _levelFor(GameStep step, List<GameLevel> levels) => switch (step) {
    LevelStep(:final levelIndex) => levels[levelIndex],
    OpeningStep() || PrologueStep() || EpilogueStep() => null,
  };

  int _levelNumber(GameStep step) => switch (step) {
    LevelStep(:final levelIndex) => levelIndex + 1,
    OpeningStep() || EpilogueStep() => 0,
    PrologueStep() => 1,
  };

  bool _isLevelOpening(
    GameScript script,
    int index,
    GameTransition transition,
  ) {
    final arrival = transition.arrival;
    if (arrival is PrologueStep) {
      return script.isLevelOpening(index);
    }
    if (arrival is! LevelStep) {
      return false;
    }

    return _levelStepOpens(arrival, transition.departure);
  }

  bool _levelStepOpens(LevelStep arrival, GameStep? departure) {
    if (departure is PrologueStep && arrival.levelIndex == 0) {
      return false;
    }
    if (departure is LevelStep && departure.levelIndex == arrival.levelIndex) {
      return false;
    }

    return true;
  }

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

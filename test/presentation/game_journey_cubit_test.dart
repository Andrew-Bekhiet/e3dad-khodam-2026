import 'package:e3dad_khodam_2026/src/data/game/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:flutter_test/flutter_test.dart';

// The script is a compile-time constant, so a real repository exercises
// exactly the script the app ships — mocking it would only add
// indirection, not isolation.
const _repository = StaticLevelScriptRepository();

/// Counts clearance stings instead of playing them.
final class _CountingSounds implements GameSounds {
  int cleared = 0;

  @override
  void playLevelCleared() {
    cleared++;
  }
}

/// Steps [cubit] forward until [test] holds, giving up after enough
/// steps to cross the whole script so a wrong predicate fails loudly
/// rather than hanging.
void _advanceUntil(GameJourneyCubit cubit, bool Function() test) {
  for (var step = 0; step < cubit.state.stepCount && !test(); step++) {
    cubit.forward();
  }
  expect(test(), isTrue, reason: 'never reached the expected step');
}

void main() {
  _startAndStepTests();
  _mapContentTests();
  _clearanceAndJumpTests();
}

void _startAndStepTests() {
  test('GameJourneyCubit_construction_startsOnThePrologue', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    expect(cubit.state.stepIndex, 0);
    expect(cubit.state.step.phase, GamePhase.prologue);
    expect(cubit.state.level, isNull);
    expect(cubit.state.beat, isNotNull);
    expect(cubit.state.isAtStart, isTrue);
    expect(cubit.state.camera, isA<FitBoundsCameraTarget>());
  });

  test('GameJourneyCubit_backwardAtStart_staysPut', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    cubit.backward();

    expect(cubit.state.stepIndex, 0);
  });

  test('GameJourneyCubit_forwardThenBackward_returnsToTheSameStep', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);
    final first = cubit.state;

    cubit
      ..forward()
      ..backward();

    expect(cubit.state, equals(first));
  });

  test('GameJourneyCubit_walkingTheWholeScript_endsOnTheEpilogue', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    for (var step = 0; step < cubit.state.stepCount; step++) {
      cubit.forward();
    }

    expect(cubit.state.isAtEnd, isTrue);
    expect(cubit.state.step.phase, GamePhase.epilogue);
    expect(cubit.state.currentStop, isNull);
    expect(cubit.state.progress, 1.0);
    // Every letter delivered: fourteen levels, nine distinct cities.
    expect(cubit.state.clearedStops.length, 9);
  });
}

void _mapContentTests() {
  test('GameJourneyCubit_firstLevel_putsTheCourierOnItsDestination', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _advanceUntil(cubit, () => cubit.state.levelNumber == 1);

    expect(cubit.state.currentStop, JourneyStops.thessalonica);
    expect(cubit.state.clearedStops, isEmpty);
    expect(cubit.state.trails, hasLength(1));
    expect(cubit.state.trails.single.position, JourneyStops.thessalonica);
    expect(cubit.state.trails.single.path, [JourneyStops.thessalonica]);
    // The city after this one is previewed, but no further.
    expect(cubit.state.nextStop, JourneyStops.thessalonica);
  });

  test('GameJourneyCubit_secondLevelInTheSameCity_doesNotRepeatTheStop', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _advanceUntil(cubit, () => cubit.state.levelNumber == 2);

    // Both Thessalonian letters are delivered to one city, so the trail
    // is still a single point and the city is not drawn twice.
    expect(cubit.state.trails.single.path, [JourneyStops.thessalonica]);
    expect(cubit.state.clearedStops, isEmpty);
    expect(cubit.state.currentStop, JourneyStops.thessalonica);
  });

  test('GameJourneyCubit_thirdLevel_extendsTheTrailToCorinth', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _advanceUntil(cubit, () => cubit.state.levelNumber == 3);

    expect(cubit.state.currentStop, JourneyStops.corinth);
    expect(cubit.state.trails.single.path, [
      JourneyStops.thessalonica,
      JourneyStops.corinth,
    ]);
    expect(cubit.state.clearedStops, [JourneyStops.thessalonica]);
  });
}

void _clearanceAndJumpTests() {
  test('GameJourneyCubit_clearingALevel_ringsTheClearanceSoundOnce', () {
    final sounds = _CountingSounds();
    final cubit = GameJourneyCubit(_repository, sounds: sounds);
    addTearDown(cubit.close);

    _advanceUntil(cubit, () => cubit.state.step.phase == GamePhase.clearance);

    expect(sounds.cleared, 1);
  });

  test('GameJourneyCubit_steppingBackOverAClearance_doesNotRingAgain', () {
    final sounds = _CountingSounds();
    final cubit = GameJourneyCubit(_repository, sounds: sounds);
    addTearDown(cubit.close);

    _advanceUntil(cubit, () => cubit.state.step.phase == GamePhase.clearance);
    cubit
      ..backward()
      ..backward();

    expect(sounds.cleared, 1);
  });

  test('GameJourneyCubit_goToStop_onlyJumpsToCitiesAlreadyReached', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _advanceUntil(cubit, () => cubit.state.levelNumber == 3);
    final atCorinth = cubit.state.stepIndex;

    // Rome comes much later in the script: still locked.
    cubit.goToStop(JourneyStops.rome.id);
    expect(cubit.state.stepIndex, atCorinth);

    // Thessalonica has been delivered to, so it is revisitable.
    cubit.goToStop(JourneyStops.thessalonica.id);
    expect(cubit.state.step.phase, GamePhase.playing);
    expect(cubit.state.currentStop, JourneyStops.thessalonica);
  });

  test('GameJourneyCubit_restart_returnsToTheOpeningBeat', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _advanceUntil(cubit, () => cubit.state.levelNumber == 4);
    cubit.restart();

    expect(cubit.state.stepIndex, 0);
    expect(cubit.state.step.phase, GamePhase.prologue);
  });
}

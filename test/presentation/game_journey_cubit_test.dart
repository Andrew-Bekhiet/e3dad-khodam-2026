import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
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

/// Presses forward until [test] holds, giving up after enough presses to
/// cross the whole script so a wrong predicate fails loudly rather than
/// hanging.
///
/// A press is not a step: most steps also open part of the destination
/// card, so crossing the script takes several presses per step.
void _pressUntil(GameJourneyCubit cubit, bool Function() test) {
  final limit = cubit.state.stepCount * 20;
  for (var press = 0; press < limit && !test(); press++) {
    cubit.forward();
  }
  expect(test(), isTrue, reason: 'never reached the expected step');
}

/// Presses forward until the given level's map is being played, with its
/// card open as far as the sign.
void _pressToLevel(GameJourneyCubit cubit, int levelNumber) {
  _pressUntil(
    cubit,
    () => cubit.state.levelNumber == levelNumber && cubit.state.isPlaying,
  );
}

void main() {
  _startAndStepTests();
  _mapContentTests();
  _sweepTests();
  _revealTests();
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

    final before = cubit.state.stepIndex;
    cubit
      ..forward()
      ..backward();

    expect(cubit.state.stepIndex, before);
  });

  test('GameJourneyCubit_pressingThroughTheWholeScript_endsOnTheLastLevel', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.isAtEnd);

    // The play writes no closing narration, so the last step is the
    // fourteenth letter itself.
    expect(cubit.state.levelNumber, 14);
    expect(cubit.state.currentStop, JourneyStops.ephesus);
    // The eight other cities already delivered to; أفسس is the current
    // stop, so it is drawn highlighted rather than cleared.
    expect(cubit.state.clearedStops.length, 8);
  });
}

void _mapContentTests() {
  test('GameJourneyCubit_firstLevel_putsBothCouriersOnItsDestination', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 1);

    expect(cubit.state.currentStop, JourneyStops.thessalonica);
    expect(cubit.state.clearedStops, isEmpty);
    // The two postmen travel together: one trail each, same route.
    expect(cubit.state.trails, hasLength(2));
    expect(
      cubit.state.trails.map((trail) => trail.character.id),
      ['courier1', 'courier2'],
    );
    for (final trail in cubit.state.trails) {
      expect(trail.path, [JourneyStops.thessalonica]);
      expect(trail.position, JourneyStops.thessalonica);
    }
    // The city after this one is previewed, but no further.
    expect(cubit.state.nextStop, JourneyStops.thessalonica);
  });

  test('GameJourneyCubit_secondLevelInTheSameCity_doesNotRepeatTheStop', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 2);

    // Both Thessalonian letters are delivered to one city, so the trail
    // is still a single point and the city is not drawn twice.
    expect(cubit.state.trails.first.path, [JourneyStops.thessalonica]);
    expect(cubit.state.clearedStops, isEmpty);
    expect(cubit.state.currentStop, JourneyStops.thessalonica);
  });

  test('GameJourneyCubit_thirdLevel_extendsTheTrailToCorinth', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 3);

    expect(cubit.state.currentStop, JourneyStops.corinth);
    for (final trail in cubit.state.trails) {
      expect(trail.path, [JourneyStops.thessalonica, JourneyStops.corinth]);
    }
    expect(cubit.state.clearedStops, [JourneyStops.thessalonica]);
  });
}

void _sweepTests() {
  test('GameJourneyCubit_reachingANewCity_sweepsOntoIt', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 3);
    final sweep = cubit.state.sweep;

    expect(sweep, isNotNull);
    expect(sweep!.widest.bounds, GameJourneyCubit.sweepFrame);
    expect(sweep.arrival.center, JourneyStops.corinth.position);
    expect(sweep.arrival.zoom, GameJourneyCubit.arrivalZoom);
    // Coming in is the part worth watching, so it takes longer.
    expect(sweep.inLeg, greaterThan(sweep.outLeg));
  });

  test('GameJourneyCubit_theFirstLevel_sweepsOntoItToo', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 1);

    expect(cubit.state.sweep, isNotNull);
  });

  test('GameJourneyCubit_anotherLetterToTheSameCity_doesNotSweep', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    // Levels ١ and ٢ are both تسالونيكي: a sweep would fly out to the
    // whole basin and come back to the identical view.
    _pressUntil(cubit, () => cubit.state.levelNumber == 2);

    expect(cubit.state.sweep, isNull);
    expect(
      cubit.state.camera,
      CenterZoomCameraTarget(
        center: JourneyStops.thessalonica.position,
        zoom: GameJourneyCubit.arrivalZoom,
      ),
    );
  });

  test('GameJourneyCubit_stepsWithinALevel_leaveTheCameraAlone', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 3);
    final camera = cubit.state.camera;
    final level = cubit.state.levelNumber;

    _pressUntil(
      cubit,
      () => cubit.state.levelNumber != level || cubit.state.isPlaying,
    );

    expect(cubit.state.levelNumber, level);
    expect(cubit.state.camera, camera);
  });

  test('GameJourneyCubit_steppingBackIntoAnEarlierCity_sweepsAgain', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 3);
    while (cubit.state.levelNumber == 3) {
      cubit.backward();
    }

    expect(cubit.state.levelNumber, 2);
    // Going back is travel too, so the way back is swept the same way.
    expect(cubit.state.camera, isNotNull);
    expect(cubit.state.currentStop, JourneyStops.thessalonica);
  });

  test('GameJourneyCubit_thePrologue_framesTheWholeJourney', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    expect(cubit.state.camera, isA<FitBoundsCameraTarget>());
    expect(cubit.state.sweep, isNull);
  });
}

void _revealTests() {
  test('GameJourneyCubit_arrivingAtALevel_showsNothingOverTheMap', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 1);

    // The sweep owns the screen: no card, and nobody speaks over it.
    expect(cubit.state.isArriving, isTrue);
    expect(cubit.state.showsSign, isFalse);
    expect(cubit.state.beat, isNull);
  });

  test('GameJourneyCubit_theFirstPressAfterArriving_raisesTheSign', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 1);
    final step = cubit.state.stepIndex;
    cubit.forward();

    // One press lands the level: the sign appears and the guide starts,
    // without moving on to another step.
    expect(cubit.state.stepIndex, step);
    expect(cubit.state.isArriving, isFalse);
    expect(cubit.state.showsSign, isTrue);
    expect(cubit.state.showsImage, isFalse);
    expect(cubit.state.beat, isNotNull);
  });

  test('GameJourneyCubit_theCard_opensSignThenImageThenVerses', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressToLevel(cubit, 1);
    final verses = cubit.state.level!.verses;

    // The playing step starts with the sign already up.
    expect(cubit.state.showsSign, isTrue);
    expect(cubit.state.showsImage, isFalse);
    expect(cubit.state.revealedVerses, isEmpty);

    cubit.forward();
    expect(cubit.state.showsImage, isTrue);
    expect(cubit.state.revealedVerses, isEmpty);

    cubit.forward();
    expect(cubit.state.revealedVerses, [verses.first]);

    for (var shown = 1; shown < verses.length; shown++) {
      cubit.forward();
    }
    expect(cubit.state.revealedVerses, verses);
    expect(cubit.state.hasMoreReveal, isFalse);
  });

  test('GameJourneyCubit_pressingPastTheLastVerse_movesToTheNextStep', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressToLevel(cubit, 1);
    final step = cubit.state.stepIndex;
    _pressUntil(cubit, () => !cubit.state.hasMoreReveal);

    expect(cubit.state.stepIndex, step);

    cubit.forward();
    expect(cubit.state.stepIndex, greaterThan(step));
  });

  test('GameJourneyCubit_backward_closesTheCardOnePartAtATime', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressToLevel(cubit, 1);
    final step = cubit.state.stepIndex;
    cubit
      ..forward()
      ..forward()
      ..forward();
    expect(cubit.state.revealedVerses, hasLength(2));

    cubit.backward();
    expect(cubit.state.revealedVerses, hasLength(1));
    expect(cubit.state.stepIndex, step);

    cubit
      ..backward()
      ..backward();
    expect(cubit.state.showsImage, isFalse);
    expect(cubit.state.showsSign, isTrue);
    expect(cubit.state.stepIndex, step);
  });

  test('GameJourneyCubit_steppingBackIntoAStep_findsItFullyOpen', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressToLevel(cubit, 1);
    final verses = cubit.state.level!.verses;
    _pressUntil(cubit, () => !cubit.state.isPlaying);

    // Returning to a step already seen should not make the operator
    // press through every verse again to reach the line they were on.
    cubit.backward();

    expect(cubit.state.isPlaying, isTrue);
    expect(cubit.state.revealedVerses, verses);
  });

  test('GameJourneyCubit_aClearedLevel_keepsItsSignUp', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.step.phase == GamePhase.clearance);

    // Still the same level, so the sign must not blink out and back.
    // The artwork and verses do close; only the name and year stay.
    expect(cubit.state.showsSign, isTrue);
    expect(cubit.state.showsImage, isFalse);
    expect(cubit.state.revealedVerses, isEmpty);
  });

  test('GameJourneyCubit_anotherLetterToTheSameCity_keepsTheSignUp', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    // Levels ١ and ٢ are both تسالونيكي, so no sweep runs between them.
    // With nothing flying, a blank screen would hide nothing and only
    // flicker a sign that is about to say the same words again.
    _pressUntil(cubit, () => cubit.state.levelNumber == 2);

    expect(cubit.state.isLevelOpening, isTrue);
    expect(cubit.state.isArriving, isFalse);
    expect(cubit.state.showsSign, isTrue);
  });

  test('GameJourneyCubit_aSweptIntoLevel_startsBlank', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    // كورنثوس is a new city, so the camera flies and the screen clears.
    _pressUntil(cubit, () => cubit.state.levelNumber == 3);

    expect(cubit.state.sweep, isNotNull);
    expect(cubit.state.isArriving, isTrue);
    expect(cubit.state.showsSign, isFalse);
  });

  test('GameJourneyCubit_revealNext_doesNothingDuringDialogue', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    // The opening beat: a line is showing, so there is no card to open.
    expect(cubit.state.isPlaying, isFalse);
    cubit.revealNext();

    expect(cubit.state.revealedVerses, isEmpty);
    expect(cubit.state.showsSign, isFalse);
  });

  test('GameJourneyCubit_everyLevel_carriesItsYear', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    for (var level = 1; level <= cubit.state.levelCount; level++) {
      _pressUntil(cubit, () => cubit.state.levelNumber == level);
      expect(
        cubit.state.level!.year,
        isNotNull,
        reason: 'level $level has no year',
      );
    }
  });
}

void _clearanceAndJumpTests() {
  test('GameJourneyCubit_clearingALevel_ringsTheClearanceSoundOnce', () {
    final sounds = _CountingSounds();
    final cubit = GameJourneyCubit(_repository, sounds: sounds);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.step.phase == GamePhase.clearance);

    expect(sounds.cleared, 1);
  });

  test('GameJourneyCubit_steppingBackOverAClearance_doesNotRingAgain', () {
    final sounds = _CountingSounds();
    final cubit = GameJourneyCubit(_repository, sounds: sounds);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.step.phase == GamePhase.clearance);
    cubit
      ..backward()
      ..backward();

    expect(sounds.cleared, 1);
  });

  test('GameJourneyCubit_goToStop_onlyJumpsToCitiesAlreadyReached', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 3);
    final atCorinth = cubit.state.stepIndex;

    // Rome comes much later in the script: still locked.
    cubit.goToStop(JourneyStops.rome.id);
    expect(cubit.state.stepIndex, atCorinth);

    // Thessalonica has been delivered to, so it is revisitable.
    cubit.goToStop(JourneyStops.thessalonica.id);
    expect(cubit.state.currentStop, JourneyStops.thessalonica);
  });

  test('GameJourneyCubit_goToStop_arrivesTheWayTheStoryDoes', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 3);
    cubit.goToStop(JourneyStops.thessalonica.id);

    // Tapping a city is a journey to it, so it lands on the level's
    // first step and sweeps, rather than dropping onto its map.
    expect(cubit.state.isLevelOpening, isTrue);
    expect(cubit.state.isArriving, isTrue);
    expect(cubit.state.sweep, isNotNull);
  });

  test('GameJourneyCubit_restart_returnsToTheOpeningBeat', () {
    final cubit = GameJourneyCubit(_repository);
    addTearDown(cubit.close);

    _pressUntil(cubit, () => cubit.state.levelNumber == 4);
    cubit.restart();

    expect(cubit.state.stepIndex, 0);
    expect(cubit.state.step.phase, GamePhase.prologue);
  });
}

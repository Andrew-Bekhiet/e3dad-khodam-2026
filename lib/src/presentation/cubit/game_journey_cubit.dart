import 'package:bloc/bloc.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_cue.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_camera.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_projection.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_script.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/reveal.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/step_direction.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/sweep_framing.dart';

/// Walks the guided playthrough one step at a time.
final class GameJourneyCubit extends Cubit<GameJourneyState> {
  factory GameJourneyCubit(
    LevelScriptRepository repository, {
    required GameSounds sounds,
    SweepFraming framing = SweepFraming.basin,
  }) {
    final script = GameScript(repository.loadLevelScript());
    return GameJourneyCubit._(
      script,
      sounds,
      const GameJourneyProjection(GameJourneyCamera()),
      const GameCueSheet(),
      framing,
    );
  }
  GameJourneyCubit._(
    this._script,
    this._sounds,
    this._projection,
    this._cueSheet,
    SweepFraming framing,
  ) : sweepFraming = framing,
      super(
        _projection.stateFor(
          _script,
          0,
          _projection.transitionTo(
            _script,
            0,
            from: null,
            direction: StepDirection.forward,
          ),
          from: null,
          framing: framing,
        ),
      );

  final GameScript _script;
  final GameSounds _sounds;
  final GameJourneyProjection _projection;
  final GameCueSheet _cueSheet;

  SweepFraming sweepFraming;

  GameCharacter get guide => _script.script.guide;
  GameCharacter get narrator => _script.script.narrator;
  GameCharacter get letterWriter => _script.script.letterWriter;

  void forward() {
    final verseCount = state.level?.verses.length ?? 0;
    if (state.reveal.hasNext(step: state.step, verseCount: verseCount)) {
      emit(
        state.copyWith(
          reveal: state.reveal.next(
            step: state.step,
            verseCount: verseCount,
          ),
        ),
      );
      return;
    }
    _goTo(state.stepIndex + 1, StepDirection.forward);
  }

  void backward() {
    final floor = Reveal.floorFor(
      step: state.step,
      opensBlank: state.opensBlank,
    );
    if (state.reveal != floor) {
      emit(state.copyWith(reveal: state.reveal.previous(floor: floor)));
      return;
    }
    _goTo(state.stepIndex - 1, StepDirection.backward);
  }

  void restart() => _goTo(0, StepDirection.forward);

  void revealNext() {
    final verseCount = state.level?.verses.length ?? 0;
    if (state.reveal.hasNext(step: state.step, verseCount: verseCount)) {
      emit(
        state.copyWith(
          reveal: state.reveal.next(
            step: state.step,
            verseCount: verseCount,
          ),
        ),
      );
    }
  }

  void revealPrevious() {
    if (state.reveal is! CardHidden) {
      emit(
        state.copyWith(
          reveal: state.reveal.previous(floor: const CardHidden()),
        ),
      );
    }
  }

  void goToStop(String stopId) {
    final reachedLevelCount = switch (state.step) {
      PrologueStep() => 0,
      EpilogueStep() => state.levelCount,
      OpeningStep() || LevelStep() => state.levelNumber,
    };
    final target = _script.firstStepForStop(
      stopId,
      reachedLevelCount: reachedLevelCount,
    );
    if (target != null) {
      _goTo(target, StepDirection.forward);
    }
  }

  void _goTo(int index, StepDirection direction) {
    if (index < 0 ||
        index >= _script.steps.length ||
        index == state.stepIndex) {
      return;
    }
    final transition = _projection.transitionTo(
      _script,
      index,
      from: state,
      direction: direction,
    );
    switch (_cueSheet.cueFor(transition)) {
      case GameCue.levelCleared:
        _sounds.playLevelCleared();
      case null:
        break;
    }
    emit(
      _projection.stateFor(
        _script,
        index,
        transition,
        from: state,
        framing: sweepFraming,
      ),
    );
  }
}

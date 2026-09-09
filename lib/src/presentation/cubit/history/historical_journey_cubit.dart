import 'package:bloc/bloc.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_camera.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/journey_trace.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/step_direction.dart';

/// Walks a historical journey one step at a time: the opening shot, then
/// each of its rests in order.
final class HistoricalJourneyCubit extends Cubit<HistoricalJourneyState> {
  static const _projection = HistoricalJourneyProjection(
    HistoricalJourneyCamera(),
  );

  final HistoricalJourney _journey;

  /// Creates a cubit over a journey. One cubit per journey: the caller
  /// picks which of the three to play.
  HistoricalJourneyCubit(this._journey)
    : super(
        _projection.stateFor(
          _journey,
          0,
          from: null,
          direction: StepDirection.forward,
        ),
      );

  /// Walks to the next rest, or does nothing on the last step.
  void forward() => _goTo(state.stepIndex + 1, StepDirection.forward);

  /// Steps back one rest, or does nothing on the first step.
  void backward() => _goTo(state.stepIndex - 1, StepDirection.backward);

  /// Returns to the opening step.
  void restart() => _goTo(0, StepDirection.forward);

  void _goTo(int index, StepDirection direction) {
    if (index < 0 || index >= state.stepCount || index == state.stepIndex) {
      return;
    }
    emit(
      _projection.stateFor(
        _journey,
        index,
        from: state,
        direction: direction,
      ),
    );
  }
}

/// Turns a journey, a step index and a direction into the state the map
/// draws.
///
/// Kept separate from [HistoricalJourneyCubit] for the reason ADR 0006
/// gives the game's split: the cubit stays a synchronous walk over an
/// index, while everything that needs to reckon with camera framing lives
/// here. Folded into one method rather than the game's `transitionTo` /
/// `stateFor` pair, since there is no cue sheet here needing the
/// in-between transition value.
final class HistoricalJourneyProjection {
  final HistoricalJourneyCamera _camera;

  const HistoricalJourneyProjection(this._camera);

  /// The state for arriving at step [index] of [journey], having come
  /// from [from] by [direction].
  HistoricalJourneyState stateFor(
    HistoricalJourney journey,
    int index, {
    required HistoricalJourneyState? from,
    required StepDirection direction,
  }) {
    final step = _stepAt(index);
    final visitedRests = _visitedRestsFor(journey, step);
    final currentRest = _currentRestFor(journey, step);

    return HistoricalJourneyState(
      position: (
        step: step,
        stepIndex: index,
        stepCount: stepCount(journey),
      ),
      map: (
        origin: journey.origin,
        visitedRests: visitedRests,
        currentStop: currentRest?.stop ?? journey.origin,
        beacon: currentRest?.beacon,
        revealedVia: _revealedVia(visitedRests, currentRest),
        trace: JourneyTrace(
          origin: journey.origin,
          visitedRests: visitedRests,
          currentRest: currentRest,
        ),
        camera: _camera.targetFor(
          journey,
          arrival: step,
          departure: from?.step,
          direction: direction,
        ),
        cameraAnimationDuration: HistoricalJourneyCamera.stepDuration,
      ),
    );
  }

  /// How many steps [journey] has: the opening shot, plus one per rest.
  int stepCount(HistoricalJourney journey) => 1 + journey.rests.length;

  HistoricalStep _stepAt(int index) =>
      index == 0 ? const JourneyOpeningStep() : RestStep(index - 1);

  List<JourneyRest> _visitedRestsFor(
    HistoricalJourney journey,
    HistoricalStep step,
  ) => switch (step) {
    JourneyOpeningStep() => const [],
    RestStep(:final restIndex) => journey.rests.sublist(0, restIndex),
  };

  JourneyRest? _currentRestFor(
    HistoricalJourney journey,
    HistoricalStep step,
  ) => switch (step) {
    JourneyOpeningStep() => null,
    RestStep(:final restIndex) => journey.rests[restIndex],
  };

  List<JourneyStop> _revealedVia(
    List<JourneyRest> visitedRests,
    JourneyRest? currentRest,
  ) => [
    for (final rest in visitedRests) ...rest.via,
    if (currentRest != null) ...currentRest.via,
  ];
}

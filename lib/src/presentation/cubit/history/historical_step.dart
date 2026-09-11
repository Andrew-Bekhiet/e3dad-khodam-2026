import 'package:equatable/equatable.dart';

/// One position in the flat list of steps a historical journey walks
/// through: the opening shot, or an arrival at one of its rests.
sealed class HistoricalStep extends Equatable {
  const HistoricalStep();
}

/// Parked at the origin, with the whole journey framed.
final class JourneyOpeningStep extends HistoricalStep {
  @override
  List<Object?> get props => const [];

  const JourneyOpeningStep();
}

/// Arrived at `journey.rests[restIndex]`, [phase] presses in: phase 0 is
/// the arrival, each later phase lights the rest's next beacon.
final class RestStep extends HistoricalStep {
  final int restIndex;
  final int phase;

  @override
  List<Object?> get props => [restIndex, phase];

  const RestStep(this.restIndex, [this.phase = 0]);
}

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

/// Arrived at `journey.rests[restIndex]`.
final class RestStep extends HistoricalStep {
  final int restIndex;

  @override
  List<Object?> get props => [restIndex];

  const RestStep(this.restIndex);
}

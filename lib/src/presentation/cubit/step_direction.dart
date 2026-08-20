import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';

enum StepDirection { forward, backward }

/// One move through the journey and the stops it travels between.
final class GameTransition {
  const GameTransition({
    required this.departure,
    required this.arrival,
    required this.direction,
    required this.departureStop,
    required this.arrivalStop,
    required this.isFirstClearance,
  });

  final GameStep? departure;
  final GameStep arrival;
  final StepDirection direction;
  final JourneyStop departureStop;
  final JourneyStop? arrivalStop;
  final bool isFirstClearance;
}

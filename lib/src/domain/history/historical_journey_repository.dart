import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';

/// Source of the three historical journeys. Synchronous for the same
/// reason `LevelScriptRepository` is: the journeys are a compile-time
/// constant, not a network or disk resource.
abstract interface class HistoricalJourneyRepository {
  /// Loads all three journeys.
  List<HistoricalJourney> loadHistoricalJourneys();
}

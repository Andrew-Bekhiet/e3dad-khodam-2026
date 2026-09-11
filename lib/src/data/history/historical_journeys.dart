import 'package:e3dad_khodam_2026/src/data/history/historical_stops.dart';
import 'package:e3dad_khodam_2026/src/data/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey_repository.dart';

/// The three historical journeys the map can play: بولس's 2nd and 3rd
/// journeys, and his voyage to رومية.
final class HistoricalJourneys {
  /// أنطاكية to كورنثوس, sending a letter back to تسالونيكي along the
  /// way.
  static const HistoricalJourney secondJourney = HistoricalJourney(
    id: 'secondJourney',
    title: 'رحلة بولس الرسول الثانية',
    origin: HistoricalStops.antioch,
    rests: [
      JourneyRest(
        stop: JourneyStops.corinth,
        via: [
          HistoricalStops.tarsus,
          HistoricalStops.derbe,
          HistoricalStops.lystra,
          HistoricalStops.iconium,
          HistoricalStops.pisidianAntioch,
          HistoricalStops.troas,
          HistoricalStops.samothrace,
          HistoricalStops.neapolis,
          HistoricalStops.philippi,
          HistoricalStops.amphipolis,
          HistoricalStops.apollonia,
          JourneyStops.thessalonica,
          HistoricalStops.berea,
          HistoricalStops.athens,
        ],
        beacons: [JourneyStops.thessalonica],
      ),
    ],
  );

  /// أنطاكية to أفسس, sending letters to غلاطية and كورنثوس from there,
  /// then on to كورنثوس, sending a letter to رومية.
  static const HistoricalJourney thirdJourney = HistoricalJourney(
    id: 'thirdJourney',
    title: 'رحلة بولس الرسول الثالثة',
    origin: HistoricalStops.antioch,
    rests: [
      JourneyRest(
        stop: JourneyStops.ephesus,
        via: [
          HistoricalStops.tarsus,
          HistoricalStops.derbe,
          HistoricalStops.lystra,
          HistoricalStops.iconium,
          HistoricalStops.pisidianAntioch,
        ],
        beacons: [JourneyStops.galatia, JourneyStops.corinth],
      ),
      JourneyRest(
        stop: JourneyStops.corinth,
        via: [
          HistoricalStops.troas,
          HistoricalStops.neapolis,
          HistoricalStops.philippi,
          HistoricalStops.amphipolis,
          HistoricalStops.apollonia,
          JourneyStops.thessalonica,
          HistoricalStops.berea,
          HistoricalStops.athens,
        ],
        beacons: [JourneyStops.rome],
        arrivesDark: true,
      ),
    ],
  );

  /// قيصرية to رومية: one continuous voyage, with no intermediate rest.
  static const HistoricalJourney romeJourney = HistoricalJourney(
    id: 'romeJourney',
    title: 'رحلة بولس الرسول إلى رومية',
    origin: HistoricalStops.caesarea,
    rests: [
      JourneyRest(
        stop: JourneyStops.rome,
        via: [
          HistoricalStops.sidon,
          HistoricalStops.myra,
          HistoricalStops.cnidus,
          HistoricalStops.fairHavens,
          HistoricalStops.malta,
          HistoricalStops.syracuse,
          HistoricalStops.rhegium,
          HistoricalStops.puteoli,
        ],
      ),
    ],
  );

  /// All three journeys.
  static const List<HistoricalJourney> all = [
    secondJourney,
    thirdJourney,
    romeJourney,
  ];

  const HistoricalJourneys._();
}

/// [HistoricalJourneyRepository] backed by the compile-time
/// [HistoricalJourneys]; there is no I/O, so the load is synchronous and
/// cheap.
final class StaticHistoricalJourneyRepository
    implements HistoricalJourneyRepository {
  /// Creates a repository over the three built-in journeys.
  const StaticHistoricalJourneyRepository();

  @override
  List<HistoricalJourney> loadHistoricalJourneys() => HistoricalJourneys.all;
}

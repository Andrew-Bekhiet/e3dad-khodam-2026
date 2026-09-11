import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:equatable/equatable.dart';

/// One of Paul's historical journeys, told as an origin and the rests it
/// stops at in order.
///
/// Deliberately shallower than `GameJourneyState` and its levels: this
/// experience is trail, markers and camera only, with no dialogue, verses
/// or destination cards to hang extra structure off.
final class HistoricalJourney extends Equatable {
  /// Stable identifier, unique across the three journeys.
  final String id;

  /// The journey's title, shown while it plays. Arabic.
  final String title;

  /// Where the journey sets out from.
  final JourneyStop origin;

  /// The places the journey stops at, in the order it visits them.
  final List<JourneyRest> rests;

  @override
  List<Object?> get props => [id, title, origin, rests];

  /// Creates a journey.
  const HistoricalJourney({
    required this.id,
    required this.title,
    required this.origin,
    required this.rests,
  });
}

/// A place the journey stops at, and how it got there.
final class JourneyRest extends Equatable {
  /// Where the journey rests.
  final JourneyStop stop;

  /// The places the trail passes through on the way to [stop], without
  /// stopping at any of them.
  final List<JourneyStop> via;

  /// The cities that flash like a bulb, one after another, while the
  /// journey rests at [stop] — a letter sent to each from here. Empty when
  /// this rest sends none.
  final List<JourneyStop> beacons;

  /// Whether the first press after arriving lights `beacons[0]`, rather
  /// than it lighting the moment the journey arrives.
  final bool arrivesDark;

  /// How many presses the journey spends at this rest: one to arrive,
  /// then one per beacon that does not light on arrival.
  int get phaseCount =>
      beacons.isEmpty ? 1 : beacons.length + (arrivesDark ? 1 : 0);

  @override
  List<Object?> get props => [stop, via, beacons, arrivesDark];

  /// Creates a rest.
  const JourneyRest({
    required this.stop,
    this.via = const [],
    this.beacons = const [],
    this.arrivesDark = false,
  });

  /// The beacon lit at [phase], or null while the rest is dark.
  JourneyStop? beaconAt(int phase) {
    final index = arrivesDark ? phase - 1 : phase;

    return index < 0 || index >= beacons.length ? null : beacons[index];
  }
}

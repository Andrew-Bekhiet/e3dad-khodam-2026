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

  /// The city that flashes like a bulb while the journey rests at [stop],
  /// meaning a letter was sent to it from here — or null when this rest
  /// sends none.
  final JourneyStop? beacon;

  @override
  List<Object?> get props => [stop, via, beacon];

  /// Creates a rest.
  const JourneyRest({required this.stop, this.via = const [], this.beacon});
}

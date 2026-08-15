import 'package:e3dad_khodam_2026/src/data/game/courier_route.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_walk.dart';
import 'package:equatable/equatable.dart';

/// The couriers on the move, and the one journey they all share.
///
/// They travel together, so there is a single trail with a single group
/// standing at the end of it — not a trail and a position per person.
/// [couriers] is who is walking, [stops] is where they have been, and
/// [trailAt] is the only thing the map needs in order to draw them.
///
/// The heavy part of that geometry is the legs already behind them: real
/// route coordinates, hundreds of them by the last level, and the same
/// on every frame of a walk. They follow from [stops] alone, so they are
/// built once per party — which is what lets the map ask this question
/// on every frame without rebuilding the whole journey on every frame.
final class CourierParty extends Equatable {
  /// Who is travelling, in the order they are drawn. Never empty.
  final List<GameCharacter> couriers;

  /// Every stop the party has stood at, oldest first, with consecutive
  /// repeats collapsed — two levels in the same city are one point on
  /// the map, not two. Never empty.
  final List<JourneyStop> stops;

  /// The line through every completed leg: everything except the one
  /// being walked now.
  late final List<GeoPosition> _behind = CourierRoute.beforeLastLeg(stops);

  /// The geometry of the leg under the party's feet.
  late final List<GeoPosition> _currentLeg = CourierRoute.lastLeg(stops);

  /// The whole journey, which is what a party that is not mid-walk shows
  /// — and what most of the game's frames ask for.
  late final WalkedTrail _arrived = WalkedTrail(
    points: CourierRoute.through(stops),
    position: destination.position,
  );

  /// Where the party is once it has finished walking.
  JourneyStop get destination => stops.last;

  /// Whether the party has anywhere to have come from: a journey of one
  /// stop is a group standing still, with no leg under them.
  bool get isUnderway => stops.length > 1;

  @override
  List<Object?> get props => [couriers, stops];

  /// Creates a party. [couriers] and [stops] must not be empty.
  CourierParty({required this.couriers, required this.stops});

  /// The trail behind the party and the point they stand on, when they
  /// are [progress] of the way along the leg they are walking now.
  ///
  /// `0` leaves them on the stop they set out from and `1` puts them on
  /// [destination] with the whole journey drawn behind them; anything
  /// outside that is clamped.
  WalkedTrail trailAt(double progress) {
    final walked = progress.clamp(0.0, 1.0);
    if (walked >= 1 || !isUnderway) {
      return _arrived;
    }
    final walk = TrailWalk.along(_currentLeg, walked);

    return WalkedTrail(
      // `travelled` starts on the point `_behind` already ends on.
      points: [..._behind, ...walk.travelled.skip(1)],
      position: walk.position,
    );
  }
}

/// How much of the journey has been walked: the line to stroke, and the
/// point at the end of it where the party stands.
///
/// One value for both because they are one fact — the trail ends exactly
/// where the walkers are.
final class WalkedTrail extends Equatable {
  /// The line to stroke, oldest point first. Fewer than two points draws
  /// nothing: a journey needs somewhere to have come from.
  final List<GeoPosition> points;

  /// Where the party stands, which is the last of [points].
  final GeoPosition position;

  @override
  List<Object?> get props => [points, position];

  /// Creates a walked trail.
  const WalkedTrail({required this.points, required this.position});
}

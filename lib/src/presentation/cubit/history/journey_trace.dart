import 'package:e3dad_khodam_2026/src/data/history/historical_legs.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/domain/routing/route_line.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_walk.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart'
    show WalkedTrail;
import 'package:equatable/equatable.dart';

/// The line already drawn for a historical journey, and the stretch being
/// drawn now.
///
/// The historical counterpart of `CourierParty`. Unlike a courier's single
/// atlas leg, the stretch under way here is a run of several: the leg from
/// the previous rest through every via city to the current one, because
/// via cities are passed through rather than stopped at — one continuous
/// movement.
///
/// The heavy part of the geometry is the legs already behind the journey:
/// real route coordinates, potentially hundreds of them by the last rest.
/// They follow from [origin], [visitedRests] and [currentRest] alone, so
/// they are built once per instance with `late final` — which is what
/// lets the map ask [trailAt] on every frame without rebuilding the whole
/// journey each time.
final class JourneyTrace extends Equatable {
  static const RouteLine _route = RouteLine(HistoricalLegs.charted);

  /// Where the journey set out from.
  final JourneyStop origin;

  /// Rests already arrived at, oldest first, excluding the current one.
  final List<JourneyRest> visitedRests;

  /// The rest being approached or stood at now, or null on the opening
  /// step, when the journey has not set off.
  final JourneyRest? currentRest;

  /// The line through every rest already arrived at: everything except
  /// the stretch under way now.
  late final List<GeoPosition> _behind = _route.through(
    _pathThrough(visitedRests),
  );

  /// The geometry of the stretch under the journey's feet: from the
  /// previous rest, through [currentRest]'s via cities, to its stop.
  late final List<GeoPosition> _currentStretch = _stretch();

  /// How far along the current stretch each of its via cities sits, as a
  /// fraction of the stretch's length.
  late final List<double> _viaAt = _viaFractions();

  /// The whole journey so far, which is what a trace that is not mid-walk
  /// shows — and what most frames ask for.
  late final WalkedTrail _arrived = WalkedTrail(
    points: _route.through(_pathThrough(_restsSoFar)),
    position: destination.position,
  );

  /// Where the current stretch sets out from.
  JourneyStop get _previousStop =>
      visitedRests.isEmpty ? origin : visitedRests.last.stop;

  /// Every rest reached so far, including the current one.
  List<JourneyRest> get _restsSoFar {
    final rest = currentRest;

    return [...visitedRests, if (rest != null) rest];
  }

  /// Where the journey stands once it has finished walking: the current
  /// rest, or the origin while it is still parked there.
  JourneyStop get destination => currentRest?.stop ?? origin;

  /// Whether there is a stretch under way: false on the opening step,
  /// when the journey has nowhere to have come from yet.
  bool get isUnderway => currentRest != null;

  @override
  List<Object?> get props => [origin, visitedRests, currentRest];

  /// Creates a trace.
  JourneyTrace({
    required this.origin,
    required this.visitedRests,
    this.currentRest,
  });

  /// The trail behind the journey and the point it stands on, when it is
  /// [progress] of the way along the stretch being walked now.
  ///
  /// `0` leaves it on the stretch's starting point and `1` puts it on
  /// [destination] with the whole journey drawn behind it; anything
  /// outside that is clamped.
  WalkedTrail trailAt(double progress) {
    if (hasArrivedAt(progress)) {
      return _arrived;
    }
    final walk = TrailWalk.along(_currentStretch, progress.clamp(0.0, 1.0));

    return WalkedTrail(
      // `travelled` starts on the point `_behind` already ends on.
      points: [..._behind, ...walk.travelled.skip(1)],
      position: walk.position,
    );
  }

  /// Whether the trail has reached [destination] by [progress]: the same
  /// frame's-truth test [trailAt] and [viaReachedAt] already make, named
  /// so a marker for the destination itself — the current rest and its
  /// beacon — can be gated on it too.
  bool hasArrivedAt(double progress) =>
      progress.clamp(0.0, 1.0) >= 1 || !isUnderway;

  /// The via cities of the stretch under way that the trail has already
  /// reached at [progress].
  ///
  /// The frame's truth, where `HistoricalJourneyState.revealedVia` is the
  /// step's: a city appears as the line arrives at it rather than all of
  /// them appearing the moment the journey sets off. The same distinction
  /// [trailAt] makes against the settled trail.
  List<JourneyStop> viaReachedAt(double progress) {
    final rest = currentRest;
    if (rest == null) {
      return const [];
    }
    final walked = progress.clamp(0.0, 1.0);

    return [
      for (final (index, via) in rest.via.indexed)
        if (_viaAt[index] <= walked) via,
    ];
  }

  List<double> _viaFractions() {
    final rest = currentRest;
    if (rest == null || rest.via.isEmpty) {
      return const [];
    }
    final total = TrailWalk.lengthOf(_currentStretch);
    if (total == 0) {
      return [for (final _ in rest.via) 0];
    }

    final path = [_previousStop, ...rest.via, rest.stop];
    final fractions = <double>[];
    var walked = 0.0;
    for (var index = 1; index < path.length - 1; index++) {
      walked += TrailWalk.lengthOf(
        _route.through([path[index - 1], path[index]]),
      );
      fractions.add(walked / total);
    }

    return List.unmodifiable(fractions);
  }

  List<GeoPosition> _stretch() {
    final rest = currentRest;
    if (rest == null) {
      return const [];
    }

    return _route.through([_previousStop, ...rest.via, rest.stop]);
  }

  List<JourneyStop> _pathThrough(List<JourneyRest> rests) => [
    origin,
    for (final rest in rests) ...[...rest.via, rest.stop],
  ];
}

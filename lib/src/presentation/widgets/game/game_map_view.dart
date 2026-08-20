import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/courier_party.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_map_styles.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridges the playthrough state to the provider-agnostic map seam: the
/// journey's stops become markers, the party's shared route becomes one
/// line along real route geometry, and every traveller becomes a round
/// portrait token standing on the end of it.
///
/// While a sweep is flying, the party walks its last leg and the trail
/// draws itself up to where they stand — one movement, so one clock and
/// one computation.
final class GameMapView extends StatelessWidget {
  static const double _minZoom = 4.0;
  static const double _maxZoom = 18.0;

  /// Clear space between a portrait and the label of the stop underneath
  /// it.
  static const double _labelGap = 8.0;

  /// The sweep's shared phase clock.
  final SweepClock sweepClock;

  /// Called when a tap lands anywhere on the map, marker or not.
  ///
  /// One callback for both, because a tap is a press: landing on a city
  /// used to jump the whole level it belongs to, which skipped past the
  /// guide and the verses of every level in between.
  final VoidCallback? onTap;

  /// Creates the game map; reads its data from ambient providers.
  const GameMapView({required this.sweepClock, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameJourneyCubit>();
    final surfaceBuilder = context.read<MapSurfaceBuilder>();
    final state = cubit.state;

    return _WalkingMapSurface(
      state: state,
      // Markers answer to the step, not to the clock: only the room a
      // label leaves for a portrait can move during a walk, and the
      // portraits end the walk where this puts them. Building them out
      // here keeps them off the animation entirely.
      markers: _markersFor(state),
      onMarkerTap: (_) => onTap?.call(),
      onSurfaceTap: onTap,
      surfaceBuilder: surfaceBuilder,
      sweepClock: sweepClock,
    );
  }

  /// The stops to draw, at most one marker per point.
  ///
  /// A city holding two letters appears twice in the script — cleared
  /// from the first, current or next for the second — and two markers on
  /// one point means two copies of the city's name stacked on each
  /// other. Later entries win, so current beats cleared beats locked.
  ///
  /// The stop the party ends up on also hands its label the room to
  /// clear their portraits.
  static List<MapMarkerSpec> _markersFor(GameJourneyState state) {
    final occupied = _positionKey(state.party.destination.position);
    final nextStop = state.nextStop;
    final currentStop = state.currentStop;
    final byPosition = <String, MapMarkerSpec>{};

    for (final (stop, style, isInteractive) in [
      if (nextStop != null) (nextStop, GameMapStyles.locked, false),
      for (final stop in state.clearedStops)
        (stop, GameMapStyles.cleared, true),
      if (currentStop != null) (currentStop, GameMapStyles.current, true),
    ]) {
      final key = _positionKey(stop.position);
      byPosition[key] = _marker(
        stop,
        style,
        isInteractive: isInteractive,
        labelClearance: key == occupied
            ? GameMapStyles.tokenDiameter / 2 + _labelGap
            : 0,
      );
    }

    return byPosition.values.toList(growable: false);
  }

  /// Identifies a point, so what stands on it can be matched to it.
  static String _positionKey(GeoPosition position) =>
      '${position.latitude},${position.longitude}';

  /// A stop's marker. The stop's own id is the marker id, which is what
  /// `GameJourneyCubit.goToStop` is handed on a tap.
  static MapMarkerSpec _marker(
    JourneyStop stop,
    MapMarkerStyle style, {
    bool isInteractive = false,
    double labelClearance = 0,
  }) => MapMarkerSpec(
    id: stop.id,
    position: stop.position,
    label: stop.label,
    style: style,
    isInteractive: isInteractive,
    labelClearance: labelClearance,
  );
}

/// The map surface as the party walks across it: everything that moves
/// during a sweep, and nothing that does not.
final class _WalkingMapSurface extends StatefulWidget {
  final GameJourneyState state;
  final List<MapMarkerSpec> markers;
  final void Function(String stopId) onMarkerTap;
  final VoidCallback? onSurfaceTap;
  final MapSurfaceBuilder surfaceBuilder;
  final SweepClock sweepClock;

  const _WalkingMapSurface({
    required this.state,
    required this.markers,
    required this.onMarkerTap,
    required this.onSurfaceTap,
    required this.surfaceBuilder,
    required this.sweepClock,
  });

  @override
  State<_WalkingMapSurface> createState() => _WalkingMapSurfaceState();
}

class _WalkingMapSurfaceState extends State<_WalkingMapSurface> {
  /// The one trail on the map. The party shares a route, so it is the
  /// journey's line rather than any one traveller's.
  static const String _trailId = 'party';

  /// How far neighbouring portraits overlap, in logical pixels. A slight
  /// overlap reads as a group standing together rather than as separate
  /// people who happen to share a city.
  static const double _tokenOverlap = 8.0;

  /// How many positions the walk is rounded to over a whole leg.
  ///
  /// The couriers cross the Mediterranean in a second and a half, so
  /// moving the geometry forty times over that is already smoother than
  /// anyone can see — while handing the renderer a fresh copy of the
  /// route on all sixty of a second's frames is how the platform channel
  /// fills up faster than it drains.
  static const int _walkSteps = 40;

  /// What was last drawn, and the walk it was drawn for.
  ///
  /// The animation ticks faster than the walk is rounded, so most frames
  /// ask for a position the frame before them already answered. Handing
  /// back the very same lists means the surface can tell nothing has
  /// changed by identity, without walking a thousand coordinates to find
  /// out.
  _WalkedContent? _content;
  double? _contentAt;
  CourierParty? _contentOf;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.sweepClock,
    builder: (context, _) {
      final state = widget.state;
      final content = _contentFor(
        state.party,
        _walkProgress(widget.sweepClock),
      );

      return widget.surfaceBuilder(
        MapSurfaceSpec(
          markers: widget.markers,
          camera: state.camera,
          minZoom: GameMapView._minZoom,
          maxZoom: GameMapView._maxZoom,
          cameraAnimationDuration: state.cameraAnimationDuration,
          onMarkerTap: widget.onMarkerTap,
          onSurfaceTap: widget.onSurfaceTap,
          trails: content.trails,
          tokens: content.tokens,
        ),
      );
    },
  );

  /// The line and the portraits for [party] at [walked], rebuilt only
  /// when one of the two has actually moved.
  _WalkedContent _contentFor(CourierParty party, double walked) {
    final content = _content;
    if (content != null &&
        _contentAt == walked &&
        identical(_contentOf, party)) {
      return content;
    }
    final trail = party.trailAt(walked);
    final built = _WalkedContent(
      trails: [
        MapTrailSpec(
          id: _trailId,
          points: trail.points,
          style: MapTrailStyle.travelled,
        ),
      ],
      tokens: _tokensFor(party, trail.position),
    );
    _content = built;
    _contentAt = walked;
    _contentOf = party;

    return built;
  }

  /// How far along its last leg the party has walked, rounded to one of
  /// [_walkSteps] positions.
  ///
  /// The walk belongs to the hold, the stretch where the camera is out
  /// at the sweep frame and the whole route is on screen. Walking during
  /// the inward leg would hide the journey behind the very movement that
  /// is meant to show it: by then the camera is already closing on one
  /// city and the rest of the line is off the edge.
  ///
  /// So the order is: pull out, walk, dive.
  static double _walkProgress(SweepClock clock) {
    final walked = clock.holdProgress * _walkSteps;

    return (walked.roundToDouble() / _walkSteps).clamp(0.0, 1.0);
  }

  /// One token per courier, the group spread evenly either side of the
  /// point they all stand on.
  static List<MapTokenSpec> _tokensFor(
    CourierParty party,
    GeoPosition position,
  ) {
    final couriers = party.couriers;

    return [
      for (final (index, courier) in couriers.indexed)
        MapTokenSpec(
          id: courier.id,
          position: position,
          style: GameMapStyles.tokenFor(courier),
          offset: _rowOffset(index, couriers.length),
        ),
    ];
  }

  /// Where the [index]th of [count] couriers stands.
  ///
  /// A row, centred on the place itself, so the middle of the group is
  /// the point the trail ends at and the group travels with the trail
  /// rather than hovering somewhere near it.
  static Offset _rowOffset(int index, int count) => Offset(
    (index - (count - 1) / 2) * (GameMapStyles.tokenDiameter - _tokenOverlap),
    0,
  );
}

/// The map content that moves as the party walks: their one line, and
/// the portraits standing at the end of it.
final class _WalkedContent {
  final List<MapTrailSpec> trails;
  final List<MapTokenSpec> tokens;

  const _WalkedContent({required this.trails, required this.tokens});
}

import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/journey_trace.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/beacon_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/history_map_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridges a historical journey's playthrough state to the
/// provider-agnostic map seam: the trail becomes one line along real
/// route geometry, and the origin, rests, via cities and beacon become
/// markers. No tokens — this map has nobody standing on it.
///
/// While a sweep is flying, the trail draws itself up to where the
/// journey stands. That is the only thing that moves besides the
/// beacon's flash, so the two share one surface but two clocks.
final class HistoryMapView extends StatelessWidget {
  /// The sweep's shared phase clock.
  final SweepClock sweepClock;

  /// The beacon's shared flash clock.
  final BeaconClock beaconClock;

  /// Called when a tap lands anywhere on the map, marker or not.
  final VoidCallback? onTap;

  /// Creates the historical map; reads its data from ambient providers.
  const HistoryMapView({
    required this.sweepClock,
    required this.beaconClock,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<HistoricalJourneyCubit>();
    final surfaceBuilder = context.read<MapSurfaceBuilder>();

    return _WalkingHistoryMapSurface(
      state: cubit.state,
      onMarkerTap: (_) => onTap?.call(),
      onSurfaceTap: onTap,
      surfaceBuilder: surfaceBuilder,
      sweepClock: sweepClock,
      beaconClock: beaconClock,
    );
  }

  /// The stops to draw, at most one marker per point.
  ///
  /// A city can be both a via point the trail has passed and the rest's
  /// beacon — تسالونيكي is, on the 2nd journey. Later entries win, so the
  /// beacon is added last and its styling always wins over a waypoint's.
  static List<MapMarkerSpec> markersFor(
    HistoricalJourneyState state, {
    required bool beaconBright,
  }) {
    final beacon = state.beacon;
    final byPosition = <String, MapMarkerSpec>{};

    for (final (stop, style, isInteractive) in [
      (state.origin, HistoryMapStyles.origin, true),
      for (final rest in state.visitedRests)
        (rest.stop, HistoryMapStyles.rest, true),
      for (final via in state.revealedVia)
        (via, HistoryMapStyles.waypoint, false),
      (state.currentStop, HistoryMapStyles.current, true),
      if (beacon != null)
        (
          beacon,
          beaconBright
              ? HistoryMapStyles.beaconBright
              : HistoryMapStyles.beaconDim,
          true,
        ),
    ]) {
      byPosition[_positionKey(stop.position)] = _marker(
        stop,
        style,
        isInteractive: isInteractive,
      );
    }

    return byPosition.values.toList(growable: false);
  }

  /// Identifies a point, so what stands on it can be matched to it.
  static String _positionKey(GeoPosition position) =>
      '${position.latitude},${position.longitude}';

  static MapMarkerSpec _marker(
    JourneyStop stop,
    MapMarkerStyle style, {
    required bool isInteractive,
  }) => MapMarkerSpec(
    id: stop.id,
    position: stop.position,
    label: stop.label,
    style: style,
    isInteractive: isInteractive,
  );
}

/// The map surface as the trail draws itself: everything that moves
/// during a sweep or a flash, and nothing that does not.
final class _WalkingHistoryMapSurface extends StatefulWidget {
  final HistoricalJourneyState state;
  final void Function(String stopId) onMarkerTap;
  final VoidCallback? onSurfaceTap;
  final MapSurfaceBuilder surfaceBuilder;
  final SweepClock sweepClock;
  final BeaconClock beaconClock;

  const _WalkingHistoryMapSurface({
    required this.state,
    required this.onMarkerTap,
    required this.onSurfaceTap,
    required this.surfaceBuilder,
    required this.sweepClock,
    required this.beaconClock,
  });

  @override
  State<_WalkingHistoryMapSurface> createState() =>
      _WalkingHistoryMapSurfaceState();
}

class _WalkingHistoryMapSurfaceState extends State<_WalkingHistoryMapSurface> {
  final HistoryMapSpecBuilder _specBuilder = HistoryMapSpecBuilder();

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([widget.sweepClock, widget.beaconClock]),
    builder: (context, _) => widget.surfaceBuilder(
      _specBuilder.build(
        state: widget.state,
        sweepClock: widget.sweepClock,
        beaconBright: widget.beaconClock.isBright,
        onMarkerTap: widget.onMarkerTap,
        onSurfaceTap: widget.onSurfaceTap,
      ),
    ),
  );
}

/// Builds the map spec for a historical journey's playthrough: the trail
/// and markers, cached by identity so a still frame does not re-walk the
/// route or rebuild markers on every animation tick.
///
/// Kept independent of any widget — rather than folded into
/// `_WalkingHistoryMapSurfaceState` — so both [HistoryMapView] and the map
/// stage's `HistoricalJourneyPresenter` can share one copy of the caching
/// instead of each keeping its own.
final class HistoryMapSpecBuilder {
  static const double minZoom = 4.0;
  static const double maxZoom = 18.0;

  /// The one trail on the map: the journey's own line.
  static const String _trailId = 'journey';

  /// How many positions the walk is rounded to over a whole stretch. See
  /// `GameMapView._walkSteps` for why: smoother than any eye can see,
  /// without flooding the platform channel with a fresh route on every
  /// frame.
  static const int _walkSteps = 40;

  /// How far along the current stretch the trail has drawn, rounded to
  /// one of [_walkSteps] positions. Mirrors
  /// `GameMapView._WalkingMapSurfaceState._walkProgress`: the drawing
  /// belongs to the hold, the stretch where the camera is out at the
  /// sweep frame and the whole run is on screen.
  static double _walkProgress(SweepClock clock) {
    final walked = clock.holdProgress * _walkSteps;

    return (walked.roundToDouble() / _walkSteps).clamp(0.0, 1.0);
  }

  /// What was last drawn, and the trace/progress it was drawn for.
  List<MapTrailSpec>? _trails;
  double? _trailsAt;
  JourneyTrace? _trailsOf;

  /// What markers were last built, and the state/flash they were built
  /// for.
  List<MapMarkerSpec>? _markers;
  HistoricalJourneyState? _markersOf;
  bool? _markersBright;

  /// The spec for [state] with the beacon in [beaconBright]'s state and
  /// the trail drawn as far as [sweepClock] has walked it.
  MapSurfaceSpec build({
    required HistoricalJourneyState state,
    required SweepClock sweepClock,
    required bool beaconBright,
    required void Function(String stopId) onMarkerTap,
    required VoidCallback? onSurfaceTap,
  }) => MapSurfaceSpec(
    markers: _markersFor(state, beaconBright),
    camera: state.camera,
    minZoom: minZoom,
    maxZoom: maxZoom,
    cameraAnimationDuration: state.cameraAnimationDuration,
    onMarkerTap: onMarkerTap,
    onSurfaceTap: onSurfaceTap,
    trails: _trailsFor(state.trace, _walkProgress(sweepClock)),
    // Written out on purpose: this map has no couriers and no portraits,
    // ever.
    // ignore: avoid_redundant_argument_values
    tokens: const [],
  );

  /// The trail for [trace] at [walked], rebuilt only when one of the two
  /// has actually moved.
  List<MapTrailSpec> _trailsFor(JourneyTrace trace, double walked) {
    final trails = _trails;
    if (trails != null && _trailsAt == walked && identical(_trailsOf, trace)) {
      return trails;
    }
    final trail = trace.trailAt(walked);
    final built = [
      MapTrailSpec(
        id: _trailId,
        points: trail.points,
        style: MapTrailStyle.travelled,
      ),
    ];
    _trails = built;
    _trailsAt = walked;
    _trailsOf = trace;

    return built;
  }

  /// The markers for [state] with the beacon in [beaconBright]'s state,
  /// rebuilt only when one of the two has actually changed.
  List<MapMarkerSpec> _markersFor(
    HistoricalJourneyState state,
    bool beaconBright,
  ) {
    final markers = _markers;
    if (markers != null &&
        identical(_markersOf, state) &&
        _markersBright == beaconBright) {
      return markers;
    }
    final built = HistoryMapView.markersFor(state, beaconBright: beaconBright);
    _markers = built;
    _markersOf = state;
    _markersBright = beaconBright;

    return built;
  }
}

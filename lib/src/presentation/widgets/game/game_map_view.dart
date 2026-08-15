import 'package:e3dad_khodam_2026/src/data/game/courier_route.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/trails/trail_walk.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/character_trail.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_map_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridges the playthrough state to the provider-agnostic map seam: the
/// journey's stops become markers, each character's route becomes a line
/// along real route geometry, and each character becomes a round
/// portrait token.
///
/// While a sweep is flying, the couriers walk their last leg and the
/// trail draws itself up to where they stand — one movement, so one
/// clock and one computation.
final class GameMapView extends StatelessWidget {
  static const double _minZoom = 4.0;
  static const double _maxZoom = 18.0;

  /// Logical pixels between the tokens of characters standing in the
  /// same city, so travelling companions read as two people rather than
  /// one portrait hiding another.
  static const double _tokenSpacing = 34.0;

  /// How far through the current sweep the camera is.
  final Animation<double> sweepProgress;

  /// Creates the game map; reads its data from ambient providers.
  const GameMapView({required this.sweepProgress, super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameJourneyCubit>();
    final surfaceBuilder = context.read<MapSurfaceBuilder>();
    final state = cubit.state;
    final nextStop = state.nextStop;
    final currentStop = state.currentStop;

    return AnimatedBuilder(
      animation: sweepProgress,
      builder: (context, _) {
        final walked = _walkProgress(state.sweep, sweepProgress.value);
        final routes = [
          for (final trail in state.trails) _routeOf(trail, walked),
        ];

        return surfaceBuilder(
          MapSurfaceSpec(
            markers: [
              if (nextStop != null) _marker(nextStop, GameMapStyles.locked),
              for (final stop in state.clearedStops)
                _marker(stop, GameMapStyles.cleared, isInteractive: true),
              if (currentStop != null)
                _marker(currentStop, GameMapStyles.current, isInteractive: true),
            ],
            camera: state.camera,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            cameraAnimationDuration: state.cameraAnimationDuration,
            onMarkerTap: cubit.goToStop,
            trails: _trailsFor(routes),
            tokens: _tokensFor(routes),
          ),
        );
      },
    );
  }

  /// How far along its last leg a courier has walked.
  ///
  /// The walk belongs to the camera's inward leg alone: the couriers
  /// stay put while the camera pulls out and holds, then travel as it
  /// comes in, so the two movements land together.
  static double _walkProgress(SweepCameraTarget? sweep, double value) {
    if (sweep == null) {
      return 1;
    }
    final elapsed = value * sweep.total.inMilliseconds;
    final start = (sweep.outLeg + sweep.hold).inMilliseconds;
    final inLeg = sweep.inLeg.inMilliseconds;
    if (inLeg == 0) {
      return 1;
    }

    return ((elapsed - start) / inLeg).clamp(0.0, 1.0);
  }

  /// One character's line and where they stand on it.
  static _CourierRoute _routeOf(CharacterTrail trail, double walked) {
    final lastLeg = CourierRoute.lastLeg(trail.path);
    if (walked >= 1 || trail.path.length < 2) {
      final full = CourierRoute.through(trail.path);

      return _CourierRoute(
        character: trail.character,
        points: full,
        position: trail.position.position,
      );
    }

    final walk = TrailWalk.along(lastLeg, walked);

    return _CourierRoute(
      character: trail.character,
      points: [
        ...CourierRoute.beforeLastLeg(trail.path),
        ...walk.travelled.skip(1),
      ],
      position: walk.position,
    );
  }

  /// One line per distinct route: characters travelling together share
  /// every stop, and drawing their identical curves twice would only
  /// darken the dashes.
  static List<MapTrailSpec> _trailsFor(List<_CourierRoute> routes) {
    final byShape = <String, _CourierRoute>{};
    for (final route in routes) {
      byShape.putIfAbsent(route.shapeKey, () => route);
    }

    return [
      for (final route in byShape.values)
        MapTrailSpec(
          id: route.character.id,
          points: route.points,
          style: MapTrailStyle.travelled,
        ),
    ];
  }

  /// One token per character, with everyone standing in the same place
  /// spread evenly either side of it.
  static List<MapTokenSpec> _tokensFor(List<_CourierRoute> routes) {
    final byPosition = <String, List<_CourierRoute>>{};
    for (final route in routes) {
      byPosition.putIfAbsent(route.positionKey, () => []).add(route);
    }

    return [
      for (final group in byPosition.values)
        for (final (index, route) in group.indexed)
          MapTokenSpec(
            id: route.character.id,
            position: route.position,
            style: GameMapStyles.tokenFor(route.character),
            offset: Offset(
              (index - (group.length - 1) / 2) * _tokenSpacing,
              0,
            ),
          ),
    ];
  }

  /// A stop's marker. The stop's own id is the marker id, which is what
  /// `GameJourneyCubit.goToStop` is handed on a tap.
  static MapMarkerSpec _marker(
    JourneyStop stop,
    MapMarkerStyle style, {
    bool isInteractive = false,
  }) => MapMarkerSpec(
    id: stop.id,
    position: stop.position,
    label: stop.label,
    style: style,
    isInteractive: isInteractive,
  );
}

/// One character's drawn line and the point on it they occupy.
final class _CourierRoute {
  final GameCharacter character;
  final List<GeoPosition> points;
  final GeoPosition position;

  /// Identifies the shape, so companions walking the same water are
  /// drawn once.
  String get shapeKey =>
      '${points.length}:${points.firstOrNull}:${points.lastOrNull}';

  /// Identifies where they stand, so companions are spread apart.
  String get positionKey => '${position.latitude},${position.longitude}';

  const _CourierRoute({
    required this.character,
    required this.points,
    required this.position,
  });
}

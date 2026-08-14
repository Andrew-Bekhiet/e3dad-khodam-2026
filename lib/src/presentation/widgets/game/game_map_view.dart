import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_marker_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_trail_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_map_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridges the playthrough state to the provider-agnostic map seam: the
/// journey's stops become markers, each character's route becomes a
/// dashed trail, and each character becomes a round portrait token.
final class GameMapView extends StatelessWidget {
  static const double _minZoom = 4.0;
  static const double _maxZoom = 18.0;

  /// Creates the game map; reads its data from ambient providers.
  const GameMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameJourneyCubit>();
    final surfaceBuilder = context.read<MapSurfaceBuilder>();
    final state = cubit.state;
    final nextStop = state.nextStop;
    final currentStop = state.currentStop;

    final spec = MapSurfaceSpec(
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
      trails: [
        for (final trail in state.trails)
          MapTrailSpec(
            id: trail.character.id,
            points: [for (final stop in trail.path) stop.position],
            style: MapTrailStyle.travelled,
          ),
      ],
      tokens: [
        for (final trail in state.trails)
          MapTokenSpec(
            id: trail.character.id,
            position: trail.position.position,
            style: GameMapStyles.tokenFor(trail.character),
          ),
      ],
    );

    return surfaceBuilder(spec);
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

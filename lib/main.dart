import 'package:e3dad_khodam_2026/src/app/e3dad_khodam_app.dart';
import 'package:e3dad_khodam_2026/src/data/audio/audioplayers_game_sounds.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/data/static_journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_map_surface.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureMapboxRenderer();
  runApp(
    E3dadKhodamApp(
      gameSounds: await AudioPlayersGameSounds.create(),
      repository: const StaticJourneyMapRepository(),
      levelScriptRepository: const StaticLevelScriptRepository(),
      mapSurfaceBuilder: mapboxMapSurface,
    ),
  );
}

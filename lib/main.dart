import 'package:e3dad_khodam_2026/src/app/e3dad_khodam_app.dart';
import 'package:e3dad_khodam_2026/src/data/static_journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/map_engine/mapbox/mapbox_map_surface.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureMapboxRenderer();
  runApp(
    const E3dadKhodamApp(
      repository: StaticJourneyMapRepository(),
      mapSurfaceBuilder: mapboxMapSurface,
    ),
  );
}

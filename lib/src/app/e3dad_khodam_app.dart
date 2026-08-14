import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/app/app_theme.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/journey_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// The app root: forces Arabic/RTL, wires the M3 light/dark themes, and
/// makes the injected [repository] and [mapSurfaceBuilder] available to
/// every descendant via `RepositoryProvider`.
final class E3dadKhodamApp extends StatelessWidget {
  static const Locale _locale = Locale('ar');

  /// Source of the journey-map hierarchy and non-geographic groups.
  final JourneyMapRepository repository;

  /// Source of the guided game's level script.
  final LevelScriptRepository levelScriptRepository;

  /// Concrete map-provider widget factory (e.g. `MapboxMapSurface.new`).
  final MapSurfaceBuilder mapSurfaceBuilder;

  /// Plays the game's sound effects; silent until the clearance jingle
  /// is added to the project.
  final GameSounds gameSounds;

  /// Creates the app root over the given data sources and map provider.
  const E3dadKhodamApp({
    required this.repository,
    required this.levelScriptRepository,
    required this.mapSurfaceBuilder,
    this.gameSounds = const SilentGameSounds(),
    super.key,
  });

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<JourneyMapRepository>.value(value: repository),
      RepositoryProvider<LevelScriptRepository>.value(
        value: levelScriptRepository,
      ),
      RepositoryProvider<MapSurfaceBuilder>.value(value: mapSurfaceBuilder),
      RepositoryProvider<GameSounds>.value(value: gameSounds),
    ],
    child: MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [_locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const JourneyMapPage(),
    ),
  );
}

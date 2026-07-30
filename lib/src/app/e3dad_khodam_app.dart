import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/app/app_theme.dart';
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

  /// Concrete map-provider widget factory (e.g. `MapboxMapSurface.new`).
  final MapSurfaceBuilder mapSurfaceBuilder;

  /// Creates the app root over the given data source and map provider.
  const E3dadKhodamApp({
    required this.repository,
    required this.mapSurfaceBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<JourneyMapRepository>.value(value: repository),
      RepositoryProvider<MapSurfaceBuilder>.value(value: mapSurfaceBuilder),
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

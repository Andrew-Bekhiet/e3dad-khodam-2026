import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/data/history/historical_journeys.dart';
import 'package:e3dad_khodam_2026/src/data/static_journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/journey_map_repository.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/game_journey_page.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/map_stage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for a real map: the surface is a platform view, which a
/// widget test cannot render, and none of these tests are about the map
/// itself.
///
/// Stateful (unlike the blank stand-ins other page tests use) so its
/// `State` object's identity can be checked across a script switch — the
/// thing this whole feature is meant to prove.
final class MapStagePageTest extends StatefulWidget {
  final MapSurfaceSpec spec;

  const MapStagePageTest(this.spec);

  @override
  State<MapStagePageTest> createState() => _MapStagePageTestState();
}

final class _MapStagePageTestState extends State<MapStagePageTest> {
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

const MapSurfaceBuilder _stubSurface = MapStagePageTest.new;

/// The stage with its dependencies stubbed. The game route needs a level
/// script and sounds provider even though these tests never step into a
/// level, since [GameJourneyPage] reads both from its ambient context.
final class _StageUnderTest extends StatelessWidget {
  const _StageUnderTest();

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<JourneyMapRepository>.value(
        value: const StaticJourneyMapRepository(),
      ),
      RepositoryProvider<LevelScriptRepository>.value(
        value: const StaticLevelScriptRepository(),
      ),
      RepositoryProvider<GameSounds>.value(value: const SilentGameSounds()),
      RepositoryProvider<MapSurfaceBuilder>.value(value: _stubSurface),
    ],
    // The app runs right-to-left, and the stage's own layout — the five
    // buttons pinned to the physical top-left — has to hold that corner
    // regardless of it.
    child: const Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(home: MapStagePage()),
    ),
  );
}

/// The spec most recently handed to the stubbed map surface.
MapSurfaceSpec _specOf(WidgetTester tester) =>
    tester.widget<MapStagePageTest>(find.byType(MapStagePageTest)).spec;

/// The mounted `State` behind the map surface, whose identity is what
/// proves a script switch did not tear the surface down.
State<MapStagePageTest> _surfaceStateOf(WidgetTester tester) =>
    tester.state(find.byType(MapStagePageTest));

Future<void> _selectScript(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
}

void main() {
  _buttonTests();
  _switchingTests();
  _chromeTests();
  _surfaceIdentityTests();
  _gameButtonTests();
}

void _buttonTests() {
  testWidgets('MapStagePage_allFiveButtons_render', (tester) async {
    await tester.pumpWidget(const _StageUnderTest());
    await tester.pump();

    expect(tester.takeException(), isNull);
    // The cross map starts selected, so its label shows twice: once as
    // the button and once as the app bar title.
    expect(find.text(AppStrings.crossMapScriptLabel), findsNWidgets(2));
    expect(find.text(AppStrings.secondJourneyScriptLabel), findsOneWidget);
    expect(find.text(AppStrings.thirdJourneyScriptLabel), findsOneWidget);
    expect(find.text(AppStrings.romeJourneyScriptLabel), findsOneWidget);
    expect(find.text(AppStrings.gameTitle), findsOneWidget);
  });
}

void _switchingTests() {
  testWidgets(
    'MapStagePage_pressingAJourneyButton_showsThatJourneysStops',
    (tester) async {
      await tester.pumpWidget(const _StageUnderTest());
      await tester.pump();

      // The cross map's own root categories, not any journey's stops.
      expect(
        _specOf(tester).markers.map((marker) => marker.id),
        contains('continents'),
      );

      await _selectScript(tester, AppStrings.secondJourneyScriptLabel);

      final secondJourneyMarkers = _specOf(
        tester,
      ).markers.map((marker) => marker.id).toList();
      expect(
        secondJourneyMarkers,
        contains(HistoricalJourneys.secondJourney.origin.id),
        reason: 'the journey opens parked on its own origin',
      );
      expect(
        secondJourneyMarkers,
        isNot(contains('continents')),
        reason: 'the cross map is no longer the visible script',
      );

      await _selectScript(tester, AppStrings.thirdJourneyScriptLabel);

      expect(
        _specOf(tester).markers.map((marker) => marker.id),
        contains(HistoricalJourneys.thirdJourney.origin.id),
      );

      await _selectScript(tester, AppStrings.romeJourneyScriptLabel);

      expect(
        _specOf(tester).markers.map((marker) => marker.id),
        contains(HistoricalJourneys.romeJourney.origin.id),
      );

      await _selectScript(tester, AppStrings.crossMapScriptLabel);

      expect(
        _specOf(tester).markers.map((marker) => marker.id),
        contains('continents'),
      );
    },
  );
}

Finder _appBarTitle(String label) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(label));

void _chromeTests() {
  testWidgets(
    'MapStagePage_theAppBarTitle_namesTheSelectedScriptAndSwitchesWithIt',
    (tester) async {
      await tester.pumpWidget(const _StageUnderTest());
      await tester.pump();

      expect(_appBarTitle(AppStrings.crossMapScriptLabel), findsOneWidget);
      expect(
        _appBarTitle(AppStrings.secondJourneyScriptLabel),
        findsNothing,
      );

      await _selectScript(tester, AppStrings.secondJourneyScriptLabel);

      expect(
        _appBarTitle(AppStrings.secondJourneyScriptLabel),
        findsOneWidget,
      );
      expect(_appBarTitle(AppStrings.crossMapScriptLabel), findsNothing);
    },
  );
}

void _surfaceIdentityTests() {
  testWidgets(
    'MapStagePage_switchingScript_neverRecreatesTheMapSurface',
    (tester) async {
      await tester.pumpWidget(const _StageUnderTest());
      await tester.pump();
      final original = _surfaceStateOf(tester);

      for (final label in [
        AppStrings.secondJourneyScriptLabel,
        AppStrings.thirdJourneyScriptLabel,
        AppStrings.romeJourneyScriptLabel,
        AppStrings.crossMapScriptLabel,
      ]) {
        await _selectScript(tester, label);

        expect(
          _surfaceStateOf(tester),
          same(original),
          reason:
              'switching to $label should update the spec, not rebuild '
              'the surface',
        );
      }
    },
  );
}

void _gameButtonTests() {
  testWidgets('MapStagePage_theGameButton_opensItsOwnScreen', (tester) async {
    await tester.pumpWidget(const _StageUnderTest());
    await tester.pump();

    await tester.tap(find.text(AppStrings.gameTitle));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(GameJourneyPage), findsOneWidget);
    // The stage stays underneath, unaffected by the pushed route.
    expect(find.byType(MapStagePage), findsOneWidget);
  });
}

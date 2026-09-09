import 'package:e3dad_khodam_2026/src/data/history/historical_journeys.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/historical_journey_page.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/history_map_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for a real map: the surface is a platform view, which a
/// widget test cannot render, and none of these tests are about the map
/// itself.
///
/// A tear-off of a widget constructor, per `MapSurfaceBuilder`'s own doc:
/// a bare function returning a widget is flagged by the linter.
final class HistoricalJourneyPageTest extends StatelessWidget {
  final MapSurfaceSpec spec;

  const HistoricalJourneyPageTest(this.spec);

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

const MapSurfaceBuilder _stubSurface = HistoricalJourneyPageTest.new;

/// The journey screen with its map surface stubbed.
final class _JourneyUnderTest extends StatelessWidget {
  final HistoricalJourney journey;

  const _JourneyUnderTest(this.journey);

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<MapSurfaceBuilder>.value(
        value: _stubSurface,
        // The app runs right-to-left, and the page's own layout mirrors
        // with it.
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(home: HistoricalJourneyPage(journey: journey)),
        ),
      );
}

/// The cubit driving the page under test.
HistoricalJourneyCubit _cubitOf(WidgetTester tester) =>
    tester.element(find.byType(Scaffold)).read<HistoricalJourneyCubit>();

/// The spec most recently handed to the stubbed map surface.
MapSurfaceSpec _specOf(WidgetTester tester) => tester
    .widget<HistoricalJourneyPageTest>(find.byType(HistoricalJourneyPageTest))
    .spec;

/// Taps the map itself, as the real surface does when a tap lands on no
/// marker.
void _tapTheMap(WidgetTester tester) {
  final spec = _specOf(tester);
  expect(spec.onSurfaceTap, isNotNull, reason: 'the map should take taps');
  spec.onSurfaceTap?.call();
}

void main() {
  _renderTests();
  _tapTests();
  _beaconTests();
  _precedenceTests();
}

void _renderTests() {
  for (final journey in HistoricalJourneys.all) {
    testWidgets('HistoricalJourneyPage_rendersFor_${journey.id}', (
      tester,
    ) async {
      await tester.pumpWidget(_JourneyUnderTest(journey));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text(journey.title), findsOneWidget);
    });
  }
}

void _tapTests() {
  testWidgets('HistoricalJourneyPage_aTapOnTheMap_advancesTheJourney', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _JourneyUnderTest(HistoricalJourneys.secondJourney),
    );
    await tester.pump();
    final cubit = _cubitOf(tester);
    final before = cubit.state.stepIndex;

    _tapTheMap(tester);
    await tester.pump();

    expect(cubit.state.stepIndex, before + 1);
    expect(tester.takeException(), isNull);
  });
}

void _beaconTests() {
  testWidgets(
    'HistoricalJourneyPage_theBeacon_appearsOnlyWhileItsRestIsCurrent',
    (tester) async {
      await tester.pumpWidget(
        const _JourneyUnderTest(HistoricalJourneys.thirdJourney),
      );
      await tester.pump();
      final cubit = _cubitOf(tester);
      final beacon = HistoricalJourneys.thirdJourney.rests[1].beacon;
      if (beacon == null) {
        fail('the third journey should name رومية as its second beacon');
      }
      final beaconId = beacon.id;

      expect(
        _specOf(tester).markers.map((marker) => marker.id),
        isNot(contains(beaconId)),
        reason: 'nothing has sent a letter to رومية yet',
      );

      cubit.forward(); // rest 0: أفسس — no beacon
      await tester.pump();
      expect(
        _specOf(tester).markers.map((marker) => marker.id),
        isNot(contains(beaconId)),
      );

      cubit.forward(); // rest 1: فيلبي — beacon رومية
      await tester.pump();
      expect(
        _specOf(tester).markers.map((marker) => marker.id),
        contains(beaconId),
      );
    },
  );
}

void _precedenceTests() {
  testWidgets(
    'HistoricalJourneyPage_aCityThatIsBothWaypointAndBeacon_drawsAsTheBeacon',
    (tester) async {
      await tester.pumpWidget(
        const _JourneyUnderTest(HistoricalJourneys.secondJourney),
      );
      await tester.pump();
      final cubit = _cubitOf(tester);
      final rest = HistoricalJourneys.secondJourney.rests.single;
      final beacon = rest.beacon;
      if (beacon == null) {
        fail('the second journey should name تسالونيكي as its beacon');
      }
      expect(
        rest.via,
        contains(beacon),
        reason: 'تسالونيكي should still be a via city on the way to كورنثوس',
      );

      cubit.forward();
      await tester.pump();

      final markersAtBeacon = _specOf(
        tester,
      ).markers.where((marker) => marker.id == beacon.id).toList();

      expect(
        markersAtBeacon,
        hasLength(1),
        reason: 'at most one marker per position',
      );
      expect(
        markersAtBeacon.single.style,
        anyOf(HistoryMapStyles.beaconBright, HistoryMapStyles.beaconDim),
        reason: 'the beacon styling must win over the waypoint styling',
      );
    },
  );
}

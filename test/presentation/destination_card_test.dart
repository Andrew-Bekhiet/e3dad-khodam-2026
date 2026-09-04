import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/destination_card.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const JourneyStop _stop = JourneyStop(
  id: 'thessalonica',
  label: 'تسالونيكي',
  position: GeoPosition(latitude: 40.64, longitude: 22.94),
);

const GameLevel _level = GameLevel(
  id: 'thessalonians-1',
  signLabel: 'تسالونيكي الأولى والثانية',
  destination: _stop,
  year: 52,
  verses: ['آية'],
);

/// A prison letter's stop: the level stands where بولس wrote it, رومية,
/// but the sign still names the letter it delivers.
const JourneyStop _rome = JourneyStop(
  id: 'rome',
  label: 'رومية',
  position: GeoPosition(latitude: 41.9, longitude: 12.5),
);

const GameLevel _prisonLevel = GameLevel(
  id: 'philippians',
  signLabel: 'فيلبي',
  destination: _rome,
);

final class _DestinationCardTest extends StatelessWidget {
  final bool hasMore;
  final String? verse;
  final VoidCallback onReveal;
  final VoidCallback onAdvance;

  const _DestinationCardTest({
    required this.hasMore,
    required this.onReveal,
    required this.onAdvance,
    this.verse = 'آية',
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: DestinationCard(
        level: _level,
        verse: verse,
        hasMore: hasMore,
        onReveal: onReveal,
        onAdvance: onAdvance,
      ),
    ),
  );
}

void main() {
  testWidgets('a card with more to give opens further on a tap', (
    tester,
  ) async {
    var revealed = 0;
    var advanced = 0;

    await tester.pumpWidget(
      _DestinationCardTest(
        hasMore: true,
        onReveal: () => revealed++,
        onAdvance: () => advanced++,
      ),
    );
    await tester.tap(find.byType(DestinationCard));

    expect(revealed, 1);
    expect(advanced, 0);
  });

  testWidgets('a fully open card steps the script instead', (tester) async {
    var revealed = 0;
    var advanced = 0;

    await tester.pumpWidget(
      _DestinationCardTest(
        hasMore: false,
        onReveal: () => revealed++,
        onAdvance: () => advanced++,
      ),
    );
    await tester.tap(find.byType(DestinationCard));

    expect(advanced, 1);
    expect(revealed, 0);
  });

  testWidgets('the card makes room for its revealed verse', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const _DestinationCardTest(
        hasMore: false,
        verse: null,
        onReveal: _never,
        onAdvance: _never,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final signOnlyHeight = tester.getSize(find.byType(PixelPanel)).height;

    await tester.pumpWidget(
      const _DestinationCardTest(
        hasMore: false,
        onReveal: _never,
        onAdvance: _never,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final panel = tester.getSize(find.byType(PixelPanel));

    expect(panel.height, greaterThan(signOnlyHeight));
    expect(panel.height, lessThan(200));
  });

  testWidgets('the card replaces a verse instead of adding another', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _DestinationCardTest(
        hasMore: false,
        verse: 'الآية الأولى',
        onReveal: _never,
        onAdvance: _never,
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.pumpWidget(
      const _DestinationCardTest(
        hasMore: false,
        verse: 'الآية الثانية',
        onReveal: _never,
        onAdvance: _never,
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('الآية الأولى'), findsNothing);
    expect(find.text('الآية الثانية'), findsOneWidget);
  });

  testWidgets(
    "the sign shows the letter's name, not the stop it stands at",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DestinationCard(
              level: _prisonLevel,
              verse: null,
              hasMore: false,
              onReveal: _never,
              onAdvance: _never,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(_prisonLevel.signLabel), findsOneWidget);
      expect(find.text(_prisonLevel.destination.label), findsNothing);
    },
  );
}

void _never() {
  fail('the layout test never taps the card');
}

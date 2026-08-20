import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/geo_position.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/destination_card.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


const GameCharacter _writer = GameCharacter(
  id: 'paul',
  name: 'بولس',
  portraitAsset: 'assets/characters/paul-avatar.jpg',
);

const JourneyStop _stop = JourneyStop(
  id: 'thessalonica',
  label: 'تسالونيكي',
  position: GeoPosition(latitude: 40.64, longitude: 22.94),
);

const GameLevel _level = GameLevel(
  id: 'thessalonians-1',
  title: 'تسالونيكي الأولى',
  destination: _stop,
  year: 52,
  verses: ['آية'],
);

final class _CardUnderTest extends StatelessWidget {
  final bool hasMore;
  final List<String> verses;
  final VoidCallback onReveal;
  final VoidCallback onAdvance;

  const _CardUnderTest({
    required this.hasMore,
    required this.onReveal,
    required this.onAdvance,
    this.verses = const ['آية'],
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: DestinationCard(
        level: _level,
        destinationLabel: _stop.label,
        verses: verses,
        versesSpeaker: _writer,
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
      _CardUnderTest(
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
      _CardUnderTest(
        hasMore: false,
        onReveal: () => revealed++,
        onAdvance: () => advanced++,
      ),
    );
    await tester.tap(find.byType(DestinationCard));

    expect(advanced, 1);
    expect(revealed, 0);
  });

  testWidgets('the card grows for its revealed verses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const _CardUnderTest(
        hasMore: false,
        verses: [],
        onReveal: _never,
        onAdvance: _never,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final signOnlyHeight = tester.getSize(find.byType(PixelPanel)).height;

    await tester.pumpWidget(
      const _CardUnderTest(
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
}

void _never() {
  fail('the layout test never taps the card');
}

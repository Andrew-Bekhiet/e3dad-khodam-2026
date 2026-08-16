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
  imageAsset: 'assets/levels/thessalonians.jpg',
  verses: ['آية'],
);

/// The card on its own, with nothing else on screen to take a tap.
final class _CardUnderTest extends StatelessWidget {
  final bool hasMore;
  final VoidCallback onReveal;
  final VoidCallback onAdvance;

  const _CardUnderTest({
    required this.hasMore,
    required this.onReveal,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: DestinationCard(
        level: _level,
        destinationLabel: _stop.label,
        showsImage: false,
        verses: const ['آية'],
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

  testWidgets('the card fills the screen but for a small margin', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const _CardUnderTest(
        hasMore: false,
        onReveal: _never,
        onAdvance: _never,
      ),
    );
    final card = tester.getSize(find.byType(DestinationCard));
    final panel = tester.getSize(find.byType(PixelPanel));

    expect(panel.width, greaterThan(card.width - 40));
    expect(panel.height, greaterThan(card.height - 40));
  });
}

void _never() {
  fail('the layout test never taps the card');
}

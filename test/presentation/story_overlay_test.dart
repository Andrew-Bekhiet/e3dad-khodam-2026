import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/story_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const GameCharacter _guide = GameCharacter(
  id: 'guide',
  name: 'الرحلة',
  portraitAsset: 'assets/characters/guide.jpg',
);

const GameCharacter _narrator = GameCharacter(
  id: 'narrator',
  name: 'الراوي',
  portraitAsset: 'assets/characters/narrator.jpg',
);

/// A line distinctive enough that finding it in the tree can only mean it
/// was actually painted, not a coincidental match against other copy.
const String _line = 'نص مميز للاختبار لا يظهر إلا إذا رُسم فعلاً';

Future<void> _pumpOverlay(WidgetTester tester, StoryBeat beat) =>
    tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: StoryOverlay(
            guide: _guide,
            narrator: _narrator,
            beat: beat,
            onAdvance: _never,
          ),
        ),
      ),
    );

void main() {
  testWidgets(
    'StoryOverlay_aGuideBeat_neverPaintsItsText',
    (tester) async {
      await _pumpOverlay(tester, const StoryBeat.guide(_line));
      await tester.pump(StoryOverlay.switchDuration);

      expect(find.text(_line), findsNothing);
    },
  );

  testWidgets(
    'StoryOverlay_aNarratorBeat_paintsItsText',
    (tester) async {
      await _pumpOverlay(tester, const StoryBeat.narrator(_line));
      await tester.pump(StoryOverlay.switchDuration);

      expect(find.text(_line), findsOneWidget);
    },
  );
}

void _never() {
  fail('the overlay test never advances the script');
}

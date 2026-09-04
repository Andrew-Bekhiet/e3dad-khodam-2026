import 'package:e3dad_khodam_2026/src/app/app_theme.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_characters.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_level.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/destination_card.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/guide_dialogue_panel.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/narrator_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// These guards are deliberately pessimistic. A widget test lays text
/// out in a fixed-width test font rather than Cairo, so every line
/// measures wider here than it draws on a screen: a layout that fits
/// under these tests has room to spare in the app. The same property is
/// why there is no big-screen overflow guard — at display sizes the test
/// font alone overflows any window, so such a test would report on the
/// font instead of on the design.
///
/// A phone held upright, and the same phone turned on its side.
///
/// Landscape is the tighter of the two and the one a width-only
/// breakpoint gets wrong: it is the *wider* viewport of the pair, so a
/// rule reading width alone calls it a desktop and hands it projector
/// type in 390 logical pixels of height.
const Size _phonePortrait = Size(390, 844);
const Size _phoneLandscape = Size(844, 390);

/// A laptop window — comfortably the large class, and the size the
/// story text is actually authored for.
const Size _desktop = Size(1440, 900);

/// What the room is shown, in logical pixels.
///
/// Written as numbers rather than read back off the theme: the promise
/// is that a big screen keeps these *absolute* sizes, so a change to
/// which `TextTheme` slot a panel reaches for must fail this, not follow
/// it silently.
const double _narratorBodySize = 45.0;
const double _verseSize = 36.0;

/// The level with the longest single verse, found rather than named.
///
/// The guard has to follow the script: naming تسالونيكي here would keep
/// passing on the day someone writes a longer letter, which is the exact
/// day it is meant to fail.
GameLevel get _wordiestLevel => PostOfficeScript.levels.reduce(
  (a, b) => _longestVerseLength(b) > _longestVerseLength(a) ? b : a,
);

int _longestVerseLength(GameLevel level) => level.verses.fold(
  0,
  (longest, verse) => verse.length > longest ? verse.length : longest,
);

/// Every beat the script contains, in no particular order.
List<StoryBeat> get _allBeats => [
  ...PostOfficeScript.script.prologue,
  ...PostOfficeScript.script.epilogue,
  for (final level in PostOfficeScript.levels) ...[
    ...level.briefing,
    ...level.clearance,
  ],
];

/// The longest thing the narrator says anywhere in the script.
///
/// Only the narrator's text is ever painted — the guide's line is spoken
/// live on stage — so the narrator is the only speaker whose card needs
/// an overflow guard driven by line length.
StoryBeat get _longestNarratorBeat => _allBeats
    .where((beat) => beat.speaker == StorySpeaker.narrator)
    .reduce((a, b) => b.text.length > a.text.length ? b : a);

/// Renders [child] on a screen of [size] and returns whatever it threw.
///
/// An overflowing `RenderFlex` reports through the error handler rather
/// than by throwing out of `pump`, so the check is `takeException`, not
/// a `try`.
Future<Object?> _renderAt(
  WidgetTester tester,
  Size size,
  Widget child, {
  double appBarHeight = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          // The whole window is what decides the size class, so the bar
          // has to be real rather than subtracted from the size passed
          // in: shrinking the viewport to model a body would drop the
          // panel into the compact class and test nothing.
          appBar: appBarHeight == 0
              ? null
              : PreferredSize(
                  preferredSize: Size.fromHeight(appBarHeight),
                  child: SizedBox(height: appBarHeight),
                ),
          body: child,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));

  return tester.takeException();
}

/// Renders [level]'s card on its final verse and returns whatever it threw.
///
/// Wrapped up as one call rather than a widget-returning helper so the
/// card is built where it is used; a bare function handing back a widget
/// is an anti-pattern the linter is right about.
Future<Object?> _renderCardAt(
  WidgetTester tester,
  Size size,
  GameLevel level,
) => _renderAt(
  tester,
  size,
  DestinationCard(
    level: level,
    verse: level.verses.isEmpty ? null : level.verses.last,
    hasMore: false,
    onReveal: _neverRevealed,
    onAdvance: _neverStepped,
  ),
);

/// Passed where the card wants a reveal callback it will never call:
/// `hasMore` is false, so the card is already as open as it goes.
void _neverRevealed() {
  assert(false, 'a fully open card has nothing left to reveal');
}

/// Passed where the card wants a step callback: these tests measure how
/// the card lays out and never tap it.
void _neverStepped() {
  assert(false, 'the layout tests never tap the card');
}

/// The rendered size of [text]'s font, as laid out.
double? _fontSizeOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.textContaining(text)).style?.fontSize;

void main() {
  group('DestinationCard', () {
    testWidgets('the wordiest level fits a phone held upright', (tester) async {
      final error = await _renderCardAt(
        tester,
        _phonePortrait,
        _wordiestLevel,
      );

      expect(error, isNull);
    });

    testWidgets('the wordiest level fits a phone on its side', (tester) async {
      final error = await _renderCardAt(
        tester,
        _phoneLandscape,
        _wordiestLevel,
      );

      expect(error, isNull);
    });

    testWidgets('every level fits a phone, not merely the worst', (
      tester,
    ) async {
      for (final level in PostOfficeScript.levels) {
        final error = await _renderCardAt(tester, _phonePortrait, level);

        expect(error, isNull, reason: 'level ${level.id} overflowed');
      }
    });
  });

  group('story panels fit a phone', () {
    testWidgets('the narrator card', (tester) async {
      final error = await _renderAt(
        tester,
        _phoneLandscape,
        NarratorCard(
          character: PostOfficeCharacters.narrator,
          beat: _longestNarratorBeat,
        ),
      );

      expect(error, isNull);
    });

    testWidgets('the guide dialogue panel, held upright', (tester) async {
      final error = await _renderAt(
        tester,
        _phonePortrait,
        const GuideDialoguePanel(
          character: PostOfficeCharacters.guide,
          beat: StoryBeat.guide('نص لا يُرسم على الشاشة'),
        ),
      );

      expect(error, isNull);
    });

    testWidgets('the guide dialogue panel, on its side', (tester) async {
      final error = await _renderAt(
        tester,
        _phoneLandscape,
        const GuideDialoguePanel(
          character: PostOfficeCharacters.guide,
          beat: StoryBeat.guide('نص لا يُرسم على الشاشة'),
        ),
      );

      expect(error, isNull);
    });
  });

  group('a big screen keeps the sizes the room was shown', () {
    testWidgets('the narrator speaks at displayMedium', (tester) async {
      await _renderAt(
        tester,
        _desktop,
        NarratorCard(
          character: PostOfficeCharacters.narrator,
          beat: _longestNarratorBeat,
        ),
      );

      expect(
        _fontSizeOf(tester, _longestNarratorBeat.text),
        _narratorBodySize,
      );
    });

    testWidgets('a verse is set at displaySmall', (tester) async {
      final level = _wordiestLevel;
      await _renderCardAt(tester, _desktop, level);

      expect(_fontSizeOf(tester, level.verses.last), _verseSize);
    });
  });
}

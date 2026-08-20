import 'package:e3dad_khodam_2026/src/data/audio/audioplayers_game_sounds.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_builder.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_surface_spec.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/pages/game_journey_page.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/guide_callout.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/guide_dialogue_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for a real map: the surface is a platform view, which a
/// widget test cannot render, and none of these tests are about the map.
///
/// A tear-off of a widget constructor, per `MapSurfaceBuilder`'s own doc:
/// a bare function returning a widget is flagged by the linter.
final class _BlankSurface extends StatelessWidget {
  final MapSurfaceSpec spec;

  const _BlankSurface(this.spec);

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

const MapSurfaceBuilder _blankSurface = _BlankSurface.new;

/// How many times the map has been handed a spec to draw.
///
/// The map is a platform view: every one of these is a fresh spec over
/// the channel, so the count is the cost of a rebuild rather than a proxy
/// for it.
int _surfaceBuilds = 0;

Widget _countingSurface(MapSurfaceSpec spec) {
  _surfaceBuilds++;

  return _BlankSurface(spec);
}

/// The game screen with its dependencies stubbed.
final class _GameUnderTest extends StatelessWidget {
  final MapSurfaceBuilder surfaceBuilder;

  const _GameUnderTest({this.surfaceBuilder = _blankSurface});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<LevelScriptRepository>.value(
        value: const StaticLevelScriptRepository(),
      ),
      RepositoryProvider<GameSounds>.value(
        value: await AudioPlayersGameSounds.create(),
      ),
      RepositoryProvider<MapSurfaceBuilder>.value(value: surfaceBuilder),
    ],
    // The app runs right-to-left; the bubble anchors on the start edge,
    // so the direction is load-bearing for where it lands.
    child: const Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(home: GameJourneyPage()),
    ),
  );
}

/// The cubit driving the page under test.
GameJourneyCubit _cubitOf(WidgetTester tester) =>
    tester.element(find.byType(Scaffold)).read<GameJourneyCubit>();

/// Taps the map itself, as the real surface does when a tap lands on no
/// marker. The gesture cannot be made with the tester: the real surface
/// is a platform view that hit-tests inside the renderer, so the seam it
/// reports through is the thing to drive.
void _tapTheMap(WidgetTester tester) {
  final spec = tester.widget<_BlankSurface>(find.byType(_BlankSurface)).spec;
  expect(spec.onSurfaceTap, isNotNull, reason: 'the map should take taps');
  spec.onSurfaceTap?.call();
}

/// Steps the script until a beat of [emphasis] is showing.
void _advanceUntil(WidgetTester tester, BeatEmphasis emphasis) {
  final cubit = _cubitOf(tester);
  for (var press = 0; press < 60; press++) {
    if (cubit.state.beat?.emphasis == emphasis) {
      return;
    }
    cubit.forward();
  }
  fail('never reached a $emphasis beat');
}

/// The app bar's height as the page asked for it; an unset height is
/// `kToolbarHeight`, which is what the page means by leaving it alone.
double _appBarHeight(WidgetTester tester) =>
    tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight ?? kToolbarHeight;

/// Runs the app bar's growth all the way to its end.
///
/// Written out rather than `pumpAndSettle`: the card's chevron pulses on
/// a repeating controller, so nothing on this screen ever settles. The
/// second pump is what lets the growth's ticker take its start time —
/// one long pump alone lands on the frame the ticker starts on, and
/// reads back the height it began at.
Future<void> _growTheBar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('GameJourneyPage_theOpeningShot_saysNothing', (tester) async {
    await tester.pumpWidget(const _GameUnderTest());
    await tester.pump();

    expect(tester.takeException(), isNull);
    // The map, framed on the post office, with nobody talking over it.
    expect(find.byType(GuideDialoguePanel), findsNothing);
    expect(find.byType(GuideCallout), findsNothing);
  });

  testWidgets('GameJourneyPage_thePrologue_showsTheGuidesPanelAfterTheFlight', (
    tester,
  ) async {
    await tester.pumpWidget(const _GameUnderTest());
    final cubit = _cubitOf(tester);

    cubit
      ..forward()
      ..forward();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.byType(GuideDialoguePanel), findsOneWidget);
  });

  testWidgets('GameJourneyPage_aGuideCallout_isActuallyOnScreen', (
    tester,
  ) async {
    await tester.pumpWidget(const _GameUnderTest());
    final cubit = _cubitOf(tester);

    // Walk forward until a beat wants the bubble rather than the panel.
    for (var press = 0; press < 60; press++) {
      if (cubit.state.beat?.emphasis == BeatEmphasis.callout) {
        break;
      }
      cubit.forward();
    }
    expect(
      cubit.state.beat?.emphasis,
      BeatEmphasis.callout,
      reason: 'never reached a beat that wants the bubble',
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GuideCallout), findsOneWidget);
    // The symptom: the dialogue never appears, because painting it throws
    // and the frame's layer tree is dropped.
    expect(tester.takeException(), isNull);

    // And it is aimed at her, not merely on screen: the tail sits over
    // the portrait in the app bar.
    final callout = tester.widget<GuideCallout>(find.byType(GuideCallout));
    final avatar = tester.getRect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(CharacterPortrait),
      ),
    );
    expect(callout.tailCentreX, isNotNull);
    expect(
      callout.tailCentreX,
      inInclusiveRange(avatar.left, avatar.right),
      reason: 'the tail should point at the guide, not past her',
    );
  });

  group('the guide only takes the extra height while she is talking', () {
    /// Big enough to be the large class in both dimensions.
    const Size bigScreen = Size(1400, 1000);

    Future<void> pumpBig(WidgetTester tester) async {
      tester.view.physicalSize = bigScreen;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const _GameUnderTest());
      await tester.pump();
    }

    testWidgets('the opening shot leaves the bar alone', (tester) async {
      await pumpBig(tester);

      expect(_appBarHeight(tester), kToolbarHeight);
    });

    testWidgets('a callout raises it', (tester) async {
      await pumpBig(tester);
      _advanceUntil(tester, BeatEmphasis.callout);
      await _growTheBar(tester);

      expect(_appBarHeight(tester), greaterThan(kToolbarHeight));
    });

    testWidgets('and it grows into it rather than jumping', (tester) async {
      await pumpBig(tester);
      _advanceUntil(tester, BeatEmphasis.callout);
      // The frame the bubble arrives on, then one part-way through the
      // growth: the bar is on its way up rather than already there.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      final started = _appBarHeight(tester);
      await tester.pump(const Duration(milliseconds: 20));
      final partWay = _appBarHeight(tester);
      await tester.pump(const Duration(milliseconds: 400));

      expect(started, kToolbarHeight);
      expect(partWay, greaterThan(started));
      expect(partWay, lessThan(_appBarHeight(tester)));
    });

    testWidgets('a panel beat does not, having its own portrait', (
      tester,
    ) async {
      await pumpBig(tester);
      _advanceUntil(tester, BeatEmphasis.panel);
      await _growTheBar(tester);

      expect(_appBarHeight(tester), kToolbarHeight);
    });

    testWidgets('and the map underneath is not redrawn while it grows', (
      tester,
    ) async {
      _surfaceBuilds = 0;
      // Taller than the rest of the group: this test walks to a card
      // carrying two letters' verses, and it is measuring redraws rather
      // than layout — an overflow there would fail it for the wrong
      // reason.
      tester.view.physicalSize = const Size(1400, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const _GameUnderTest(surfaceBuilder: _countingSurface),
      );
      await tester.pump();

      final cubit = _cubitOf(tester);
      // Twelve presses lands on تسالونيكي's second letter, one press short
      // of its bubble. That level is not swept into, so the camera holds
      // across the press that raises her — leaving the bar's growth as the
      // only thing moving, which is what makes the count mean anything.
      for (var press = 0; press < 12; press++) {
        cubit.forward();
      }
      for (var second = 0; second < 5; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      final camera = cubit.state.camera;

      cubit.forward();
      expect(cubit.state.beat?.emphasis, BeatEmphasis.callout);
      expect(cubit.state.camera, camera, reason: 'the camera must hold');

      // Two frames: the one the bubble arrives on, where the map may
      // redraw because the game state genuinely changed, and the one
      // after it, which is where the cubit's own notification lands.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      final before = _surfaceBuilds;

      // From here nothing is happening but the bar growing.
      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(
        _surfaceBuilds - before,
        0,
        reason: 'the growing bar redrew the map beneath it',
      );
      expect(
        _appBarHeight(tester),
        greaterThan(kToolbarHeight),
        reason: 'the bar really did grow, so the count above means something',
      );
    });
  });

  group('a tap on the map steps the script', () {
    testWidgets('from the opening shot, which nothing else covers', (
      tester,
    ) async {
      await tester.pumpWidget(const _GameUnderTest());
      await tester.pump();
      final cubit = _cubitOf(tester);
      final before = cubit.state.stepIndex;

      _tapTheMap(tester);
      await tester.pump();

      expect(cubit.state.stepIndex, before + 1);
    });

    testWidgets('but not while the camera is still flying', (tester) async {
      await tester.pumpWidget(const _GameUnderTest());
      await tester.pump();
      final cubit = _cubitOf(tester);
      // The first press sets off the sweep out of الإسماعيلية.
      _tapTheMap(tester);
      await tester.pump();
      final midFlight = cubit.state.stepIndex;

      _tapTheMap(tester);
      await tester.pump();

      expect(cubit.state.stepIndex, midFlight);
    });

    testWidgets('including a tap that lands on a city', (tester) async {
      await tester.pumpWidget(const _GameUnderTest());
      await tester.pump();
      final cubit = _cubitOf(tester);
      final spec = tester
          .widget<_BlankSurface>(find.byType(_BlankSurface))
          .spec;
      final stop = cubit.state.currentStop;
      if (stop == null) {
        fail('the opening shot stands somewhere');
      }
      final before = cubit.state.stepIndex;

      // A city is a press like any other: jumping to the level it
      // belongs to would skip every level in between.
      spec.onMarkerTap(stop.id);
      await tester.pump();

      expect(cubit.state.stepIndex, before + 1);
      expect(tester.takeException(), isNull);
    });
  });
}

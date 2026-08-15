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

/// The game screen with its dependencies stubbed.
final class _GameUnderTest extends StatelessWidget {
  const _GameUnderTest();

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<LevelScriptRepository>.value(
        value: const StaticLevelScriptRepository(),
      ),
      RepositoryProvider<GameSounds>.value(value: const SilentGameSounds()),
      RepositoryProvider<MapSurfaceBuilder>.value(value: _blankSurface),
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
}

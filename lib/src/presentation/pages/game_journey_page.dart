import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/city_overlay.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_map_view.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/level_hud.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/story_overlay.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/map_arrow_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The game screen: the same pixel map, walked as fourteen levels, with
/// the guide and the narrator talking over it between them.
final class GameJourneyPage extends StatelessWidget {
  /// Creates the game screen.
  const GameJourneyPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => GameJourneyCubit(
      context.read<LevelScriptRepository>(),
      sounds: context.read<GameSounds>(),
    ),
    child: const _GameJourneyView(),
  );
}

/// The screen's body, split out so it can own the keyboard focus node
/// while `GameJourneyPage` stays the stateless provider boundary.
final class _GameJourneyView extends StatefulWidget {
  const _GameJourneyView();

  @override
  State<_GameJourneyView> createState() => _GameJourneyViewState();
}

class _GameJourneyViewState extends State<_GameJourneyView> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'game-journey-keys');

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameJourneyCubit>();
    final state = cubit.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.gameTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            tooltip: AppStrings.restartTooltip,
            onPressed: cubit.restart,
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) => _onKeyEvent(cubit, event),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const GameMapView(),
            if (state.isPlaying && state.level != null)
              CityOverlay(
                level: state.level!,
                cityLabel: state.currentStop?.label ?? '',
                verses: state.revealedVerses,
                versesSpeaker: cubit.letterWriter,
                hasMoreVerses: state.hasMoreVerses,
                onRevealVerse: cubit.revealNextVerse,
              ),
            LevelHud(state: state),
            StoryOverlay(
              guide: cubit.guide,
              narrator: cubit.narrator,
              beat: state.beat,
              onAdvance: () => _step(cubit, forward: true),
            ),
            _Arrows(
              state: state,
              onBackward: () => _step(cubit, forward: false),
              onForward: () => _step(cubit, forward: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Left and right walk the script, space and enter advance it, down
  /// and up work the level's verses, and escape leaves the game.
  /// Left/right are not mirrored for RTL: they match the on-screen
  /// arrows, which are not mirrored either.
  KeyEventResult _onKeyEvent(GameJourneyCubit cubit, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        _step(cubit, forward: true);

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.backspace:
        _step(cubit, forward: false);

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        cubit.revealNextVerse();

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        cubit.hideLastVerse();

        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        Navigator.of(context).maybePop();

        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  /// Steps the script and takes the keyboard focus back, so a tap on the
  /// map or a button does not leave the arrow keys dead afterwards.
  void _step(GameJourneyCubit cubit, {required bool forward}) {
    forward ? cubit.forward() : cubit.backward();
    _focusNode.requestFocus();
  }
}

/// The on-screen step arrows, framed to match the game's panels and kept
/// above the story overlay so they stay usable while someone is talking.
final class _Arrows extends StatelessWidget {
  final GameJourneyState state;
  final VoidCallback onBackward;
  final VoidCallback onForward;

  const _Arrows({
    required this.state,
    required this.onBackward,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) => PositionedDirectional(
    end: 12,
    bottom: 12,
    child: SafeArea(
      child: PixelPanel(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: MapArrowControls(
          onBackward: onBackward,
          onForward: onForward,
          canGoBackward: !state.isAtStart,
          canGoForward: !state.isAtEnd,
        ),
      ),
    ),
  );
}

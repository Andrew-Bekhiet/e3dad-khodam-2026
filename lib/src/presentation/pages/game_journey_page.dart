import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/destination_card.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_map_view.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/story_overlay.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_overlay.dart';
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

/// The screen's body, split out so it can own the keyboard focus node and
/// the sweep's clock while `GameJourneyPage` stays the stateless provider
/// boundary.
final class _GameJourneyView extends StatefulWidget {
  const _GameJourneyView();

  @override
  State<_GameJourneyView> createState() => _GameJourneyViewState();
}

class _GameJourneyViewState extends State<_GameJourneyView>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'game-journey-keys');

  /// Runs from 0 to 1 across a whole sweep. Drives the couriers walking,
  /// their trail drawing itself behind them, and the streaks over the
  /// map — all three are the same movement, so they share one clock.
  late final AnimationController _sweep = AnimationController(vsync: this);

  /// Presses made while the camera was still flying.
  ///
  /// The operator drives this like a slideshow and will press ahead of
  /// the animation. Dropping those presses would make the game feel
  /// deaf, so they are held and applied the moment the sweep lands.
  int _pressesDuringSweep = 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameJourneyCubit>();
    final state = cubit.state;

    return BlocListener<GameJourneyCubit, GameJourneyState>(
      listenWhen: (previous, current) => previous.camera != current.camera,
      listener: (context, state) => _onCameraChanged(state),
      child: Scaffold(
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
              GameMapView(sweepProgress: _sweep),
              SweepOverlay(progress: _sweep),
              if (state.level != null && !state.isArriving)
                DestinationCard(
                  level: state.level!,
                  destinationLabel: state.currentStop?.label ?? '',
                  showsImage: state.showsImage,
                  verses: state.revealedVerses,
                  versesSpeaker: cubit.letterWriter,
                  hasMore: state.hasMoreReveal,
                  onReveal: cubit.revealNext,
                ),
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
      ),
    );
  }

  @override
  void dispose() {
    _sweep.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Starts the sweep clock when the camera is given one to fly, and
  /// parks it otherwise so nothing is drawn over a still map.
  void _onCameraChanged(GameJourneyState state) {
    final sweep = state.sweep;
    if (sweep == null) {
      _sweep
        ..stop()
        ..value = 0;

      return;
    }
    _sweep
      ..duration = sweep.total
      ..forward(from: 0).then((_) => _drainPresses());
  }

  /// Applies whatever was pressed while the camera was flying.
  void _drainPresses() {
    if (!mounted || _pressesDuringSweep == 0) {
      return;
    }
    final cubit = context.read<GameJourneyCubit>();
    final pending = _pressesDuringSweep;
    _pressesDuringSweep = 0;
    for (var press = 0; press < pending; press++) {
      cubit.forward();
    }
  }

  /// Left and right walk the script, space and enter advance it, down and
  /// up work the card, and escape leaves the game. Left/right are not
  /// mirrored for RTL: they match the on-screen arrows, which are not
  /// mirrored either.
  KeyEventResult _onKeyEvent(GameJourneyCubit cubit, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.arrowDown:
        _step(cubit, forward: true);

        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.backspace:
      case LogicalKeyboardKey.arrowUp:
        _step(cubit, forward: false);

        return KeyEventResult.handled;

      case LogicalKeyboardKey.escape:
        Navigator.of(context).maybePop();

        return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Steps the script and takes the keyboard focus back, so a tap on the
  /// map or a button does not leave the arrow keys dead afterwards.
  ///
  /// A press made mid-sweep is queued rather than applied: the sweep is
  /// one movement and cutting it short mid-flight leaves the camera
  /// somewhere nobody asked for.
  void _step(GameJourneyCubit cubit, {required bool forward}) {
    _focusNode.requestFocus();
    if (_sweep.isAnimating) {
      if (forward) {
        _pressesDuringSweep++;
      }

      return;
    }
    forward ? cubit.forward() : cubit.backward();
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

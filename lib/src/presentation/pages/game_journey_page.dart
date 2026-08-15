import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
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
    // Resolved here, where a context certainly has one, rather than
    // looked up inside the view: the view has to silence the travelling
    // loop from `dispose`, by which point its own context is gone.
    child: _GameJourneyView(sounds: context.read<GameSounds>()),
  );
}

/// The screen's body, split out so it can own the keyboard focus node and
/// the sweep's clock while `GameJourneyPage` stays the stateless provider
/// boundary.
final class _GameJourneyView extends StatefulWidget {
  final GameSounds sounds;

  const _GameJourneyView({required this.sounds});

  @override
  State<_GameJourneyView> createState() => _GameJourneyViewState();
}

class _GameJourneyViewState extends State<_GameJourneyView>
    with SingleTickerProviderStateMixin {
  /// Edge of the guide's portrait in the app bar. Small enough to sit in
  /// a toolbar, big enough to read as a face — and `GuideCallout` points
  /// its tail at the middle of it.
  static const double _guideAvatarSize = 40.0;

  final FocusNode _focusNode = FocusNode(debugLabel: 'game-journey-keys');

  /// Ties the guide's speech bubble to her portrait above it, so the tail
  /// points at her wherever the app bar decides to put her.
  final LayerLink _guideLink = LayerLink();

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

  /// The step the camera last moved for, so a move can tell which way it
  /// went.
  int _cameraStep = 0;

  GameSounds get _sounds => widget.sounds;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameJourneyCubit>();
    final state = cubit.state;

    return BlocListener<GameJourneyCubit, GameJourneyState>(
      listenWhen: (previous, current) => previous.camera != current.camera,
      listener: (context, state) => _onCameraChanged(state),
      child: Scaffold(
        appBar: AppBar(
          // Left where the title starts rather than centred: the bubble
          // hangs from the start edge, and a centred portrait would leave
          // its tail pointing across the middle of the screen at it.
          centerTitle: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CompositedTransformTarget(
                link: _guideLink,
                child: CharacterPortrait(
                  character: cubit.guide,
                  size: _guideAvatarSize,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(child: Text(AppStrings.gameTitle)),
            ],
          ),
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
              // Gated on the card being open, not merely on there being
              // a level: a cleared level still has one, and its card
              // must be gone before the clearance line and the next
              // sweep.
              if (state.showsCard)
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
                guideLink: _guideLink,
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
    _sounds.stopWalking();
    _sweep.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Starts the sweep clock when the camera is given one to fly, and
  /// parks it otherwise so nothing is drawn over a still map.
  ///
  /// The travelling loop rides the same clock, so it starts and stops
  /// exactly where the movement does — including the parked branch, which
  /// is how a journey cut short still falls silent.
  void _onCameraChanged(GameJourneyState state) {
    final arriving = state.stepIndex > _cameraStep;
    _cameraStep = state.stepIndex;
    final sweep = state.sweep;
    if (sweep == null) {
      _sounds.stopWalking();
      _sweep
        ..stop()
        ..value = 0;

      return;
    }
    // The loop rides the movement either way, because the movement is on
    // screen either way. The arrival sting does not: see [_onSweepLanded].
    _sounds.startWalking();
    _sweep
      ..duration = sweep.total
      ..forward(from: 0).then((_) => _onSweepLanded(arriving: arriving));
  }

  /// The party has stopped moving. A `TickerFuture` only completes when
  /// the animation runs its whole course, so an interrupted sweep never
  /// gets here — which is the point: nothing was reached.
  ///
  /// Only a forward move *arrives* anywhere. Stepping back re-flies a
  /// sweep already seen, and ringing the arrival again would contradict
  /// the clearance and departure stings, which the cubit deliberately
  /// keeps quiet when the journey is being reviewed rather than lived.
  void _onSweepLanded({required bool arriving}) {
    if (!mounted) {
      return;
    }
    _sounds.stopWalking();
    if (arriving) {
      _sounds.playLevelReached();
    }
    _drainPresses();
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
  /// A forward press made mid-sweep is queued rather than applied: the
  /// sweep is one movement, and cutting it short leaves the camera
  /// somewhere nobody asked for.
  ///
  /// A backward press mid-sweep is dropped, not queued. Queueing it
  /// would land the camera and immediately fly it back out again, which
  /// is worse than ignoring a key pressed during a second of animation.
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

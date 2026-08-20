import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/sweep_framing.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/character_portrait.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/destination_card.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_map_view.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/guide_dialogue_panel.dart'
    show GuideDialoguePanel;
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
  /// Edge of the guide's portrait in the app bar. `GuideCallout` points
  /// its tail at the middle of it, whichever size it is: the tail is
  /// measured off the laid-out box rather than assumed, so it follows
  /// this on its own.
  ///
  /// She is only given the larger size on a big screen and only while a
  /// bubble is hanging off her, because the height comes out of the map
  /// and out of whatever else is on screen. A `BeatEmphasis.panel` beat
  /// is deliberately not counted: that panel carries its own portrait at
  /// [GuideDialoguePanel] size, so growing the bar behind its scrim would
  /// cost height to show a second, smaller copy of the same face.
  static const double _guideAvatarCompact = 40.0;
  static const double _guideAvatarLarge = 120.0;

  /// Clearance above and below the portrait. The app bar is sized from
  /// the portrait plus this, so the portrait is the only number to
  /// change when tuning how big she should be — set it alone and the bar
  /// grows to hold her instead of clipping her.
  ///
  /// At [_guideAvatarCompact] the sum is exactly `kToolbarHeight`.
  static const double _guideAvatarClearance = 16.0;

  /// How long the bar takes to grow around her and settle back.
  ///
  /// Short on purpose: this is chrome moving out of the way of a line
  /// somebody is about to read, not something to watch. `CharacterPortrait`
  /// eases its own frame on top of this, so the face lands a beat after
  /// the bar rather than snapping with it.
  static const Duration _guideAvatarGrow = Duration(milliseconds: 100);

  final FocusNode _focusNode = FocusNode(debugLabel: 'game-journey-keys');

  /// Finds the guide's portrait so her bubble's tail can point at it.
  ///
  /// Measured rather than linked: a `LayerLink` cannot reach from an app
  /// bar into a body, because `Scaffold` paints the body first and the
  /// bar over it, and a follower painted before its leader trips a
  /// framework assertion that takes the whole overlay off the screen.
  final GlobalKey _guideAvatarKey = GlobalKey();

  /// Where that portrait sits, in global x.
  ///
  /// A notifier rather than a field behind `setState`, because it is
  /// re-read on every frame the bar is growing. Calling `setState` for it
  /// would rebuild this whole widget — and with it the map, which is a
  /// platform view being handed a fresh spec sixty times a second for a
  /// number only the bubble's tail cares about.
  final ValueNotifier<double?> _guideAnchorX = ValueNotifier(null);

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

  /// How many of those are kept. An arrow key held down repeats about
  /// thirty times a second, and replaying three seconds of that would
  /// walk the script past the level the operator was waiting for.
  static const int _maxQueuedPresses = 3;

  GameSounds get _sounds => widget.sounds;

  @override
  void initState() {
    super.initState();
    _reaimTheTail();
    _playSoundOnSweepAnimation();
  }

  void _playSoundOnSweepAnimation() {
    _sweep.addStatusListener(_sweepSoundListener);
  }

  Future<void> _sweepSoundListener(AnimationStatus status) async {
    if (status == AnimationStatus.forward) {
      final sweepOutDuration = context
          .read<GameJourneyCubit>()
          .state
          .sweep
          ?.outLeg;
      await Future.delayed(sweepOutDuration ?? Duration.zero);

      _sounds.startWalking();
    } else if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _sounds.stopWalking();
      if (status == AnimationStatus.completed) _sounds.playLevelReached();
    }
  }

  /// Re-reads where the portrait is after the frame that moved it.
  ///
  /// She slides as the bar grows, so the tail has to be re-aimed for as
  /// long as that lasts — which is why the answer lives in a notifier
  /// rather than in this widget's state.
  void _reaimTheTail() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _findGuideAvatar());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameJourneyCubit>();
    final screen = GameScreenSize.of(context);
    // Read here rather than in the cubit: how much screen there is is a
    // fact about the viewport, and the cubit has none.
    cubit.sweepFraming = screen.pick(
      compact: SweepFraming.leg,
      large: SweepFraming.basin,
    );
    final state = cubit.state;
    final beat = state.beat;
    final guideHasABubbleUp =
        beat != null &&
        beat.speaker == StorySpeaker.guide &&
        beat.emphasis == BeatEmphasis.callout;
    final guideAvatarSize = guideHasABubbleUp
        ? screen.pick(compact: _guideAvatarCompact, large: _guideAvatarLarge)
        : _guideAvatarCompact;

    // Built outside the builder below so the same widget instance is
    // handed back on every frame of the bar's growth: the element sees an
    // identical child and skips the whole subtree, which is what keeps the
    // map off a 200ms rebuild loop.
    final body = Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) => _onKeyEvent(cubit, event),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GameMapView(
            sweepProgress: _sweep,
            // The map is the biggest target on a phone, so a tap on it
            // steps the script — the same thing the forward arrow does,
            // whether or not the tap landed on a city.
            onTap: () => _step(cubit, forward: true),
          ),
          SweepOverlay(progress: _sweep),
          // Mounted for as long as there is a level, and only faded on
          // `showsCard`: mounting on `showsCard` would tear the card out
          // of the tree before it could fade, so it would vanish and pop
          // back at full size instead of easing away before the
          // clearance line and the next sweep.
          if (state.level case final level?)
            AnimatedCrossFade(
              duration: StoryOverlay.switchDuration ~/ 3,
              crossFadeState: state.showsCard
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              secondChild: const SizedBox.shrink(),
              firstChild: DestinationCard(
                level: level,
                destinationLabel: state.currentStop?.label ?? '',
                verses: state.revealedVerses,
                versesSpeaker: cubit.letterWriter,
                hasMore: state.hasMoreReveal,
                onReveal: cubit.revealNext,
                onAdvance: () => _step(cubit, forward: true),
              ),
            ),
          // Listening rather than reading, so that re-aiming the tail
          // rebuilds the bubble alone and leaves the map beneath it
          // untouched.
          ValueListenableBuilder<double?>(
            valueListenable: _guideAnchorX,
            builder: (context, anchorX, _) => StoryOverlay(
              guide: cubit.guide,
              guideAnchorX: anchorX,
              narrator: cubit.narrator,
              beat: state.beat,
              onAdvance: () => _step(cubit, forward: true),
            ),
          ),
          _Arrows(
            state: state,
            onBackward: () => _step(cubit, forward: false),
            onForward: () => _step(cubit, forward: true),
          ),
        ],
      ),
    );

    return BlocListener<GameJourneyCubit, GameJourneyState>(
      listenWhen: (previous, current) => previous.camera != current.camera,
      listener: (context, state) => _onCameraChanged(state),
      // The whole `Scaffold` is rebuilt per frame, not just the bar: the
      // bar's height is `PreferredSize`'s, and `Scaffold` only re-reads
      // that when it is handed a new one. Animating inside the bar would
      // grow the portrait against a body that jumps.
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: guideAvatarSize),
        duration: _guideAvatarGrow,
        curve: Curves.easeOutCubic,
        builder: (context, size, child) {
          _reaimTheTail();

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(size + _guideAvatarClearance),
              child: AppBar(
                centerTitle: false,
                toolbarHeight: size + _guideAvatarClearance,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CharacterPortrait(
                      key: _guideAvatarKey,
                      character: cubit.guide,
                      size: size,
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
            ),
            body: child,
          );
        },
        child: body,
      ),
    );
  }

  @override
  void dispose() {
    _sounds.stopWalking();
    _sweep.removeStatusListener(_sweepSoundListener);
    _sweep.dispose();
    _focusNode.dispose();
    _guideAnchorX.dispose();
    super.dispose();
  }

  /// Notes where the guide's portrait ended up, so her bubble can point
  /// at it.
  void _findGuideAvatar() {
    if (!mounted) {
      return;
    }
    final box = _guideAvatarKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return;
    }
    _guideAnchorX.value = box.localToGlobal(box.size.center(Offset.zero)).dx;
  }

  /// Starts the sweep clock when the camera is given one to fly, and
  /// parks it otherwise so nothing is drawn over a still map.
  ///
  /// The travelling loop rides the same clock, so it starts and stops
  /// exactly where the movement does — including the parked branch, which
  /// is how a journey cut short still falls silent.
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
      ..forward(from: 0).then((_) => _onSweepLanded());
  }

  /// The party has stopped moving. A `TickerFuture` only completes when
  /// the animation runs its whole course, so an interrupted sweep never
  /// gets here — which is the point: nothing was reached.
  ///
  /// Every sweep that runs is an arrival: the cubit only puts one on a
  /// forward move to a city the camera is not already at, so there is no
  /// re-flown sweep here to keep quiet for.
  void _onSweepLanded() {
    if (!mounted) {
      return;
    }
    _sounds.playLevelReached();
    _drainPresses();
  }

  /// Applies whatever was pressed while the camera was flying, one press
  /// per frame.
  ///
  /// One at a time rather than all at once: a press can set off another
  /// sweep, and applying the rest of the queue on top of it would stack
  /// two flights on one clock — the second restarting the first from zero
  /// over a map that is halfway to somewhere else. So each press waits
  /// for the frame after the one before it, and a press that starts a
  /// sweep leaves the remainder queued for when *it* lands.
  void _drainPresses() {
    if (!mounted || _pressesDuringSweep == 0) {
      return;
    }
    _pressesDuringSweep--;
    context.read<GameJourneyCubit>().forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sweep.isAnimating) {
        return;
      }
      _drainPresses();
    });
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
        _pressesDuringSweep = (_pressesDuringSweep + 1).clamp(
          0,
          _maxQueuedPresses,
        );
      }

      return;
    }

    if (forward) {
      cubit.forward();
    } else {
      cubit.backward();
    }
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

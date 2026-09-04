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
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_step_controls.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/level_step_counter.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/story_overlay.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_overlay.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_phase.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_press_queue.dart';
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
  /// How big the guide's portrait in the app bar grows while she is
  /// speaking.
  ///
  /// She is only given the larger size on a big screen and only while one
  /// of her beats is up, because the height comes out of the map and out
  /// of whatever else is on screen.
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

  /// Runs from 0 to 1 across a whole sweep. Drives the couriers walking,
  /// their trail drawing itself behind them, and the streaks over the
  /// map — all three are the same movement, so they share one clock.
  late final AnimationController _sweep = AnimationController(vsync: this);
  late final SweepClock _sweepClock = SweepClock(_sweep);
  final SweepPressQueue _pressQueue = SweepPressQueue();
  SweepPhase _lastSweepPhase = SweepPhase.landed;

  GameSounds get _sounds => widget.sounds;

  @override
  void initState() {
    super.initState();
    _sweepClock.addListener(_playSoundForSweepPhase);
  }

  void _playSoundForSweepPhase() {
    final phase = _sweepClock.phase;
    if (phase == _lastSweepPhase) {
      return;
    }
    _lastSweepPhase = phase;
    switch (phase) {
      case SweepPhase.hold:
        _sounds
          ..playDeparture()
          ..startWalking();
      case SweepPhase.landed || SweepPhase.interrupted:
        _sounds.stopWalking();
      case SweepPhase.out || SweepPhase.inward:
        break;
    }
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
    final guideIsSpeaking = beat != null && beat.speaker == StorySpeaker.guide;
    final guideAvatarSize = guideIsSpeaking
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
            sweepClock: _sweepClock,
            // The map is the biggest target on a phone, so a tap on it
            // steps the script — the same thing the forward arrow does,
            // whether or not the tap landed on a city.
            onTap: () => _step(cubit, forward: true),
          ),
          SweepOverlay(clock: _sweepClock),
          // Mounted for as long as there is a level, and only faded on
          // `showsCard`: mounting on `showsCard` would tear the card out
          // of the tree before it could fade, so it would vanish and pop
          // back at full size instead of easing away before the
          // clearance line and the next sweep.
          if (state.level case final level?)
            AnimatedCrossFade(
              duration: StoryOverlay.switchDuration ~/ 3,
              crossFadeState:
                  state.reveal.showsCard(
                    step: state.step,
                    hasLevel: state.level != null,
                  )
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              alignment: Alignment.center,
              layoutBuilder:
                  (topChild, topChildKey, bottomChild, bottomChildKey) =>
                      SizedBox.expand(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            KeyedSubtree(
                              key: bottomChildKey,
                              child: bottomChild,
                            ),
                            KeyedSubtree(key: topChildKey, child: topChild),
                          ],
                        ),
                      ),
              secondChild: const SizedBox.shrink(),
              firstChild: DestinationCard(
                level: level,
                verse: state.reveal.revealedVerse(levelVerses: level.verses),
                hasMore: state.reveal.hasNext(
                  step: state.step,
                  verseCount: level.verses.length,
                ),
                onReveal: cubit.revealNext,
                onAdvance: () => _step(cubit, forward: true),
              ),
            ),
          StoryOverlay(
            guide: cubit.guide,
            narrator: cubit.narrator,
            beat: state.beat,
            onAdvance: () => _step(cubit, forward: true),
          ),
          Positioned(
            bottom: screen.pick(compact: 16, large: 24),
            child: SafeArea(
              child: LevelStepCounter(progress: state.levelProgress),
            ),
          ),
          PositionedDirectional(
            end: 12,
            bottom: 12,
            child: SafeArea(
              child: GameStepControls(
                onBackward: () => _step(cubit, forward: false),
                onForward: () => _step(cubit, forward: true),
                canGoBackward: !state.isAtStart,
                canGoForward: !state.isAtEnd,
              ),
            ),
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
        builder: (context, size, child) => Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(size + _guideAvatarClearance),
            child: AppBar(
              centerTitle: false,
              toolbarHeight: size + _guideAvatarClearance,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CharacterPortrait(character: cubit.guide, size: size),
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
        ),
        child: body,
      ),
    );
  }

  @override
  void dispose() {
    _sounds.stopWalking();
    _sweepClock
      ..removeListener(_playSoundForSweepPhase)
      ..dispose();
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
    final sweep = state.sweep;
    if (sweep == null) {
      _sweepClock.interrupt();

      return;
    }
    _sweepClock.start(sweep).then((_) => _onSweepLanded());
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
    _drainPressQueue();
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
  void _drainPressQueue() {
    if (!mounted ||
        !_pressQueue.drainOne(context.read<GameJourneyCubit>().forward)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sweepClock.phase.isRunning) {
        return;
      }
      _drainPressQueue();
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

    final key = event.logicalKey;
    if (_isForwardKey(key)) {
      _step(cubit, forward: true);

      return KeyEventResult.handled;
    }

    if (_isBackwardKey(key)) {
      _step(cubit, forward: false);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  bool _isForwardKey(LogicalKeyboardKey key) => switch (key) {
    LogicalKeyboardKey.arrowLeft ||
    LogicalKeyboardKey.space ||
    LogicalKeyboardKey.enter ||
    LogicalKeyboardKey.arrowDown => true,
    _ => false,
  };

  bool _isBackwardKey(LogicalKeyboardKey key) => switch (key) {
    LogicalKeyboardKey.arrowRight ||
    LogicalKeyboardKey.backspace ||
    LogicalKeyboardKey.arrowUp => true,
    _ => false,
  };

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
    _pressQueue.press(
      forward: forward,
      phase: _sweepClock.phase,
      onForward: cubit.forward,
      onBackward: cubit.backward,
    );
  }
}

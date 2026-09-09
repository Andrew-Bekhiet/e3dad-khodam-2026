import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/game/game_sounds.dart';
import 'package:e3dad_khodam_2026/src/domain/game/level_script_repository.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/sweep_framing.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/step_focus.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/sweep_step_queue.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/destination_card.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_map_view.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_screen_size.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_step_controls.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/level_step_counter.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/story_overlay.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_overlay.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_phase.dart';
import 'package:flutter/material.dart';
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
  final FocusNode _focusNode = FocusNode(debugLabel: 'game-journey-keys');

  /// Times the couriers walking, their trail drawing itself behind them,
  /// and the streaks over the map — all three are the same movement, so
  /// they share one clock.
  late final SweepStepQueue _stepQueue = SweepStepQueue(
    vsync: this,
    focusNode: _focusNode,
    onForward: context.read<GameJourneyCubit>().forward,
    onBackward: context.read<GameJourneyCubit>().backward,
  );
  SweepPhase _lastSweepPhase = SweepPhase.landed;

  GameSounds get _sounds => widget.sounds;

  @override
  void initState() {
    super.initState();
    _stepQueue.sweepClock.addListener(_playSoundForSweepPhase);
  }

  void _playSoundForSweepPhase() {
    final phase = _stepQueue.sweepClock.phase;
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

    final body = StepFocus(
      focusNode: _focusNode,
      onForward: _stepQueue.forward,
      onBackward: _stepQueue.backward,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GameMapView(
            sweepClock: _stepQueue.sweepClock,
            // The map is the biggest target on a phone, so a tap on it
            // steps the script — the same thing the forward arrow does,
            // whether or not the tap landed on a city.
            onTap: _stepQueue.forward,
          ),
          SweepOverlay(clock: _stepQueue.sweepClock),
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
                onAdvance: _stepQueue.forward,
              ),
            ),
          StoryOverlay(
            guide: cubit.guide,
            narrator: cubit.narrator,
            beat: state.beat,
            onAdvance: _stepQueue.forward,
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
                onBackward: _stepQueue.backward,
                onForward: _stepQueue.forward,
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
      listener: (context, state) => _stepQueue.handleCameraChange(
        state.sweep,
        onLanded: _sounds.playLevelReached,
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text(AppStrings.gameTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.replay),
              tooltip: AppStrings.restartTooltip,
              onPressed: cubit.restart,
            ),
          ],
        ),
        body: body,
      ),
    );
  }

  @override
  void dispose() {
    _sounds.stopWalking();
    _stepQueue
      ..sweepClock.removeListener(_playSoundForSweepPhase)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

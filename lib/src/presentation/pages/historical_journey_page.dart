import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_step_controls.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_press_queue.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/beacon_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/history_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The screen for one historical journey: the same pixel map, walked as
/// a silent sequence of rests, with a trail drawing itself between them
/// and a beacon flashing wherever a letter was sent. No dialogue, cards
/// or sounds — this experience is trail, markers and camera only.
final class HistoricalJourneyPage extends StatelessWidget {
  /// The journey this screen plays.
  final HistoricalJourney journey;

  /// Creates the screen for [journey].
  const HistoricalJourneyPage({required this.journey, super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => HistoricalJourneyCubit(journey),
    child: _HistoricalJourneyView(title: journey.title),
  );
}

/// The screen's body, split out so it can own the keyboard focus node,
/// the sweep clock and the beacon clock while [HistoricalJourneyPage]
/// stays the stateless provider boundary.
final class _HistoricalJourneyView extends StatefulWidget {
  final String title;

  const _HistoricalJourneyView({required this.title});

  @override
  State<_HistoricalJourneyView> createState() => _HistoricalJourneyViewState();
}

class _HistoricalJourneyViewState extends State<_HistoricalJourneyView>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(
    debugLabel: 'historical-journey-keys',
  );

  /// Runs from 0 to 1 across a whole sweep, timing the camera and the
  /// trail drawing itself behind it.
  late final AnimationController _sweep = AnimationController(vsync: this);
  late final SweepClock _sweepClock = SweepClock(_sweep);

  /// Repeats for the page's whole lifetime, timing the beacon's flash.
  late final AnimationController _beaconController = AnimationController(
    vsync: this,
  );
  late final BeaconClock _beaconClock = BeaconClock(_beaconController);

  final SweepPressQueue _pressQueue = SweepPressQueue();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<HistoricalJourneyCubit>();
    final state = cubit.state;

    final body = Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) => _onKeyEvent(cubit, event),
      child: Stack(
        fit: StackFit.expand,
        children: [
          HistoryMapView(
            sweepClock: _sweepClock,
            beaconClock: _beaconClock,
            // The map is the biggest target on a phone, so a tap on it
            // steps the journey — the same thing the forward arrow does.
            onTap: () => _step(cubit, forward: true),
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

    return BlocListener<HistoricalJourneyCubit, HistoricalJourneyState>(
      listenWhen: (previous, current) => previous.camera != current.camera,
      listener: (context, state) => _onCameraChanged(state),
      child: Scaffold(
        appBar: AppBar(centerTitle: false, title: Text(widget.title)),
        body: body,
      ),
    );
  }

  @override
  void dispose() {
    _sweepClock.dispose();
    _sweep.dispose();
    _beaconClock.dispose();
    _beaconController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Starts the sweep clock when the camera is given one to fly, and
  /// parks it otherwise so nothing is drawn over a still map.
  void _onCameraChanged(HistoricalJourneyState state) {
    final sweep = state.sweep;
    if (sweep == null) {
      _sweepClock.interrupt();

      return;
    }
    _sweepClock.start(sweep).then((_) => _onSweepLanded());
  }

  /// The journey has stopped moving. A `TickerFuture` only completes
  /// when the animation runs its whole course, so an interrupted sweep
  /// never gets here.
  void _onSweepLanded() {
    if (!mounted) {
      return;
    }
    _drainPressQueue();
  }

  /// Applies whatever was pressed while the camera was flying, one press
  /// per frame — see `GameJourneyPage._drainPressQueue` for why one at a
  /// time.
  void _drainPressQueue() {
    if (!mounted ||
        !_pressQueue.drainOne(
          context.read<HistoricalJourneyCubit>().forward,
        )) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sweepClock.phase.isRunning) {
        return;
      }
      _drainPressQueue();
    });
  }

  /// Left and right walk the journey, space and enter advance it. Not
  /// mirrored for RTL: they match the on-screen arrows, which are not
  /// mirrored either.
  KeyEventResult _onKeyEvent(HistoricalJourneyCubit cubit, KeyEvent event) {
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

  /// Steps the journey and takes the keyboard focus back, so a tap on
  /// the map or a button does not leave the arrow keys dead afterwards.
  ///
  /// A forward press made mid-sweep is queued; a backward press mid-sweep
  /// is dropped — landing only to fly straight back out is worse than
  /// ignoring a key pressed during a second of animation.
  void _step(HistoricalJourneyCubit cubit, {required bool forward}) {
    _focusNode.requestFocus();
    _pressQueue.press(
      forward: forward,
      phase: _sweepClock.phase,
      onForward: cubit.forward,
      onBackward: cubit.backward,
    );
  }
}

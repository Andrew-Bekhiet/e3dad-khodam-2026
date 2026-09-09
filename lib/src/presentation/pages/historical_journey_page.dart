import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_cubit.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_journey_state.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/step_focus.dart';
import 'package:e3dad_khodam_2026/src/presentation/stage/sweep_step_queue.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_step_controls.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/beacon_clock.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/history/history_map_view.dart';
import 'package:flutter/material.dart';
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

  late final SweepStepQueue _stepQueue = SweepStepQueue(
    vsync: this,
    focusNode: _focusNode,
    onForward: context.read<HistoricalJourneyCubit>().forward,
    onBackward: context.read<HistoricalJourneyCubit>().backward,
  );

  /// Repeats for the page's whole lifetime, timing the beacon's flash.
  late final AnimationController _beaconController = AnimationController(
    vsync: this,
  );
  late final BeaconClock _beaconClock = BeaconClock(_beaconController);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<HistoricalJourneyCubit>();
    final state = cubit.state;

    final body = StepFocus(
      focusNode: _focusNode,
      onForward: _stepQueue.forward,
      onBackward: _stepQueue.backward,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HistoryMapView(
            sweepClock: _stepQueue.sweepClock,
            beaconClock: _beaconClock,
            // The map is the biggest target on a phone, so a tap on it
            // steps the journey — the same thing the forward arrow does.
            onTap: _stepQueue.forward,
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

    return BlocListener<HistoricalJourneyCubit, HistoricalJourneyState>(
      listenWhen: (previous, current) => previous.camera != current.camera,
      listener: (context, state) => _stepQueue.handleCameraChange(
        state.sweep,
      ),
      child: Scaffold(
        appBar: AppBar(centerTitle: false, title: Text(widget.title)),
        body: body,
      ),
    );
  }

  @override
  void dispose() {
    _stepQueue.dispose();
    _beaconClock.dispose();
    _beaconController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

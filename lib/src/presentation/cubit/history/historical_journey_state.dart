import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:e3dad_khodam_2026/src/domain/history/historical_journey.dart';
import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/historical_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/history/journey_trace.dart';
import 'package:equatable/equatable.dart';

/// A snapshot of a historical journey's playthrough: which step is
/// showing, what the map should draw, and where the camera should look.
///
/// Deliberately shallower than `GameJourneyState`: this experience has no
/// cards, beats or levels to hang extra structure off.
final class HistoricalJourneyState extends Equatable {
  final ({HistoricalStep step, int stepIndex, int stepCount}) position;

  final ({
    JourneyStop origin,
    List<JourneyRest> visitedRests,
    JourneyStop currentStop,
    JourneyStop? beacon,
    List<JourneyStop> revealedVia,
    JourneyTrace trace,
    MapCameraTarget camera,
    Duration cameraAnimationDuration,
  })
  map;

  /// The step currently showing.
  HistoricalStep get step => position.step;

  /// Position of [step] in the flat list of steps, and the total.
  int get stepIndex => position.stepIndex;

  /// How many steps the whole playthrough has.
  int get stepCount => position.stepCount;

  /// Where the journey set out from.
  JourneyStop get origin => map.origin;

  /// Rests already arrived at, excluding the current one.
  List<JourneyRest> get visitedRests => map.visitedRests;

  /// The origin on the opening step, otherwise `rests[i].stop`.
  JourneyStop get currentStop => map.currentStop;

  /// The city flashing while the journey rests at [currentStop], or null
  /// when this rest sends no letter.
  JourneyStop? get beacon => map.beacon;

  /// Every via point from the origin through the current rest, in order —
  /// the cities the trail has actually passed. Nothing beyond the current
  /// rest is drawn.
  List<JourneyStop> get revealedVia => map.revealedVia;

  /// The polyline behind the animation and the stretch being drawn now.
  JourneyTrace get trace => map.trace;

  /// Where the map should be looking.
  MapCameraTarget get camera => map.camera;

  /// How long the map surface should take to animate to [camera]. A
  /// [SweepCameraTarget] ignores this and times its own three parts.
  Duration get cameraAnimationDuration => map.cameraAnimationDuration;

  /// The sweep this step runs, or null when the camera holds still.
  SweepCameraTarget? get sweep =>
      camera is SweepCameraTarget ? camera as SweepCameraTarget : null;

  /// Whether there is anything before this step.
  bool get isAtStart => stepIndex <= 0;

  /// Whether there is anything after this step.
  bool get isAtEnd => stepIndex >= stepCount - 1;

  @override
  List<Object?> get props => [position, map];

  /// Creates a playthrough state.
  const HistoricalJourneyState({required this.position, required this.map});
}

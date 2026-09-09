part of 'map_camera_target.dart';

/// Requests the camera pull out to [widest], hold there, then come in to
/// [arrival] — the move the game makes when the journey reaches a new
/// destination.
///
/// Expressed as a target rather than performed by whoever builds the
/// spec, so that the playthrough stays a synchronous list of steps: the
/// cubit says *sweep to أفسس*, and each surface decides how to fly it.
/// The widest point is deliberately not a step of its own — nobody can
/// stop the script half way through a sweep.
///
/// A surface running this ignores the spec's own
/// `cameraAnimationDuration`: a sweep times its own three parts.
final class SweepCameraTarget extends MapCameraTarget {
  /// The frame to pull out to, showing the whole basin.
  final FitBoundsCameraTarget widest;

  /// Where the camera settles once it comes back in.
  ///
  /// A center/zoom point for the game's single destination, or a bounds
  /// frame when arrival means holding two places on screen at once — a
  /// rest and the beacon flashing beside it.
  final CameraLeg arrival;

  /// How long the camera takes to reach [widest].
  final Duration outLeg;

  /// How long the camera rests at [widest] before diving. The pause is
  /// what makes the Mediterranean register at all.
  final Duration hold;

  /// How long the camera takes to come in to [arrival]. Longer than
  /// [outLeg] on purpose: going out is travel, coming in is arrival, and
  /// arrival is the part worth watching.
  final Duration inLeg;

  /// The whole sweep, end to end.
  Duration get total => outLeg + hold + inLeg;

  @override
  List<Object?> get props => [widest, arrival, outLeg, hold, inLeg];

  /// Creates a sweep.
  const SweepCameraTarget({
    required this.widest,
    required this.arrival,
    required this.outLeg,
    required this.hold,
    required this.inLeg,
  });
}

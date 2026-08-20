/// The part of a camera sweep that is currently running.
enum SweepPhase {
  out,
  hold,
  inward,
  landed,
  interrupted;

  /// Whether the camera is still moving through a sweep.
  bool get isRunning => switch (this) {
    SweepPhase.out || SweepPhase.hold || SweepPhase.inward => true,
    SweepPhase.landed || SweepPhase.interrupted => false,
  };
}

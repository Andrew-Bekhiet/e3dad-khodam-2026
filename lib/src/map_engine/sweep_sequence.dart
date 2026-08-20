import 'dart:async';

import 'package:e3dad_khodam_2026/src/map_engine/map_camera_target.dart';

/// Performs the provider-independent timing of a camera sweep.
final class SweepSequence {
  /// Flies out, holds at the wide frame, then flies in to the destination.
  static Future<void> run(
    SweepCameraTarget sweep, {
    required FutureOr<void> Function(CameraLeg leg, Duration duration) flyLeg,
    required bool Function() isMounted,
    FutureOr<void> Function()? onOutStarted,
    FutureOr<void> Function()? onArrivalStarted,
  }) async {
    await flyLeg(sweep.widest, sweep.outLeg);
    await onOutStarted?.call();
    await Future<void>.delayed(sweep.outLeg + sweep.hold);
    if (!isMounted()) {
      return;
    }
    await flyLeg(sweep.arrival, sweep.inLeg);
    await onArrivalStarted?.call();
  }

  const SweepSequence._();
}

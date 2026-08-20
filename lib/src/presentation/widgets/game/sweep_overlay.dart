import 'dart:math';

import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/sweep_clock.dart';
import 'package:flutter/widgets.dart';

/// The streaks and vignette drawn over the map while the camera sweeps.
///
/// The map itself cannot be blurred by Flutter — it is a platform view,
/// so its pixels are never Flutter's to filter. On web the surface blurs
/// the real map canvas through CSS; everywhere else this layer is what
/// carries the speed, and it is drawn identically on every platform
/// because Flutter draws it.
///
/// Strongest in the middle of the sweep and gone by the time the camera
/// settles, so the effect never sits over a still map.
final class SweepOverlay extends StatelessWidget {
  /// The sweep's shared phase clock.
  final SweepClock clock;

  /// Creates the overlay.
  const SweepOverlay({required this.clock, super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: AnimatedBuilder(
        animation: clock,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _SweepPainter(clock.progress),
        ),
      ),
    ),
  );
}

/// Paints fine streaks running out from the centre, plus a dark edge.
final class _SweepPainter extends CustomPainter {
  /// Streaks drawn per frame. Enough to read as motion, few enough that
  /// the map is never hidden behind them.
  static const int _streakCount = 44;

  /// Longest a streak reaches, as a fraction of the viewport's diagonal.
  static const double _streakLength = 0.22;

  /// Where the streaks begin, as a fraction of the diagonal — nothing is
  /// drawn over the middle, which is where the city lands.
  static const double _clearCentre = 0.16;

  /// Fixed seed: the streaks must not crawl about between frames.
  static const int _seed = 20260815;

  final double progress;

  /// Full at the middle of the sweep, nothing at either end.
  double get _intensity => sin(progress.clamp(0.0, 1.0) * pi);

  const _SweepPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final intensity = _intensity;
    if (intensity <= 0.01) {
      return;
    }

    final centre = Offset(size.width / 2, size.height / 2);
    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    final random = Random(_seed);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = GamePalette.white.withValues(alpha: 0.3 * intensity);

    for (var index = 0; index < _streakCount; index++) {
      final angle = random.nextDouble() * 2 * pi;
      final start = _clearCentre + random.nextDouble() * 0.5;
      final length = _streakLength * intensity * (0.4 + random.nextDouble());
      final direction = Offset(cos(angle), sin(angle));

      canvas
        ..save()
        ..drawLine(
          centre + direction * (start * diagonal),
          centre + direction * ((start + length) * diagonal),
          paint..strokeWidth = 1 + random.nextDouble() * 1.6,
        )
        ..restore();
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 0.75,
          colors: [
            const Color(0x00000000),
            GamePalette.ink.withValues(alpha: 0.55 * intensity),
          ],
          stops: const [0.55, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_SweepPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

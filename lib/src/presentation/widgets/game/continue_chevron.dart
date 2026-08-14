import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:flutter/material.dart';

/// The blinking cue that there is more to see: a chevron, and no words —
/// the game's copy is the play's copy, and the play never wrote a
/// "press to continue".
final class ContinueChevron extends StatefulWidget {
  static const Duration _period = Duration(milliseconds: 900);

  /// Which way the cue points: forward for dialogue, down for verses.
  final IconData icon;

  /// Chevron colour.
  final Color color;

  /// Chevron size in logical pixels.
  final double size;

  /// Creates the cue.
  const ContinueChevron({
    this.icon = Icons.play_arrow,
    this.color = GamePalette.ink,
    this.size = 22,
    super.key,
  });

  @override
  State<ContinueChevron> createState() => _ContinueChevronState();
}

class _ContinueChevronState extends State<ContinueChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: ContinueChevron._period,
  )..repeat(reverse: true);

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller.drive(Tween(begin: 0.25, end: 0.9)),
    child: Icon(widget.icon, size: widget.size, color: widget.color),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

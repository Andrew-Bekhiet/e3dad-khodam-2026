import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/continue_chevron.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:e3dad_khodam_2026/src/presentation/widgets/game/pixel_panel.dart';
import 'package:flutter/material.dart';

/// The guide talking as a speech bubble from her portrait in the app bar.
///
/// She is already on screen, so the bubble carries no portrait of its own
/// — only what she is saying. The full `GuideDialoguePanel` is still there
/// for the lines that deserve the screen; which one a beat gets is
/// [StoryBeat.emphasis], chosen in the script.
///
/// Anchored to the start edge because the avatar sits at the start of the
/// app bar's title, which is the one position that holds under RTL without
/// measuring anything.
final class GuideCallout extends StatelessWidget {
  /// Width of the tail's base.
  static const double _tailWidth = 22.0;

  /// How far the tail stands above the bubble.
  static const double _tailHeight = 12.0;

  /// Distance from the start edge to the middle of the tail — half the
  /// app-bar avatar, so the tail rises towards the middle of her face.
  static const double _tailCentreInset = 30.0;

  static const double _maxWidth = 520.0;

  /// The line being spoken.
  final StoryBeat beat;

  /// Creates the guide's speech bubble.
  const GuideCallout({required this.beat, super.key});

  @override
  Widget build(BuildContext context) {
    final title = beat.title;
    final text = TextTheme.of(context);

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: _tailCentreInset - _tailWidth / 2,
                  ),
                  child: CustomPaint(
                    size: Size(_tailWidth, _tailHeight),
                    painter: _CalloutTail(),
                  ),
                ),
                Flexible(
                  child: PixelPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null) ...[
                          Text(
                            title,
                            style: text.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: GamePalette.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              beat.text,
                              style: text.headlineSmall?.copyWith(
                                height: 1.5,
                                color: GamePalette.ink,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: ContinueChevron(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The bubble's tail: a hard triangle with the panel's own border on its
/// two slanted sides, and nothing across the base where it meets the
/// panel's own edge.
final class _CalloutTail extends CustomPainter {
  static const double _borderWidth = 3.0;

  const _CalloutTail();

  @override
  void paint(Canvas canvas, Size size) {
    final apex = Offset(size.width / 2, 0);
    final left = Offset(0, size.height);
    final right = Offset(size.width, size.height);
    final body = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(body, Paint()..color = GamePalette.parchment);
    canvas.drawPath(
      Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(apex.dx, apex.dy)
        ..lineTo(right.dx, right.dy),
      Paint()
        ..color = GamePalette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth,
    );
  }

  @override
  bool shouldRepaint(_CalloutTail oldDelegate) => false;
}

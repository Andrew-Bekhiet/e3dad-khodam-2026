import 'package:e3dad_khodam_2026/src/presentation/widgets/game/game_palette.dart';
import 'package:flutter/widgets.dart';

/// The game's dialogue box: a flat fill, a thick ink border and a hard
/// offset shadow — no gradients, no blur, no rounded corners, so it sits
/// on the pixel basemap as part of the same picture.
final class PixelPanel extends StatelessWidget {
  static const double _borderWidth = 3.0;
  static const double _shadowOffset = 4.0;

  /// What the panel wraps.
  final Widget child;

  /// Panel fill.
  final Color color;

  /// Border and shadow colour.
  final Color border;

  /// Inner spacing around [child].
  final EdgeInsetsGeometry padding;

  /// Creates a panel.
  const PixelPanel({
    required this.child,
    this.color = GamePalette.parchment,
    this.border = GamePalette.ink,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: border, width: _borderWidth),
      boxShadow: [
        BoxShadow(
          color: border,
          offset: const Offset(_shadowOffset, _shadowOffset),
        ),
      ],
    ),
    child: child,
  );
}

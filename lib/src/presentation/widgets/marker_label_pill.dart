import 'package:flutter/material.dart';

/// A marker's label text — either on a solid white pill (used by every
/// kind except city, per spec §2: a stroked/outlined text halo renders
/// inconsistently with Arabic diacritics and joining forms) or bare on
/// the tile inside a white halo (city markers — the quietest element at
/// the busiest, most crowded level, but still legible over the basemap).
final class MarkerLabelPill extends StatelessWidget {
  static const Color _pillColor = Color(0xE6FFFFFF);
  static const double _pillHorizontalPadding = 8.0;
  static const double _pillVerticalPadding = 2.0;
  static const double _pillRadius = 6.0;
  static const double _pillShadowBlur = 2.0;
  static const Color _pillShadowColor = Color(0x26000000);
  static const Offset _pillShadowOffset = Offset(0, 1);
  static const int _maxLines = 1;

  /// Halo painted behind bare (city) labels: an opaque white glow offset
  /// to all four diagonals plus one centered, so the text reads against
  /// busy basemap features (roads, coastlines, the style's own labels)
  /// without the weight of a pill. Unlike a stroked outline — rejected
  /// in spec §2 — a halo leaves Arabic diacritics and joining forms
  /// untouched. No dark drop shadow is mixed in: later shadows paint
  /// over earlier ones, so the white would simply bury it.
  static const double _haloBlur = 3.0;
  static const Color _haloColor = Color(0xFFFFFFFF);
  static const double _haloSpread = 1.5;
  static const List<Shadow> _cityLabelShadows = [
    Shadow(
      blurRadius: _haloBlur,
      color: _haloColor,
      offset: Offset(-_haloSpread, -_haloSpread),
    ),
    Shadow(
      blurRadius: _haloBlur,
      color: _haloColor,
      offset: Offset(_haloSpread, -_haloSpread),
    ),
    Shadow(
      blurRadius: _haloBlur,
      color: _haloColor,
      offset: Offset(-_haloSpread, _haloSpread),
    ),
    Shadow(
      blurRadius: _haloBlur,
      color: _haloColor,
      offset: Offset(_haloSpread, _haloSpread),
    ),
    Shadow(blurRadius: _haloBlur, color: _haloColor),
  ];

  /// Line-height multiplier applied to every label's [TextStyle.height],
  /// so the rendered text box is exactly `fontSize * lineHeight` — a
  /// fixed number `MarkerVisual.labelSegmentHeight` can reserve space
  /// for deterministically, instead of guessing at font-metric-dependent
  /// natural line height (which Cairo renders ~1px taller than guessed).
  static const double lineHeight = 1.25;

  /// The place or category name to display.
  final String text;

  /// Font size in logical pixels, per the marker's tier (spec §4).
  final double fontSize;

  /// Font weight, per the marker's tier (spec §4).
  final FontWeight fontWeight;

  /// Text color — on the pill, or bare on the tile for city labels.
  final Color textColor;

  /// Whether to paint the white pill background; false renders bare
  /// haloed text instead (city markers only).
  final bool showBackground;

  /// Creates a marker label.
  const MarkerLabelPill({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.textColor,
    required this.showBackground,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBackground) {
      return Text(
        text,
        textAlign: TextAlign.center,
        maxLines: _maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: lineHeight,
          color: textColor,
          shadows: _cityLabelShadows,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _pillColor,
        borderRadius: BorderRadius.circular(_pillRadius),
        boxShadow: const [
          BoxShadow(
            blurRadius: _pillShadowBlur,
            color: _pillShadowColor,
            offset: _pillShadowOffset,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _pillHorizontalPadding,
          vertical: _pillVerticalPadding,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: lineHeight,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

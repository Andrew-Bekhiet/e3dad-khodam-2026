import 'package:flutter/material.dart';

/// A marker's label text — either on a solid white pill (used by every
/// kind except city, per spec §2: a stroked/outlined text halo renders
/// inconsistently with Arabic diacritics and joining forms) or bare on
/// the tile with a soft shadow (city markers, deliberately the quietest
/// element at the busiest, most crowded level).
final class MarkerLabelPill extends StatelessWidget {
  static const Color _pillColor = Color(0xE6FFFFFF);
  static const double _pillHorizontalPadding = 8.0;
  static const double _pillVerticalPadding = 2.0;
  static const double _pillRadius = 6.0;
  static const double _pillShadowBlur = 2.0;
  static const Color _pillShadowColor = Color(0x26000000);
  static const Offset _pillShadowOffset = Offset(0, 1);
  static const double _cityShadowBlur = 1.0;
  static const Color _cityShadowColor = Color(0x59000000);
  static const Offset _cityShadowOffset = Offset(0, 1);
  static const int _maxLines = 1;

  /// The place or category name to display.
  final String text;

  /// Font size in logical pixels, per the marker's tier (spec §4).
  final double fontSize;

  /// Font weight, per the marker's tier (spec §4).
  final FontWeight fontWeight;

  /// Text color — on the pill, or bare on the tile for city labels.
  final Color textColor;

  /// Whether to paint the white pill background; false renders bare
  /// text with a text shadow instead (city markers only).
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
          color: textColor,
          shadows: const [
            Shadow(
              blurRadius: _cityShadowBlur,
              color: _cityShadowColor,
              offset: _cityShadowOffset,
            ),
          ],
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
            color: textColor,
          ),
        ),
      ),
    );
  }
}

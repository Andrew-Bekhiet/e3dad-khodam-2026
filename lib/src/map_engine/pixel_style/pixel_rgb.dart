/// An opaque 8-bit RGB colour with the handful of operations the pixel
/// palette needs.
///
/// Deliberately not `dart:ui`'s `Color`: everything here is pure
/// arithmetic over the style/sprite pipeline, testable without a Flutter
/// binding, and needs `#rrggbb` strings for Mapbox style JSON rather
/// than ARGB ints.
final class PixelRgb {
  static const int _channelMax = 255;
  static const int _hexRadix = 16;
  static const int _hexDigitsPerChannel = 2;
  static const double _oneSixth = 1.0 / 6.0;
  static const double _oneThird = 1.0 / 3.0;
  static const double _half = 0.5;
  static const double _twoThirds = 2.0 / 3.0;

  static String _hex(int channel) =>
      channel.toRadixString(_hexRadix).padLeft(_hexDigitsPerChannel, '0');

  static int _lerpChannel(int from, int to, double t) =>
      (from + (to - from) * t).round();

  static double _clamp01(double value) => value.clamp(0.0, 1.0);

  static int _hueToChannel(double p, double q, double hue) {
    final t = (hue + 1) % 1;
    final double value;
    if (t < _oneSixth) {
      value = p + (q - p) * 6 * t;
    } else if (t < _half) {
      value = q;
    } else if (t < _twoThirds) {
      value = p + (q - p) * (_twoThirds - t) * 6;
    } else {
      value = p;
    }

    return (_clamp01(value) * _channelMax).round();
  }

  /// Red channel, `0`–`255`.
  final int red;

  /// Green channel, `0`–`255`.
  final int green;

  /// Blue channel, `0`–`255`.
  final int blue;

  /// This colour as a Mapbox-style `#rrggbb` string.
  String get hex =>
      '#'
      '${_hex(red)}'
      '${_hex(green)}'
      '${_hex(blue)}';

  @override
  int get hashCode => Object.hash(red, green, blue);

  /// Creates a colour from its three channels.
  const PixelRgb(this.red, this.green, this.blue);

  /// Builds a colour from hue/saturation/lightness, each `0`–`1`.
  factory PixelRgb._fromHsl({
    required double hue,
    required double saturation,
    required double lightness,
  }) {
    if (saturation == 0) {
      final grey = (lightness * _channelMax).round();

      return PixelRgb(grey, grey, grey);
    }
    final q = lightness < _half
        ? lightness * (1 + saturation)
        : lightness + saturation - lightness * saturation;
    final p = 2 * lightness - q;

    return PixelRgb(
      _hueToChannel(p, q, hue + _oneThird),
      _hueToChannel(p, q, hue),
      _hueToChannel(p, q, hue - _oneThird),
    );
  }

  /// Multiplies HSL saturation by [saturation] and lightness by
  /// [lightness], each clamped back into range — the "palette" knobs of
  /// the tuner. Hue is never touched, so the palette stays recognisably
  /// itself at any setting.
  PixelRgb adjusted({required double saturation, required double lightness}) {
    final hsl = _toHsl();

    return PixelRgb._fromHsl(
      hue: hsl.hue,
      saturation: _clamp01(hsl.saturation * saturation),
      lightness: _clamp01(hsl.lightness * lightness),
    );
  }

  /// Linear per-channel blend from this colour toward [other]; `t == 0`
  /// is this colour, `t == 1` is [other].
  PixelRgb mixedWith(PixelRgb other, double t) => PixelRgb(
    _lerpChannel(red, other.red, t),
    _lerpChannel(green, other.green, t),
    _lerpChannel(blue, other.blue, t),
  );

  @override
  bool operator ==(Object other) =>
      other is PixelRgb &&
      other.red == red &&
      other.green == green &&
      other.blue == blue;

  @override
  String toString() => hex;

  ({double hue, double saturation, double lightness}) _toHsl() {
    final r = red / _channelMax;
    final g = green / _channelMax;
    final b = blue / _channelMax;
    final max = [r, g, b].reduce((a, c) => a > c ? a : c);
    final min = [r, g, b].reduce((a, c) => a < c ? a : c);
    final lightness = (max + min) / 2;
    if (max == min) {
      return (hue: 0.0, saturation: 0.0, lightness: lightness);
    }
    final delta = max - min;
    final saturation = lightness > _half
        ? delta / (2 - max - min)
        : delta / (max + min);
    final double hue;
    if (max == r) {
      hue = ((g - b) / delta + (g < b ? 6 : 0)) * _oneSixth;
    } else if (max == g) {
      hue = ((b - r) / delta + 2) * _oneSixth;
    } else {
      hue = ((r - g) / delta + 4) * _oneSixth;
    }

    return (hue: hue, saturation: saturation, lightness: lightness);
  }
}

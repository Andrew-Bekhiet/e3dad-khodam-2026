import 'dart:ui' as ui;

import 'package:e3dad_khodam_2026/src/map_engine/map_token_spec.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:flutter/services.dart';

/// Rasterises [MapTokenStyle]s into the round portrait images the
/// renderer draws characters as.
///
/// Output is a [PixelSprite], so both surfaces register these through the
/// paths they already have: PNG on mobile, raw RGBA on web — exactly like
/// `MarkerSprite`.
final class TokenSprite {
  /// Image pixels per logical pixel. Portraits are photographs, so they
  /// are rasterised above 1:1 and declared at that scale to stay sharp.
  static const double scale = 3.0;

  /// Fraction of the crop height above the portrait's centre. Portraits
  /// are head-and-shoulders shots, so a square crop is taken from the top
  /// rather than the middle, which would cut the face in half.
  static const double _cropAlignY = 0.15;

  static const double _shadowBlur = 6.0;
  static const double _shadowOffsetDy = 2.0;
  static const double _shadowOpacity = 0.35;
  static const double _shadowMargin = 2.0;

  /// Gaussian blur radius to the sigma [ui.MaskFilter.blur] takes.
  static const double _blurToSigma = 0.5;

  /// Rasterises [style] into a sprite named [MapTokenStyle.id], loading
  /// its portrait from [bundle] (the root bundle by default).
  static Future<PixelSprite> render(
    MapTokenStyle style, {
    AssetBundle? bundle,
  }) async {
    final portrait = await _loadPortrait(style.portraitAsset, bundle);
    const margin = _shadowBlur + _shadowOffsetDy + _shadowMargin;
    final logicalSize = style.diameter + margin * 2;
    final pixelSize = (logicalSize * scale).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(scale);
    final bounds = ui.Rect.fromLTWH(
      margin,
      margin,
      style.diameter,
      style.diameter,
    );

    _paintShadow(canvas, bounds);
    _paintPortrait(canvas, style, bounds, portrait);
    _paintRing(canvas, style, bounds);
    portrait?.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelSize, pixelSize);
    picture.dispose();

    // Straight, not premultiplied: premultiplied bytes would darken the
    // antialiased circle edge on both the PNG and GL JS paths.
    final bytes = await image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    image.dispose();
    if (bytes == null) {
      throw StateError('Failed to rasterise token sprite "${style.id}".');
    }

    return PixelSprite(
      id: style.id,
      width: pixelSize,
      height: pixelSize,
      rgba: bytes.buffer.asUint8List(),
    );
  }

  /// Renders [styles], one sprite per distinct id.
  static Future<List<PixelSprite>> renderAll(
    Iterable<MapTokenStyle> styles, {
    AssetBundle? bundle,
  }) async {
    final byId = <String, MapTokenStyle>{
      for (final style in styles) style.id: style,
    };

    return [
      for (final style in byId.values) await render(style, bundle: bundle),
    ];
  }

  /// Decodes the portrait, or returns null when the asset is missing or
  /// undecodable — a character whose artwork has not been dropped in yet
  /// still gets a token, just a plain coloured one.
  static Future<ui.Image?> _loadPortrait(
    String assetPath,
    AssetBundle? bundle,
  ) async {
    try {
      final data = await (bundle ?? rootBundle).load(assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      codec.dispose();

      return frame.image;
    } catch (_) {
      return null;
    }
  }

  static void _paintShadow(ui.Canvas canvas, ui.Rect bounds) {
    final paint = ui.Paint()
      ..color = const ui.Color(0xFF000000).withValues(alpha: _shadowOpacity)
      ..maskFilter = const ui.MaskFilter.blur(
        ui.BlurStyle.normal,
        _shadowBlur * _blurToSigma,
      );
    canvas.drawCircle(
      bounds.center.translate(0, _shadowOffsetDy),
      bounds.width / 2,
      paint,
    );
  }

  /// Fills the disc inside the ring with the portrait, cropped to cover.
  static void _paintPortrait(
    ui.Canvas canvas,
    MapTokenStyle style,
    ui.Rect bounds,
    ui.Image? portrait,
  ) {
    final disc = bounds.deflate(style.ringWidth);
    canvas
      ..save()
      ..clipPath(ui.Path()..addOval(disc))
      ..drawRect(disc, ui.Paint()..color = style.fallbackColor);
    if (portrait != null) {
      canvas.drawImageRect(
        portrait,
        _coverSource(portrait),
        disc,
        ui.Paint()..filterQuality = ui.FilterQuality.medium,
      );
    }
    canvas.restore();
  }

  /// The largest square inside [image], taken [_cropAlignY] of the way
  /// down when the image is taller than it is wide.
  static ui.Rect _coverSource(ui.Image image) {
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final side = width < height ? width : height;
    final left = (width - side) / 2;
    final top = (height - side) * _cropAlignY;

    return ui.Rect.fromLTWH(left, top, side, side);
  }

  static void _paintRing(
    ui.Canvas canvas,
    MapTokenStyle style,
    ui.Rect bounds,
  ) {
    if (style.ringWidth <= 0) {
      return;
    }
    // Inset by half the stroke so the ring does not grow the footprint.
    canvas.drawCircle(
      bounds.center,
      (style.diameter - style.ringWidth) / 2,
      ui.Paint()
        ..color = style.ringColor
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = style.ringWidth,
    );
  }

  const TokenSprite._();
}

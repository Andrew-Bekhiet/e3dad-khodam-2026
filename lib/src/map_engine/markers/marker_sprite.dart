import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:e3dad_khodam_2026/src/map_engine/markers/map_marker_style.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';

/// Rasterises [MapMarkerStyle]s into style images the renderer draws.
///
/// Output is a [PixelSprite], so both surfaces register these through the
/// paths they already have: PNG on mobile, raw RGBA on web.
final class MarkerSprite {
  /// Image pixels per logical pixel. Sprites are rasterised at [scale]
  /// and declared at it, so they draw at logical size but stay sharp.
  static const double scale = 3.0;

  static const double _quarterTurn = math.pi / 4;

  static const double _shadowMargin = 2.0;

  /// Gaussian blur radius to the sigma [ui.MaskFilter.blur] takes.
  static const double _blurToSigma = 0.5;

  /// Rasterises [style] into a sprite named [MapMarkerStyle.id].
  static Future<PixelSprite> render(MapMarkerStyle style) async {
    final margin = _marginOf(style);
    final logicalSize = style.shape.diameter + margin * 2;
    final pixelSize = (logicalSize * scale).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(scale);
    final bounds = ui.Rect.fromLTWH(
      margin,
      margin,
      style.shape.diameter,
      style.shape.diameter,
    );

    _paintShadow(canvas, style, bounds);
    _paintShape(canvas, style, bounds);
    _paintGlyph(canvas, style, bounds);

    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelSize, pixelSize);
    picture.dispose();

    // Straight, not premultiplied: premultiplied bytes would darken every
    // antialiased and shadowed edge on both the PNG and GL JS paths.
    final bytes = await image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    image.dispose();
    if (bytes == null) {
      throw StateError('Failed to rasterise marker sprite "${style.id}".');
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
    Iterable<MapMarkerStyle> styles,
  ) async {
    final byId = <String, MapMarkerStyle>{
      for (final style in styles) style.id: style,
    };

    return [for (final style in byId.values) await render(style)];
  }

  static double _marginOf(MapMarkerStyle style) {
    final shadow = style.shadow;

    return shadow == null ? 0 : shadow.blur + shadow.offsetDy + _shadowMargin;
  }

  static void _paintShadow(
    ui.Canvas canvas,
    MapMarkerStyle style,
    ui.Rect bounds,
  ) {
    final shadow = style.shadow;
    if (shadow == null || shadow.opacity <= 0) {
      return;
    }
    final paint = ui.Paint()
      ..color = const ui.Color(0xFF000000).withValues(alpha: shadow.opacity)
      ..maskFilter = ui.MaskFilter.blur(
        ui.BlurStyle.normal,
        shadow.blur * _blurToSigma,
      );
    canvas
      ..save()
      ..translate(0, shadow.offsetDy);
    _drawShape(canvas, style, bounds, paint);
    canvas.restore();
  }

  static void _paintShape(
    ui.Canvas canvas,
    MapMarkerStyle style,
    ui.Rect bounds,
  ) {
    _drawShape(canvas, style, bounds, ui.Paint()..color = style.shape.color);
    if (style.shape.ringWidth <= 0) {
      return;
    }
    // Inset by half the stroke so the ring does not grow the footprint.
    final ring = ui.Paint()
      ..color = style.shape.ringColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = style.shape.ringWidth;
    _drawShape(canvas, style, bounds.deflate(style.shape.ringWidth / 2), ring);
  }

  static void _drawShape(
    ui.Canvas canvas,
    MapMarkerStyle style,
    ui.Rect bounds,
    ui.Paint paint,
  ) {
    switch (style.shape.shape) {
      case MapMarkerShape.circle:
        canvas.drawCircle(bounds.center, bounds.width / 2, paint);
      case MapMarkerShape.roundedSquare:
        canvas.drawRRect(
          ui.RRect.fromRectAndRadius(
            bounds,
            ui.Radius.circular(style.shape.cornerRadius),
          ),
          paint,
        );
      case MapMarkerShape.diamond:
        // Shrunk by √2 so the rotated corners stay inside the footprint.
        final side = bounds.width / math.sqrt2;
        final square = ui.Rect.fromCenter(
          center: bounds.center,
          width: side,
          height: side,
        );
        canvas
          ..save()
          ..translate(bounds.center.dx, bounds.center.dy)
          ..rotate(_quarterTurn)
          ..translate(-bounds.center.dx, -bounds.center.dy)
          ..drawRRect(
            ui.RRect.fromRectAndRadius(
              square,
              ui.Radius.circular(style.shape.cornerRadius),
            ),
            paint,
          )
          ..restore();
    }
  }

  static void _paintGlyph(
    ui.Canvas canvas,
    MapMarkerStyle style,
    ui.Rect bounds,
  ) {
    final glyph = style.glyph;
    if (glyph == null || glyph.size <= 0) {
      return;
    }
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontFamily: _fontFamilyOf(glyph),
              fontSize: glyph.size,
              // Makes the paragraph height exactly the em size, so the
              // centring below is exact.
              height: 1,
              textAlign: ui.TextAlign.center,
            ),
          )
          ..pushStyle(ui.TextStyle(color: glyph.color))
          ..addText(String.fromCharCode(glyph.codePoint));
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: bounds.width));
    canvas.drawParagraph(
      paragraph,
      ui.Offset(bounds.left, bounds.center.dy - paragraph.height / 2),
    );
    paragraph.dispose();
  }

  /// Flutter prefixes packaged fonts with `packages/<package>/`.
  static String _fontFamilyOf(MapMarkerGlyph glyph) => glyph.fontPackage == null
      ? glyph.fontFamily
      : 'packages/${glyph.fontPackage}/${glyph.fontFamily}';

  const MarkerSprite._();
}

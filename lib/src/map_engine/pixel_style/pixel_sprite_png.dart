import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';

/// PNG encoding for generated sprites.
extension PixelSpritePng on PixelSprite {
  /// This sprite as PNG bytes.
  ///
  /// The Maps SDK's `MbxImage` documents its `data` as raw RGBA, but the
  /// iOS implementation hands it to `UIImage(data:)` and fails with
  /// "Could not initialize the image from the specified data" on
  /// anything that is not an encoded image — the plugin's own example
  /// passes a PNG. Mapbox GL JS wants the opposite (raw RGBA in a
  /// `{width, height, data}` object), so the web surface uses [rgba]
  /// directly and only the mobile surface comes through here.
  ///
  /// Encoding is lossless and the palette has five colours, so nothing
  /// about the artwork changes; it costs one decode/encode per pattern
  /// at startup.
  Future<Uint8List> toPng() async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(rgba);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    codec.dispose();
    descriptor.dispose();
    if (png == null) {
      throw StateError('Failed to encode sprite "$id" as PNG.');
    }

    return png.buffer.asUint8List();
  }
}

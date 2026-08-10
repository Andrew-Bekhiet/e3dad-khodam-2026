import 'dart:ui' as ui;

import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_palette.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite.dart';
import 'package:e3dad_khodam_2026/src/map_engine/pixel_style/pixel_sprite_png.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PixelSpritePng', () {
    test('encodesEverySpriteAsADecodablePng', () async {
      for (final sprite in PixelSprites.build(PixelPalette.tuned())) {
        final png = await sprite.toPng();

        // The PNG magic number — what the iOS SDK's decoder looks for,
        // and the whole reason this encoding step exists.
        expect(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);

        final codec = await ui.instantiateImageCodec(png);
        final frame = await codec.getNextFrame();
        expect(frame.image.width, sprite.width);
        expect(frame.image.height, sprite.height);
        frame.image.dispose();
        codec.dispose();
      }
    });

    test('roundTripsThePixelsUnchanged', () async {
      final sprite = PixelSprites.build(PixelPalette.tuned()).first;
      final codec = await ui.instantiateImageCodec(await sprite.toPng());
      final frame = await codec.getNextFrame();
      final decoded = await frame.image.toByteData();
      if (decoded == null) {
        fail('toByteData returned null');
      }

      expect(decoded.buffer.asUint8List(), sprite.rgba);
      frame.image.dispose();
      codec.dispose();
    });
  });
}

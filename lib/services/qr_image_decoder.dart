import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

class QrImageDecoder {
  static String? decodeFromPath(String path) {
    try {
      final bytes = File(path).readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final source = RGBLuminanceSource(
        image.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.rgba)
            .buffer
            .asInt32List(),
      );
      final bitmap = BinaryBitmap(HybridBinarizer(source));
      return QRCodeReader().decode(bitmap).text;
    } catch (_) {
      return null;
    }
  }
}

import 'dart:typed_data';
import 'dart:ui';

class PictureUtils {
  static Future<Uint8List> finalizePicture(
      PictureRecorder recorder, double size) async {
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

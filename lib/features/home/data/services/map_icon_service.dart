import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart' as vg;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

enum AvatarShape { circle, rounded }

@injectable
class MapIconService {
  Future<Uint8List> _convertSvgToPng(
      String svgString, double width, double height) async {
    final SvgStringLoader svgStringLoader = SvgStringLoader(svgString);
    final PictureInfo pictureInfo =
        await vg.vg.loadPicture(svgStringLoader, null);
    final ui.Picture picture = pictureInfo.picture;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas =
        Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(width, height)));
    canvas.scale(
        width / pictureInfo.size.width, height / pictureInfo.size.height);
    canvas.drawPicture(picture);

    final ui.Image imgByteData =
        await recorder.endRecording().toImage(width.ceil(), height.ceil());
    final ByteData? bytesData =
        await imgByteData.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = bytesData?.buffer.asUint8List() ?? Uint8List(0);

    pictureInfo.picture.dispose();
    return imageData;
  }

  /// Загружает SVG иконку с сервера и конвертирует в растровое изображение
  Future<Uint8List?> loadSvgIcon(String iconUrl, {double size = 24}) async {
    try {
      // Загружаем SVG с сервера
      final response = await http.get(Uri.parse(iconUrl));
      if (response.statusCode != 200) {
        debugPrint('Failed to load icon from $iconUrl: ${response.statusCode}');
        return null;
      }
      return await _convertSvgToPng(response.body, size, size);
    } catch (e) {
      debugPrint('Error loading SVG icon from $iconUrl: $e');
    }

    return null;
  }

  Future<Uint8List?> loadNetworkAvatar(
    String imageUrl, {
    double size = 96,
    Color borderColor = Colors.orange,
    double borderWidth = 4,
    AvatarShape shape = AvatarShape.circle,
    double borderRadius = 8, // для rounded
  }) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        debugPrint(
            'Failed to load image from $imageUrl: ${response.statusCode}');
        return null;
      }

      final Uint8List rawBytes = response.bodyBytes;

      // Декодируем картинку
      final ui.Codec codec = await ui.instantiateImageCodec(rawBytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image sourceImage = frame.image;

      // Подготовка канваса
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Rect dstRect = Rect.fromLTWH(0, 0, size, size);

      // Прозрачный фон
      final Paint clearPaint = Paint()..blendMode = BlendMode.clear;
      canvas.drawRect(dstRect, clearPaint);

      // Подготовка клипа
      Path? clipPath;
      RRect? clipRRect;

      if (shape == AvatarShape.circle) {
        final double radius = size / 2;
        clipPath = Path()
          ..addOval(
              Rect.fromCircle(center: Offset(radius, radius), radius: radius));
      } else {
        clipRRect = RRect.fromRectAndRadius(
          dstRect,
          Radius.circular(borderRadius),
        );
      }

      canvas.saveLayer(dstRect, Paint());
      if (shape == AvatarShape.circle && clipPath != null) {
        canvas.clipPath(clipPath, doAntiAlias: true);
      } else if (shape == AvatarShape.rounded && clipRRect != null) {
        canvas.clipRRect(clipRRect, doAntiAlias: true);
      }

      // Рассчитываем aspect-ratio crop (cover)
      final double srcAspect = sourceImage.width / sourceImage.height;
      const double dstAspect = 1;
      Rect srcRect;
      if (srcAspect > dstAspect) {
        final double newWidth = sourceImage.height * dstAspect;
        final double x = (sourceImage.width - newWidth) / 2;
        srcRect = Rect.fromLTWH(x, 0, newWidth, sourceImage.height.toDouble());
      } else {
        final double newHeight = sourceImage.width / dstAspect;
        final double y = (sourceImage.height - newHeight) / 2;
        srcRect = Rect.fromLTWH(0, y, sourceImage.width.toDouble(), newHeight);
      }

      // Рисуем изображение
      final Paint imagePaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;
      canvas.drawImageRect(sourceImage, srcRect, dstRect, imagePaint);

      canvas.restore();

      // Рисуем обводку
      final Paint strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor
        ..isAntiAlias = true;

      if (shape == AvatarShape.circle) {
        final double radius = size / 2;
        canvas.drawCircle(
          Offset(radius, radius),
          radius - borderWidth / 2,
          strokePaint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            dstRect.deflate(borderWidth / 2),
            Radius.circular(borderRadius),
          ),
          strokePaint,
        );
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
      final ByteData? pngBytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();

      if (pngBytes == null) return null;
      return pngBytes.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading network avatar from $imageUrl: $e');
      return null;
    }
  }
}

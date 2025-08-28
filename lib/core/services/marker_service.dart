import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../utils/picture_utils.dart';

sealed class MarkerStyleOptions {}

class CircleWithImageOptions extends MarkerStyleOptions {
  final String imageUrl;
  final double size;

  CircleWithImageOptions({
    required this.imageUrl,
    this.size = 50,
  });
}

class CircleWithIconOptions extends MarkerStyleOptions {
  final int iconCode;
  final Color backgroundColor;
  final Color iconColor;
  final String? fontFamily;
  final double size;

  CircleWithIconOptions({
    required this.iconCode,
    required this.backgroundColor,
    required this.iconColor,
    this.fontFamily,
    this.size = 50,
  });
}

class EmptyCircleOptions extends MarkerStyleOptions {
  final Color color;
  final double size;

  EmptyCircleOptions({
    required this.color,
    this.size = 50,
  });
}

abstract class MarkerService {
  /// Создает маркер для свойства на основе стиля
  Future<Uint8List> generateMarker({
    required MarkerStyleOptions options,
  });

  /// Создает маркер с изображением в круге
  Future<Uint8List> createImageMarker(
      {required CircleWithImageOptions options});

  /// Создает маркер с иконкой
  Future<Uint8List> createIconMarker({required CircleWithIconOptions options});

  /// Создает обычный круг
  Future<Uint8List> createSimpleMarker({required EmptyCircleOptions options});

  /// Загружает изображение из URL
  Future<Uint8List> loadImageFromUrl(String url);
}

@Injectable(as: MarkerService)
class MarkerServiceImpl implements MarkerService {
  MarkerServiceImpl();

  @override
  Future<Uint8List> generateMarker({
    required MarkerStyleOptions options,
  }) async {
    switch (options) {
      case CircleWithImageOptions o:
        return createImageMarker(options: o);

      case CircleWithIconOptions o:
        return createIconMarker(options: o);

      case EmptyCircleOptions o:
        return createSimpleMarker(options: o);
    }
  }

  @override
  Future<Uint8List> createImageMarker(
      {required CircleWithImageOptions options}) async {
    final imageBytes = await loadImageFromUrl(options.imageUrl);
    return _makeCircleFromImage(imageBytes, options.size);
  }

  @override
  Future<Uint8List> createIconMarker(
      {required CircleWithIconOptions options}) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = options.size / 2;

    // Рисуем фон
    final backgroundPaint = Paint()
      ..isAntiAlias = true
      ..color = options.backgroundColor;

    canvas.drawCircle(Offset(radius, radius), radius, backgroundPaint);

    // Рисуем иконку
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(options.iconCode),
        style: TextStyle(
          fontSize: options.size * 0.5, // 50% от размера маркера
          fontFamily: options.fontFamily,
          color: options.iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (options.size - textPainter.width) / 2,
        (options.size - textPainter.height) / 2,
      ),
    );

    return PictureUtils.finalizePicture(recorder, options.size);
  }

  @override
  Future<Uint8List> createSimpleMarker(
      {required EmptyCircleOptions options}) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = options.size / 2;
    const borderWidth = 10.0;

    final borderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = options.color;

    canvas.drawCircle(
      Offset(radius, radius),
      radius - borderWidth / 2,
      borderPaint,
    );

    final fillPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = options.color.withValues(alpha: 0.6);

    canvas.drawCircle(
      Offset(radius, radius),
      radius - borderWidth,
      fillPaint,
    );

    return PictureUtils.finalizePicture(recorder, options.size);
  }

  @override
  Future<Uint8List> loadImageFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<Uint8List> _makeCircleFromImage(
      Uint8List imageBytes, double size) async {
    final radius = size / 2;

    final codec = await instantiateImageCodec(
      imageBytes,
      targetWidth: size.toInt(),
      targetHeight: size.toInt(),
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Рисуем круг
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    paint.blendMode = BlendMode.srcIn;
    canvas.drawImage(image, Offset.zero, paint);

    return PictureUtils.finalizePicture(recorder, size);
  }
}

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

class ImagePainter extends CustomPainter {
  final Offset offset;
  final ui.Image image;
  final double pixelRatio;

  ImagePainter(this.image, this.offset, {this.pixelRatio = 3.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Масштабируем изображение с учетом pixelRatio
    final scaledWidth = image.width / pixelRatio;
    final scaledHeight = image.height / pixelRatio;

    // Создаем целевой прямоугольник для рисования изображения
    final dstRect =
        Rect.fromLTWH(offset.dx, offset.dy, scaledWidth, scaledHeight);

    // Рисуем изображение с учетом pixelRatio
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        dstRect,
        Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

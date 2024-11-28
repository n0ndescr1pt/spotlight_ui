import 'dart:ui' as ui;

import 'package:flutter/material.dart';
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

class ArrowPainter extends CustomPainter {
  final bool isAbove;

  ArrowPainter({this.isAbove = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;
    final Path path = Path();

    if (isAbove) {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

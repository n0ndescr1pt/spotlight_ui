import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HighlightStorage {
  List<ui.Image> images;
  List<Offset> offsets;
  List<Size> size;

  HighlightStorage({
    required this.images,
    required this.offsets,
    required this.size,
  });

  void clear() {
    images.clear();
    offsets.clear();
    size.clear();
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spotlight_ui/src/image_painter.dart';
import 'package:spotlight_ui/src/spotlight_controller.dart';

class SpotlightOverlay extends StatefulWidget {
  final Widget child;
  final SpotlightController spotlightController;
  const SpotlightOverlay(
      {super.key, required this.child, required this.spotlightController});

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay> {
  List<ui.Image> _highlightImages = [];
  List<Offset> _highlightOffsets = [];

  @override
  void initState() {
    widget.spotlightController.currentStep.addListener(() {
      _captureHighlightedWidget(widget.spotlightController.currentStep.value);
    });
    super.initState();
  }

  Future<void> _captureHighlightedWidget(int currentStep) async {
    final List<ui.Image> images = [];
    final List<Offset> offsets = [];
    final List<Size> sizes = [];

    //TODO проверка на долбаеба если null
    final _highlightKeys = widget.spotlightController.highlightKeys;

    for (int i = 0; i < _highlightKeys[currentStep]!.length; i++) {
      final RenderRepaintBoundary? boundary = _highlightKeys[currentStep]![i]
          .currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        final Offset offset = boundary.localToGlobal(Offset.zero);
        final Size size = boundary.size;

        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        images.add(image);
        offsets.add(offset);
        sizes.add(size);
      }
    }

    _highlightImages = images;
    _highlightOffsets = offsets;

    //_animationController.forward(from: 0.0); TODOсделать
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7)), //TODO вынести
        ),
        ...List.generate(_highlightImages.length, (index) {
          return CustomPaint(
            painter:
                ImagePainter(_highlightImages[index], _highlightOffsets[index]),
          );
        }),
      ],
    );
  }
}

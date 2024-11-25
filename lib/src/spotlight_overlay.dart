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
  List<Size> _highlightSize = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureHighlightedWidget(widget.spotlightController.currentStep.value);
    });

    widget.spotlightController.currentStep.addListener(_stepListener);
    super.initState();
  }

  void _stepListener() {
    _captureHighlightedWidget(widget.spotlightController.currentStep.value);
  }

  @override
  void dispose() {
    widget.spotlightController.currentStep.removeListener(_stepListener);
    super.dispose();
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
    print("$currentStep asdoakdpasd");
    setState(() {
      _highlightImages = images;
      _highlightOffsets = offsets;
      _highlightSize = sizes;
    });

    //_animationController.forward(from: 0.0); TODOсделать
  }

  @override
  Widget build(BuildContext context) {
    print(_highlightOffsets);
    return Stack(
      children: [
        widget.child,
        GestureDetector(
          onTap: () {
            print(widget.spotlightController.currentStep.value);
            widget.spotlightController.nextStep();
            print(widget.spotlightController.currentStep.value);
          },
          child: Container(color: Colors.black.withOpacity(0.7) //TODO вынести
              ),
        ),
        ...List.generate(_highlightImages.length, (index) {
          return CustomPaint(
            painter:
                ImagePainter(_highlightImages[index], _highlightOffsets[index]),
          );
        }),
        if (_highlightImages.isNotEmpty)
          Positioned(
            top: _highlightOffsets[_highlightOffsets.length - 1].dy +
                _highlightSize[_highlightSize.length - 1].height +
                12,
            left: 12,
            right: 12,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: 100,
            ),
          )
      ],
    );
  }
}

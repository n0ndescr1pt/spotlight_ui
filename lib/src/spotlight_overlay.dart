import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spotlight_ui/src/controller_provider.dart';
import 'package:spotlight_ui/src/painters.dart';
import 'package:spotlight_ui/src/spotlight_controller.dart';
import 'package:spotlight_ui/src/tooltip_widget.dart';

class SpotlightOverlay extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final SpotlightController spotlightController;
  const SpotlightOverlay(
      {super.key,
      required this.child,
      required this.spotlightController,
      this.scrollController});

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<ui.Image> _highlightImages = [];
  List<Offset> _highlightOffsets = [];
  List<Size> _highlightSize = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          Duration(milliseconds: 400),
          () => _captureHighlightedWidget(
              widget.spotlightController.currentStep.value));
    });

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Interval(0.0, 1.0));
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
    final _highlightKeys = widget.spotlightController.highlightKeys;
    final RenderBox renderBox = _highlightKeys[currentStep]!
        .last
        .currentContext!
        .findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final ScrollController? controller = widget.scrollController;

    if (controller != null) {
      final double targetOffset = offset.dy + controller.offset;
      await _scrollToHighlightedWidget(targetOffset);
    }

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
    setState(() {
      _highlightImages = images;
      _highlightOffsets = offsets;
      _highlightSize = sizes;
    });

    _animationController.forward(from: 0.0);
  }

  Future<void> _scrollToHighlightedWidget(double offset) async {
    if (_highlightOffsets.isNotEmpty && _highlightSize.isNotEmpty) {
      final double screenHeight = MediaQuery.of(context).size.height;
      final double highlightBottom =
          _highlightOffsets.last.dy + _highlightSize.last.height;

      if (highlightBottom + 300 > screenHeight) {
        //TODO убрать 300 и высчитывать высоту тултип виджета
        _animationController.reverse(from: 0.25);
        final ScrollController? controller = widget.scrollController;

        if (controller != null) {
          print(offset);
          await controller.animateTo(
            offset - _highlightSize.last.height,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double left = 0;
    if (_highlightImages.isNotEmpty) {
      double offset = 0;
      double size = 0;
      for (int i = 0; i < _highlightImages.length; i++) {
        offset += _highlightOffsets[i].dx;
        size += _highlightSize[i].width;
      }
      offset = offset / _highlightOffsets.length - 1;
      size = size / _highlightSize.length - 1;
      left = offset + size / 2 - 12;

// Проверка, чтобы значение left не было меньше 12
      if (left < 12) {
        left = 12;
      }

// Проверка, чтобы значение left не выходило за пределы экрана
      if (left > MediaQuery.of(context).size.width - 12) {
        left = MediaQuery.of(context).size.width - 12;
      }
    }
    print(_highlightOffsets);
    return ControllerProvider(
      spotlightController: widget.spotlightController,
      child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, snapshot) {
            return Stack(
              children: [
                widget.child,
                GestureDetector(
                  onTap: () => widget.spotlightController.nextStep(),
                  child: Container(
                    color: Colors.black.withOpacity(0.7), //TODO вынести
                  ),
                ),
                ...List.generate(_highlightImages.length, (index) {
                  return FadeTransition(
                    opacity: _animation,
                    child: CustomPaint(
                      painter: ImagePainter(
                          _highlightImages[index], _highlightOffsets[index]),
                    ),
                  );
                }),
                if (_highlightImages.isNotEmpty) ...[
                  Positioned(
                    top: _highlightOffsets[_highlightOffsets.length - 1].dy +
                        _highlightSize[_highlightSize.length - 1].height +
                        4,
                    left: left + 2,
                    child: FadeTransition(
                      opacity: _animation,
                      child: CustomPaint(
                        size: Size(24, 12), // Размер стрелки
                        painter: ArrowPainter(), // Рисуем стрелку
                      ),
                    ),
                  ),
                  Positioned(
                    top: _highlightOffsets[_highlightOffsets.length - 1].dy +
                        _highlightSize[_highlightSize.length - 1].height +
                        16,
                    left: 12,
                    right: 12,
                    child: FadeTransition(
                        opacity: _animation,
                        child: widget.spotlightController.tooltipWidgets[
                            widget.spotlightController.currentStep.value]),
                  ),
                ]
              ],
            );
          }),
    );
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spotlight_ui/src/controller_provider.dart';
import 'package:spotlight_ui/src/painters.dart';
import 'package:spotlight_ui/src/spotlight_controller.dart';

class SpotlightOverlay extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final SpotlightController spotlightController;
  final Duration animationDuration;
  final Duration scrollAnimationDuration;
  final ArrowSettings arrowSettings;
  final bool isEnabled;
  const SpotlightOverlay({
    super.key,
    this.isEnabled = true,
    required this.child,
    required this.spotlightController,
    this.scrollController,
    this.animationDuration = const Duration(milliseconds: 400),
    this.scrollAnimationDuration = const Duration(milliseconds: 400),
    this.arrowSettings =
        const ArrowSettings(color: Colors.white, size: Size(24, 12)),
  });

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay>
    with TickerProviderStateMixin {
  late Map<int, SpotlightStep> steps;
  late SpotlightController spotlightController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late bool isEnable;

  List<ui.Image> _highlightImages = [];
  List<Offset> _highlightOffsets = [];
  List<Size> _highlightSize = [];
  @override
  void initState() {
    isEnable = widget.isEnabled;
    steps = widget.spotlightController.steps;
    spotlightController = widget.spotlightController;

    _initHighlight();
    _buildAnimation();
    spotlightController.currentStep.addListener(_stepListener);

    super.initState();
  }

  void _initHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          const Duration(milliseconds: 900),
          () =>
              _captureHighlightedWidget(spotlightController.currentStep.value));
    });
  }

  void _buildAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _animation = CurvedAnimation(
        parent: _animationController, curve: const Interval(0.0, 1.0));
  }

  void _stepListener() {
    _captureHighlightedWidget(spotlightController.currentStep.value);
  }

  Future<void> _captureHighlightedWidget(int currentStep) async {
    final List<ui.Image> images = [];
    final List<Offset> offsets = [];
    final List<Size> sizes = [];
    await WidgetsBinding.instance.endOfFrame;
    await _scrollToHighlightedWidget();
    final length = steps[currentStep]?.highlightKeys.length ?? 0;
    for (int i = 0; i < length; i++) {
      final RenderRepaintBoundary? boundary = steps[currentStep]
          ?.highlightKeys[i]
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

  Future<void> _scrollToHighlightedWidget() async {
    final ScrollController? controller = widget.scrollController;
    if (controller == null) return;

    final highlightKeys =
        spotlightController.steps[spotlightController.currentStep.value];
    final RenderRepaintBoundary? boundary =
        highlightKeys?.highlightKeys.last.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary != null) {
      final Offset offset = boundary.localToGlobal(Offset.zero);
      final double targetOffset = offset.dy / 1.3 + controller.offset;
      final Size size = boundary.size;

      final double screenHeight = MediaQuery.of(context).size.height;
      final double highlightBottom = offset.dy + size.height;
      final toolTipHeight = spotlightController
              .steps[spotlightController.currentStep.value]?.tooltip.height ??
          0;
      print(controller.position.maxScrollExtent);
      print(controller.offset);
      print(offset.dy);
      print("TOOLTIP  $toolTipHeight");
      if (highlightBottom + toolTipHeight + 20 > screenHeight) {
        _animationController.reverse(from: 0.0);

        if (targetOffset > controller.position.maxScrollExtent) {
          print("scrolling...");
          await controller.animateTo(
            controller.position.maxScrollExtent,
            duration: widget.scrollAnimationDuration,
            curve: Curves.easeInOut,
          );
          //TODO сделать если скролить надо много то количество времени больше
        } else if (targetOffset > controller.position.pixels) {
          await controller.animateTo(
            targetOffset,
            duration: widget.scrollAnimationDuration,
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }

  double _calculateLeftOffset() {
    double offset = 0, size = 0;
    for (int i = 0; i < _highlightImages.length; i++) {
      offset += _highlightOffsets[i].dx;
      size += _highlightSize[i].width;
    }
    offset /= _highlightOffsets.length;
    size /= _highlightSize.length;
    return offset + size / 2 - 12;
  }

  bool _calculateIsAboveTooltip(double tooltipHeight) {
    if (_highlightImages.isNotEmpty &&
        _highlightOffsets.first.dy +
                _highlightSize.first.height +
                tooltipHeight +
                20 >
            MediaQuery.of(context).size.height) {
      print("true");
      return true;
    }
    return false;
  }

  List<Widget> _buildHighlightWidgets() {
    return List.generate(_highlightImages.length, (index) {
      return FadeTransition(
        opacity: _animation,
        child: CustomPaint(
          painter:
              ImagePainter(_highlightImages[index], _highlightOffsets[index]),
        ),
      );
    });
  }

  Widget _buildArrowWidget(
    bool isAbove,
    double left,
  ) {
    return Positioned(
      top: isAbove
          ? _highlightOffsets.last.dy - 12
          : _highlightOffsets.first.dy + _highlightSize.first.height + 4,
      left: left,
      child: FadeTransition(
        opacity: _animation,
        child: CustomPaint(
          size: Size(24, 12),
          painter: ArrowPainter(
            isAbove: isAbove,
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipWidget(bool isAbove, double tooltipHeight) {
    print("      asdfsdfsdfs$tooltipHeight");
    return Positioned(
      top: isAbove
          ? _highlightOffsets.last.dy - tooltipHeight - 12
          : _highlightOffsets.first.dy + _highlightSize.first.height + 16,
      left: 12,
      right: 12,
      child: FadeTransition(
          opacity: _animation,
          child: spotlightController
              .steps[spotlightController.currentStep.value]!.tooltip),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isEnable) {
      final tooltipHeight = spotlightController
              .steps[spotlightController.currentStep.value]?.tooltip.height ??
          0;
      bool isAbove = false;
      double left = 0;
      if (_highlightImages.isNotEmpty) {
        left = _clamp(
            _calculateLeftOffset(), 12, MediaQuery.of(context).size.width - 12);
        isAbove = _calculateIsAboveTooltip(tooltipHeight);
      }
      return ControllerProvider(
        spotlightController: spotlightController,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, snapshot) {
            return Stack(
              children: [
                widget.child,
                GestureDetector(
                  onTap: () => spotlightController.nextStep(),
                  child: Container(
                    color: Colors.black.withOpacity(0.7), //TODO вынести
                  ),
                ),
                ..._buildHighlightWidgets(),
                if (_highlightImages.isNotEmpty) ...[
                  _buildArrowWidget(isAbove, left),
                  _buildTooltipWidget(isAbove, tooltipHeight),
                ]
              ],
            );
          },
        ),
      );
    } else {
      return widget.child;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.spotlightController.currentStep.removeListener(_stepListener);
    super.dispose();
  }
}

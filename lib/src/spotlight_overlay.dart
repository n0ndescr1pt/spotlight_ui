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
  final Duration waitBeforeStartDuration;

  const SpotlightOverlay({
    super.key,
    required this.child,
    required this.spotlightController,
    this.scrollController,
    this.animationDuration = const Duration(milliseconds: 400),
    this.scrollAnimationDuration = const Duration(milliseconds: 400),
    this.arrowSettings =
        const ArrowSettings(color: Colors.white, size: Size(24, 12)),
    this.waitBeforeStartDuration = const Duration(milliseconds: 900),
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
  late bool _isEnable;

  List<ui.Image> _highlightImages = [];
  List<Offset> _highlightOffsets = [];
  List<Size> _highlightSize = [];
  @override
  void initState() {
    steps = widget.spotlightController.steps;
    spotlightController = widget.spotlightController;
    _isEnable = spotlightController.isEnabled.value;
    if (_isEnable) {
      _initHighlight();
      _buildAnimation();
      spotlightController.currentStep.addListener(_stepListener);
      spotlightController.isEnabled.addListener(() => setState(() {
            _isEnable = spotlightController.isEnabled.value;
          }));
    }

    super.initState();
  }

  void _initHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          widget.waitBeforeStartDuration,
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

    await _scrollToHighlightedWidget();
    await WidgetsBinding.instance.endOfFrame;
    final length = steps[currentStep]?.highlightKeys.length ?? 0;
    for (int i = 0; i < length; i++) {
      final RenderRepaintBoundary? boundary = steps[currentStep]
          ?.highlightKeys[i]
          .currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        final Offset offset = boundary.localToGlobal(Offset.zero);
        final Size size = boundary.size;

        final ui.Image image = await boundary.toImage(pixelRatio: 6.0);
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

    List<MapEntry<GlobalKey, Offset>> positions = [];

    for (var key in highlightKeys?.highlightKeys ?? <GlobalKey>[]) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        positions.add(MapEntry(key, position));
      }
    }

    if (positions.isNotEmpty) {
      positions.sort((a, b) => a.value.dy.compareTo(b.value.dy));

      final RenderRepaintBoundary? boundary = positions.first.key.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final Offset offset = boundary.localToGlobal(Offset.zero);
        final double targetOffset = offset.dy - 20 + controller.offset;
        final Size size = boundary.size;

        final double screenHeight = MediaQuery.of(context).size.height;
        final double highlightBottom = offset.dy + size.height;
        final toolTipHeight = spotlightController
                .steps[spotlightController.currentStep.value]?.tooltip.height ??
            0;
        if (highlightBottom + toolTipHeight +100 > screenHeight) {
          _animationController.reverse(from: 0.0);

          if (targetOffset > controller.position.maxScrollExtent) {
            await controller.animateTo(
              controller.position.maxScrollExtent,
              duration: widget.scrollAnimationDuration,
              curve: Curves.easeInOut,
            );
          } else if (targetOffset > controller.position.pixels) {
            await controller.animateTo(
              targetOffset-25,
              duration: widget.scrollAnimationDuration,
              curve: Curves.easeInOut,
            );
          }
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
    return offset + size / 2 - 13;
  }

  bool _calculateIsAboveTooltip(double tooltipHeight) {
    if (_highlightImages.isNotEmpty &&
        _highlightOffsets.first.dy +
                _highlightSize.first.height +
                tooltipHeight +
                20 >
            MediaQuery.of(context).size.height) {
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
    final highlightKeys =
        spotlightController.steps[spotlightController.currentStep.value];

    List<MapEntry<GlobalKey, Offset>> positions = [];

    for (var key in highlightKeys?.highlightKeys ?? <GlobalKey>[]) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        positions.add(MapEntry(key, position));
      }
    }

    if (positions.isNotEmpty) {
      positions.sort((a, b) => a.value.dy.compareTo(b.value.dy));
    }
    return Positioned(
      top: isAbove
          ? positions.first.value.dy - 12
          : positions.last.value.dy + _highlightSize.first.height + 8,
      left: left + 6,
      child: FadeTransition(
        opacity: _animation,
        child: CustomPaint(
          size: const Size(14, 8),
          painter: ArrowPainter(isAbove: isAbove),
        ),
      ),
    );
  }

  Widget _buildTooltipWidget(bool isAbove, double tooltipHeight) {
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
    if (_isEnable) {
      final tooltipHeight = spotlightController
              .steps[spotlightController.currentStep.value]?.tooltip.height ??
          0;
      bool isAbove = false;
      double left = 0;
      if (_highlightImages.isNotEmpty) {
        left = _clamp(
            _calculateLeftOffset(), 24, MediaQuery.of(context).size.width - 50);
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

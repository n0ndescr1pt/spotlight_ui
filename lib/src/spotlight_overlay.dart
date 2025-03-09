import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spotlight_ui/src/controller_provider.dart';
import 'package:spotlight_ui/src/highlight_storage.dart';
import 'package:spotlight_ui/src/painters.dart';
import 'package:spotlight_ui/src/spotlight_controller.dart';

/// Widget that provides an overlay for the onboarding spotlight.
class SpotlightOverlay extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final SpotlightController spotlightController;
  final Duration animationDuration;
  final Duration scrollAnimationDuration;
  final ArrowSettings arrowSettings;
  final Duration waitBeforeStartDuration;
  final double scrollOffset;

  const SpotlightOverlay({
    super.key,
    required this.child,
    required this.spotlightController,
    this.scrollController,
    this.animationDuration = const Duration(milliseconds: 400),
    this.scrollAnimationDuration = const Duration(milliseconds: 400),
    this.arrowSettings = const ArrowSettings(),
    this.waitBeforeStartDuration = const Duration(milliseconds: 600),
    this.scrollOffset = 0,
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

  final HighlightStorage _highlightsStorage =
      HighlightStorage(images: [], offsets: [], size: []);

  @override
  void initState() {
    super.initState();
    steps = widget.spotlightController.steps;
    spotlightController = widget.spotlightController;
    _isEnable = spotlightController.isEnabled.value;
    if (_isEnable) {
      _initializeHighlightProcess();
      _initializeAnimation();
      spotlightController.currentStep.addListener(_stepListener);
      spotlightController.isEnabled.addListener(() => setState(() {
            _isEnable = spotlightController.isEnabled.value;
          }));
    }
  }

  /// Initializes the highlight process by capturing the first widget.
  void _initializeHighlightProcess() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          widget.waitBeforeStartDuration,
          () =>
              _captureHighlightedWidget(spotlightController.currentStep.value));
    });
  }

  /// Builds the animation controller and its curve.
  void _initializeAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _animation = CurvedAnimation(
        parent: _animationController, curve: const Interval(0.0, 1.0));
  }

  /// Listener that updates the highlighted widget when the step changes.
  void _stepListener() {
    if (spotlightController.currentStep.value >= 0) {
      if (spotlightController.currentStep.value == 0) {
        _initializeHighlightProcess();
      }
      _captureHighlightedWidget(spotlightController.currentStep.value);
    } else {
      setState(() {
        _highlightsStorage.clear();
      });
    }
  }

  /// Captures the currently highlighted widget and stores its properties.
  Future<void> _captureHighlightedWidget(int currentStep) async {
    final List<ui.Image> images = [];
    final List<Offset> offsets = [];
    final List<Size> sizes = [];

    await _scrollToHighlightedWidget();
    await WidgetsBinding.instance.endOfFrame;
    final listStep = steps.keys.toList();
    checkConsistent(listStep);
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
      _highlightsStorage.images = images;
      _highlightsStorage.offsets = offsets;
      _highlightsStorage.size = sizes;
    });

    _animationController.forward(from: 0.0);
  }

  void checkConsistent(List<int> listStep) {
    for (var i = 0; i < steps.length - 1; i++) {
      if (listStep[i]++ != listStep[i + 1]) {
        throw Exception("The steps should be consistent");
      }
    }
  }

  /// Scrolls to the widget currently being highlighted.
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
        final double targetOffset =
            offset.dy - 20 + controller.offset - widget.scrollOffset;
        final Size size = boundary.size;

        final double screenHeight = MediaQuery.of(context).size.height;
        final double highlightBottom = offset.dy + size.height;
        final toolTipHeight = spotlightController
                .steps[spotlightController.currentStep.value]?.tooltip.height ??
            0;
        if (highlightBottom + toolTipHeight + 100 > screenHeight) {
          _animationController.reverse(from: 0.0);

          if (targetOffset > controller.position.maxScrollExtent) {
            await controller.animateTo(
              controller.position.maxScrollExtent,
              duration: widget.scrollAnimationDuration,
              curve: Curves.easeInOut,
            );
          } else if (targetOffset > controller.position.pixels) {
            await controller.animateTo(
              targetOffset - 20,
              duration: widget.scrollAnimationDuration,
              curve: Curves.easeInOut,
            );
          }
        }
      }
    }
  }

  /// Clamps a value between a minimum and maximum range.
  double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }

  /// Calculates the horizontal offset for tooltip placement.
  double _calculateLeftOffset() {
    double offset = 0, size = 0;
    for (int i = 0; i < _highlightsStorage.images.length; i++) {
      offset += _highlightsStorage.offsets[i].dx;
      size += _highlightsStorage.size[i].width;
    }
    offset /= _highlightsStorage.offsets.length;
    size /= _highlightsStorage.size.length;
    return offset + size / 2 - 13;
  }

  /// Determines if the tooltip should be displayed above the highlighted widget.
  bool _calculateIsAboveTooltip(double tooltipHeight) {
    if (_highlightsStorage.images.isNotEmpty &&
        _highlightsStorage.offsets.first.dy +
                _highlightsStorage.size.first.height +
                tooltipHeight +
                20 >
            MediaQuery.of(context).size.height) {
      return true;
    }
    return false;
  }

  /// Builds the highlight widgets.
  List<Widget> _buildHighlightWidgets() {
    return List.generate(_highlightsStorage.images.length, (index) {
      return FadeTransition(
        opacity: _animation,
        child: CustomPaint(
          painter: ImagePainter(
            _highlightsStorage.images[index],
            _highlightsStorage.offsets[index],
          ),
        ),
      );
    });
  }

  /// Builds the arrow widget for the tooltip.
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
          : positions.last.value.dy + _highlightsStorage.size.first.height + 8,
      left: left + 6,
      child: FadeTransition(
        opacity: _animation,
        child: CustomPaint(
          size: widget.arrowSettings.size,
          painter: ArrowPainter(
            isAbove: isAbove,
            color: widget.arrowSettings.color,
          ),
        ),
      ),
    );
  }

  /// Builds the tooltip widget.
  Widget _buildTooltipWidget(bool isAbove, double tooltipHeight) {
    return Positioned(
      top: isAbove
          ? _highlightsStorage.offsets.last.dy - tooltipHeight - 12
          : _highlightsStorage.offsets.first.dy +
              _highlightsStorage.size.first.height +
              16,
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
    if (_isEnable && spotlightController.currentStep.value >= 0) {
      final tooltipHeight = spotlightController
              .steps[spotlightController.currentStep.value]?.tooltip.height ??
          0;
      bool isAbove = false;
      double left = 0;
      if (_highlightsStorage.images.isNotEmpty) {
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
                    color: const Color.fromARGB(179, 0, 0, 0),
                  ),
                ),
                ..._buildHighlightWidgets(),
                if (_highlightsStorage.images.isNotEmpty) ...[
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

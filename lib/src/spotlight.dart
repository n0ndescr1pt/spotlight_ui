part of 'spotlight_controller.dart';

class Spotlight extends StatefulWidget {
  final int step;
  final Widget child;
  final TooltipWidget? tooltip;
  const Spotlight({
    super.key,
    required this.step,
    required this.child,
    this.tooltip,
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  final GlobalKey _key = GlobalKey();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ControllerProvider.of(context)?.spotlightController;
      controller?._addStep(widget.step, _key, tooltip: widget.tooltip);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: widget.child,
    );
  }
}

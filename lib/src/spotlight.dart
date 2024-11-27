import 'package:flutter/material.dart';
import 'package:spotlight_ui/spotlight_ui.dart';
import 'package:spotlight_ui/src/controller_provider.dart';

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
  int i = 0;
  final GlobalKey _key = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SpotlightController controller =
        ControllerProvider.of(context)!.spotlightController;
    if (i < 1) controller.addKey(widget.step, _key, widget.tooltip);
    i++; //TODO что то придумать
    return RepaintBoundary(
      key: _key,
      child: widget.child,
    );
  }
}

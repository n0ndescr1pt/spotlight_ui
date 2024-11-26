import 'package:flutter/material.dart';
import 'package:spotlight_ui/src/spotlight_controller.dart';

class Spotlight extends StatefulWidget {
  final SpotlightController controller;
  final int step;
  final Widget child;
  const Spotlight({
    super.key,
    required this.controller,
    required this.step,
    required this.child,
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  final GlobalKey _key = GlobalKey();
  @override
  void initState() {
    super.initState();
    print(_key);
    widget.controller.addKey(widget.step, _key);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: widget.child,
    );
  }
}

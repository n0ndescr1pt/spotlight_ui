import 'package:flutter/widgets.dart';
import 'package:spotlight_ui/spotlight_ui.dart';

class ControllerProvider extends InheritedWidget {
  final SpotlightController? spotlightController;

  const ControllerProvider({
    super.key,
    required super.child,
    required this.spotlightController,
  });
  @override
  bool updateShouldNotify(covariant ControllerProvider oldWidget) {
    return spotlightController != oldWidget.spotlightController;
  }

  static ControllerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ControllerProvider>();
  }
}

import 'package:flutter/widgets.dart';
import 'package:spotlight_ui/spotlight_ui.dart';
import 'package:spotlight_ui/src/stream_manager.dart';

class SpotlightController {
  final Map<int, List<GlobalKey>> highlightKeys = {};
  final Map<int, TooltipWidget> tooltipWidgets = {};
  final StreamManager streamManager = StreamManager();

  final ValueNotifier<int> currentStep = ValueNotifier<int>(0);

  void nextStep() {
    if (currentStep.value < highlightKeys.length - 1) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void addKey(int step, GlobalKey key, TooltipWidget? tooltip) {
    if (tooltip == null) {
      tooltipWidgets[step] = TooltipWidget(); //TODO добавить дефолтный тултип
    } else {
      tooltipWidgets[step] = tooltip;
    }
    if (highlightKeys.containsKey(step)) {
      highlightKeys[step]?.add(key);
    } else {
      highlightKeys[step] = [key];
    }
    //streamManager.addData(true);
  }

  SpotlightController();
}

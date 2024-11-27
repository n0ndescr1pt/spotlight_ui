import 'package:flutter/widgets.dart';
import 'package:spotlight_ui/src/stream_manager.dart';

class SpotlightController {
  final Map<int, List<GlobalKey>> highlightKeys = {};
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

  void addKey(int step, GlobalKey key) {
    if (highlightKeys.containsKey(step)) {
      highlightKeys[step]?.add(key);
    } else {
      highlightKeys[step] = [key];
    }
    //streamManager.addData(true);
  }

  SpotlightController();
}

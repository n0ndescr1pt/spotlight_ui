import 'package:flutter/widgets.dart';
import 'package:spotlight_ui/spotlight_ui.dart';
//import 'package:spotlight_ui/src/stream_manager.dart';

class SpotlightController {
  final Map<int, SpotlightStep> steps = {};
  //final StreamManager streamManager = StreamManager();
  final ValueNotifier<int> currentStep = ValueNotifier<int>(0);

  final ValueNotifier<bool> isEnabled;

  SpotlightController({bool isEnable = true})
      : isEnabled = ValueNotifier(isEnable);

  void disableOnboarding() {
    isEnabled.value = false;
  }

  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void addStep(int step, GlobalKey key, {TooltipWidget? tooltip}) {
    if (step < 0) {
      throw ArgumentError('Step must be non-negative');
    }
    final spotlightStep = steps.putIfAbsent(
      step,
      () => SpotlightStep(
        highlightKeys: [],
        tooltip: tooltip ??
            TooltipWidget(
              height: 200,
            ), // TODO Установить дефолтный тултип
      ),
    );
    //streamManager.addData(true);///TODO
    spotlightStep.highlightKeys.add(key);
  }
}

class SpotlightStep {
  final List<GlobalKey> highlightKeys;
  final TooltipWidget tooltip;

  SpotlightStep({required this.highlightKeys, required this.tooltip});
}

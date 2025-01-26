import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spotlight_ui/spotlight_ui.dart';
import 'package:spotlight_ui/src/controller_provider.dart';

part 'spotlight.dart';
class SpotlightController {
  final Map<int, SpotlightStep> steps = {};
  final ValueNotifier<int> currentStep;
  final ValueNotifier<bool> isEnabled;

  SpotlightController({
    bool isEnable = true,
    int initialPosition = -1,
  })  : isEnabled = ValueNotifier(isEnable),
        currentStep = ValueNotifier(initialPosition);

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

  void start() {
    currentStep.value = 0;
  }

  void stop() {
    currentStep.value = -1;
  }

   void _addStep(int step, GlobalKey key, {TooltipWidget? tooltip}) {
    if (step < 0) {
      throw ArgumentError('Step must be non-negative');
    }

    final spotlightStep = steps.putIfAbsent(
      step,
      () => SpotlightStep(
          highlightKeys: [], tooltip: tooltip ?? defaultTooltip()),
    );
    spotlightStep.highlightKeys.add(key);
  }
}

class SpotlightStep {
  final List<GlobalKey> highlightKeys;
  final TooltipWidget tooltip;

  SpotlightStep({required this.highlightKeys, required this.tooltip});
}

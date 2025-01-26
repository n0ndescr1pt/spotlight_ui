import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spotlight_ui/spotlight_ui.dart';
import 'package:spotlight_ui/src/controller_provider.dart';

part 'spotlight.dart';

/// Controller to manage the onboarding spotlight flow.
class SpotlightController {
  /// Map of steps with their associated data.
  final Map<int, SpotlightStep> steps = {};

  /// Current step being highlighted.
  final ValueNotifier<int> currentStep;

  /// Controls whether the onboarding is enabled or disabled.
  final ValueNotifier<bool> isEnabled;

  /// Constructor for SpotlightController.
  ///
  /// [isEnable]: Specifies if the spotlight is enabled initially.
  /// [initialPosition]: Sets the starting position for onboarding steps.
  SpotlightController({
    bool isEnable = true,
    int initialPosition = -1,
  })  : isEnabled = ValueNotifier(isEnable),
        currentStep = ValueNotifier(initialPosition);

  /// Disables the onboarding flow.
  void disableOnboarding() {
    isEnabled.value = false;
  }

  /// Moves to the next step in the onboarding flow.
  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
    }
  }

  /// Moves to the previous step in the onboarding flow.
  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Starts the onboarding flow from the first step.
  void start({int i = 0}) {
    currentStep.value = i;
  }

  /// Stops the onboarding flow.
  void stop() {
    currentStep.value = -1;
  }

  /// Adds a step to the spotlight sequence.
  ///
  /// [step]: The step index to add.
  /// [key]: The widget's GlobalKey to highlight.
  /// [tooltip]: Optional tooltip widget for the step.
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

/// Represents a single step in the spotlight sequence.
class SpotlightStep {
  /// List of keys to highlight in this step.
  final List<GlobalKey> highlightKeys;

  /// Tooltip widget associated with this step.
  final TooltipWidget tooltip;

  /// Constructor for SpotlightStep.
  SpotlightStep({required this.highlightKeys, required this.tooltip});
}

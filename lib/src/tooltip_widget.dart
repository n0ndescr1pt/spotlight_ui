import 'package:flutter/material.dart';
import 'package:spotlight_ui/spotlight_ui.dart';
import 'package:spotlight_ui/src/controller_provider.dart';

class TooltipWidget extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final TooltipButton? nextStepButton;
  final TooltipButton? skipButton;
  final double? width;
  final double height;
  final double? spacing;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;

  const TooltipWidget(
      {super.key,
      this.nextStepButton,
      this.skipButton,
      this.width,
      required this.height,
      this.spacing,
      this.backgroundColor,
      this.borderRadius,
      this.child,
      this.padding});

  @override
  Widget build(BuildContext context) {
    final SpotlightController? controller =
        ControllerProvider.of(context)?.spotlightController;
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            children: [
              child ?? const SizedBox.shrink(),
              SizedBox(height: spacing ?? 0),
              GestureDetector(
                onTap: controller?.nextStep,
                child: nextStepButton ?? const SizedBox.shrink(),
              ),
              SizedBox(height: spacing ?? 0),
              GestureDetector(
                onTap: controller?.disableOnboarding,
                child: skipButton ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TooltipWidget defaultTooltip() {
  return TooltipWidget(
    height: 150,
    nextStepButton: TooltipButton(
      borderRadius: BorderRadius.circular(28),
      backgroundColor: const Color.fromARGB(255, 206, 255, 0),
      width: double.infinity,
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Next",
          ),
        ),
      ),
    ),
    skipButton: const TooltipButton(
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Skip",
          ),
        ),
      ),
    ),
    backgroundColor: Colors.white,
    child: const Column(
      children: [
        Text(
          "Your description.",
        ),
        SizedBox(height: 12)
      ],
    ),
  );
}

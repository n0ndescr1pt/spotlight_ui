import 'package:flutter/material.dart';
import 'package:spotlight_ui/src/tooltip_button.dart';

class TooltipWidget extends StatelessWidget {
  final Function() onNextStep;
  final Function() onSkip;
  final TooltipButton? nextStepButton;
  final TooltipButton? skipButton;
  final double? width;
  final double? height;
  final double? spacing;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;

  const TooltipWidget({
    super.key,
    required this.onNextStep,
    required this.onSkip,
    this.nextStepButton,
    this.skipButton,
    this.width,
    this.height,
    this.spacing,
    this.backgroundColor,
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            child ?? const SizedBox.shrink(),
            SizedBox(height: spacing ?? 0),
            InkWell(
              onTap: onNextStep,
              child: nextStepButton ?? const SizedBox.shrink(),
            ),
            SizedBox(height: spacing ?? 0),
            InkWell(
              onTap: onSkip,
              child: nextStepButton ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

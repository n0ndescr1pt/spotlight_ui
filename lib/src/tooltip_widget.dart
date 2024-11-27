import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spotlight_ui/spotlight_ui.dart';
import 'package:spotlight_ui/src/controller_provider.dart';
import 'package:spotlight_ui/src/tooltip_button.dart';

class TooltipWidget extends StatelessWidget {
  final TooltipButton? nextStepButton;
  final TooltipButton? skipButton;
  final double? width;
  final double? height;
  final double? spacing;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;

  const TooltipWidget(
      {super.key,
      this.nextStepButton,
      this.skipButton,
      this.width,
      this.height,
      this.spacing,
      this.backgroundColor,
      this.borderRadius,
      this.child});

  @override
  Widget build(BuildContext context) {
    final SpotlightController controller =
        ControllerProvider.of(context)!.spotlightController;
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            child ?? const SizedBox.shrink(),
            SizedBox(height: spacing ?? 0),
            GestureDetector(
              onTap: controller.nextStep,
              child: nextStepButton ?? const SizedBox.shrink(),
            ),
            SizedBox(height: spacing ?? 0),
            GestureDetector(
              onTap: () {},
              child: skipButton ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

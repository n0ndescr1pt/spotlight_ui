import 'package:flutter/material.dart';

class TooltipButton extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;

  const TooltipButton({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

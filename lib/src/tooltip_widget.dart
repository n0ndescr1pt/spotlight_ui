import 'package:flutter/material.dart';

class TooltipWidget extends StatelessWidget {
  final Function() onNextStep;
  final Function() onSkip;
  const TooltipWidget(
      {super.key, required this.onNextStep, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Смените жилой квартал, если хотите потренироваться в другом месте",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onNextStep, child: Text("data")),
            const SizedBox(height: 8),
            GestureDetector(
                onTap: onSkip,
                child: Text(
                  "asdasd",
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
          ],
        ),
      ),
    );
  }
}

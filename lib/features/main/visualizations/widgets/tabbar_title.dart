import 'package:flutter/material.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class AppBarTitle extends StatelessWidget {
  final String text;
  final Color? color;

  const AppBarTitle({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: TebText(
          text,
          textAlign: TextAlign.center,
          textSize: 14,
          letterSpacing: 3,
          textColor: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

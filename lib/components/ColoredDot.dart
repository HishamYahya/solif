import 'package:flutter/material.dart';

class ColoredDot extends StatelessWidget {
  final Color color;

  ColoredDot(this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

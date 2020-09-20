import 'package:flutter/material.dart';

class ColoredDot extends StatelessWidget {
  final Color color;
  final double height, width;

  ColoredDot(this.color, {this.height, this.width, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 15,
      width: width ?? 15,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

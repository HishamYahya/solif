import 'package:flutter/material.dart';
import 'package:solif/constants.dart';

class TypingWidget extends StatefulWidget {
  final String colorName;

  TypingWidget(this.colorName);

  @override
  _TypingWidgetState createState() => _TypingWidgetState();
}

class _TypingWidgetState extends State<TypingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 30,
        width: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: kOurColors[widget.colorName]),
        child: Icon(
          Icons.more_horiz,
          color: Colors.white,
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Preferences.dart';

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
        height: 25,
        constraints: BoxConstraints(minWidth: 30, maxWidth: 50),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Provider.of<Preferences>(context)
                .currentColors[widget.colorName]),
        child: Icon(
          Icons.more_horiz,
          color: Colors.white,
        ));
  }
}

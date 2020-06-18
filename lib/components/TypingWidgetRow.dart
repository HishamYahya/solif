import 'package:flutter/material.dart';
import 'package:solif/components/TypingWidget.dart';

class TypingWidgetRow extends StatelessWidget {
  final Map colorsStatus;
  TypingWidgetRow({this.colorsStatus});

  List<Widget> generateTypingWidgets() {
    List<Widget> typingWidgets = [];
    colorsStatus.forEach((colorName, statusMap) {
      if (statusMap['isTyping']) {
        typingWidgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: TypingWidget(colorName),
        ));
      }
    });
    return typingWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Container(
        child: Row(
          children: generateTypingWidgets(),
        ),
      ),
    );
  }
}

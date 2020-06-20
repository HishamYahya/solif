import 'package:flutter/material.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String color;
  final bool fromUser;
  final List<String> readColors; 

  const MessageTile(
      {Key key,
      this.message,
      this.color,
      this.fromUser,
      this. readColors});

  List<Widget> getDots() {
    // testing how it looks.
    List<Widget> dots = [];
     for(String color in readColors) {
        {
        dots.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: ColoredDot(kOurColors[color]),
        ));
      }
    };
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 5.0, left: 5.0, bottom: 5.0),
          child: Container(
            padding: EdgeInsets.all(20),
            // margin: EdgeInsets.only(bottom:4),
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.1,
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: kOurColors[color],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(fromUser ? 10 : 40),
                  bottomLeft: Radius.circular(fromUser ? 40 : 10)),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        //Divider(
        //  )
        Padding(
          padding: const EdgeInsets.only(right: 5.0, left: 5.0, bottom: 5.0),
          child: Row(
            mainAxisAlignment:
                fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: getDots(),
          ),
        )
      ],
    );
  }
}

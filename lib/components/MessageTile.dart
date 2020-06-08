import 'package:flutter/material.dart';
import 'package:solif/constants.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String color;

  const MessageTile({Key key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          padding: EdgeInsets.all(20),
         // margin: EdgeInsets.only(bottom:4),
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[2],
            color: kOurColors[color],
            borderRadius: BorderRadius.circular(15),
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
    ]);
  }
}

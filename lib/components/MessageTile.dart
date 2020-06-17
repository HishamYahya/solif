import 'package:flutter/material.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String color;
  final bool fromUser;
  final Map<String,bool> messageCheckPoint; 

  const MessageTile({Key key, this.message, this.color, this.fromUser, this.messageCheckPoint});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start  ,
            children: getDots(),
          )
                      ],
                    ),
                  );
                }
              
                List<ColoredDot> getDots() {
                  List<ColoredDot> dots = []; 
                  messageCheckPoint.forEach((color, isCheckPoint) {
                    if(isCheckPoint){
                      dots.add(ColoredDot(kOurColors[color]));
                    }
                   });
                   return dots; 
                }
}

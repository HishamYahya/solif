import 'package:flutter/material.dart';
import 'package:solif/components/MessageTile.dart';

class ChatInputBox extends StatelessWidget {
  final Color color;
  final Function(String) onChanged;
  final Function(String) onSubmit;
  ChatInputBox({this.color, this.onSubmit, this.onChanged});

  final TextEditingController messageController = TextEditingController();
  String messageValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.only(left: 5, top: 5),
      // height: 70,
      //margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          // color: color,
          // borderRadius: BorderRadius.circular(20),
          ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          autocorrect: false,
          keyboardAppearance: Brightness.light,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          showCursor: true,
          decoration: InputDecoration(
              // focusedBorder: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(15),
              //   borderSide: BorderSide(
              //     width: 4,
              //     color: color,
              //   ),
              // ),
              // enabledBorder: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(15),
              //   borderSide: BorderSide(
              //     width: 4,
              //     color: color,
              //   ),
              // ),
              border: InputBorder.none,
              hoverColor: Colors.white,
              hintText: "Type a message",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              )),
          controller: messageController,
          onChanged: onChanged,
          onSubmitted: onSubmit,
        ),
      ),
    );
  }
}

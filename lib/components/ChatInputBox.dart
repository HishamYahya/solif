import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/MessageTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Preferences.dart';

class ChatInputBox extends StatefulWidget {
  final Color color;
  final Function(String) onChanged;
  final Function(String) onSubmit;
  final TextEditingController messageController;

  ChatInputBox(
      {this.color,
      this.onSubmit,
      this.onChanged,
      @required this.messageController});

  @override
  _ChatInputBoxState createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  FocusNode _focusNode = FocusNode();

  String messageValue;

  @override
  void initState() {
    super.initState();
    bool isArabic = Provider.of<Preferences>(context, listen: false).isArabic;
    messageValue = isArabic ? 'ت' : 'j';
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    return Container(
      //padding: EdgeInsets.only(left: 5, top: 5),
      // height: 70,
      //margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          // color: color,
          // borderRadius: BorderRadius.circular(20),
          ),
      child: AutoDirection(
        text: messageValue,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: TextField(
            autocorrect: false,
            focusNode: _focusNode,
            keyboardAppearance: darkMode ? Brightness.dark : Brightness.light,
            style: TextStyle(
              fontSize: 16,
              color: darkMode ? kDarkModeTextColor87 : Colors.black,
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
              hintText: isArabic ? "اكتب رسالة" : "Type a message",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            controller: widget.messageController,
            onChanged: (value) {
              setState(() {
                messageValue = value.isEmpty ? isArabic ? 'ت' : 'j' : value;
              });
              widget.onChanged(value);
            },
            onSubmitted: (value) {
              FocusScope.of(context).requestFocus(_focusNode);
              widget.messageController.clear();
              widget.onSubmit(value);
            },
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class Message {
  String content;
  DateTime timeSent;
  String messageColor;
  Map<String, bool> hasRead = {
    kColorNames[0]: false,
    kColorNames[1]: false,
    kColorNames[2]: false,
    kColorNames[3]: false,
    kColorNames[4]: false,
  };

  Message({
    @required this.content,
    @required this.timeSent,
    @required this.messageColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'timeSent': timeSent,
      'color': messageColor,
      'hasRead': hasRead
    };
  }
}

// now returns whether it succeeded or not
Future<bool> addMessage(
    String messageContent, String color, String salfhID) async {
  //print(salfhID);
  final firestore = Firestore.instance;
  bool success = false;
  if (salfhID != null) {
    await firestore
        .collection("chatRooms")
        .document(salfhID)
        .collection('messages')
        .add(Message(
                content: messageContent,
                timeSent: DateTime.now(),
                messageColor: color)
            .toMap())
        .then((value) {
          success = true;
        })
        .timeout(Duration(seconds: 5))
        .catchError((err) {});
  }
  return success;
}

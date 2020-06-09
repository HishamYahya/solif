import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class Message {
  String id;
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
    @required this.id,
    @required this.content,
    @required this.timeSent,
    @required this.messageColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timeSent': timeSent,
      'color': messageColor,
      'hasRead': hasRead
    };
  }
}

void addMessage(String messageContent, String color, String id) {
  String salfhID = id; // to avoid avoid using widget everytime.
  //print(salfhID);
  final firestore = Firestore.instance; 
  

  if (salfhID != null) {
    // generate unique message key
    final messageKey = 
        firestore.collection("Swalf")
        .document(salfhID)
        .collection("messages")
        .document()
        .documentID;

    // save message with   generated key
    firestore
        .collection("Swalf")
        .document(salfhID)
        .collection("messages")
        .document(messageKey)
        .setData(Message(
                id: messageKey,
                content: messageContent,
                timeSent: DateTime.now(),
                messageColor: color)
            .toMap());
  }
}

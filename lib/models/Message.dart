import 'package:flutter/material.dart';

class Message {
  String id;
  String content;
  DateTime timeSent;
  String senderID;

  Message({
    @required this.id,
    @required this.content,
    @required this.timeSent,
    @required this.senderID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timeSent': timeSent,
      'senderID': senderID
    };
  }
}

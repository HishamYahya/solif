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

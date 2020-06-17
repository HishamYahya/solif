import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class Message {
  String content;
  DateTime timeSent;
  String messageColor;
  Map<String, bool> isCheckPointMessage = {
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
      'isCheckPointMessage': isCheckPointMessage
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
        .then((value) async {
          success = true;

          await firestore.collection("Swalf").document(salfhID).updateData(
              {'lastMessageSentID': value.documentID}).then((value) {
            updateUsersLastMessageRead(salfhID);
          });
        })
        .timeout(Duration(seconds: 5))
        .catchError((err) {});
  }
  return success;
}

void updateUsersLastMessageRead(salfhID) async {
  final firestore = Firestore.instance;
  DocumentReference salfhDoc = firestore.collection("Swalf").document(salfhID);
  Map<String, dynamic> salfh = await salfhDoc.get().then((value) => value.data);
  salfh['colorsStatus'].forEach((color, statusMap) { // not the most effiecent way, but avoids complications on other parts of the code.
    print(statusMap);
    if (statusMap['isInChatRoom']) {
      DocumentReference oldCheckPoint = firestore
          .collection("chatRooms")
          .document(salfhID)
          .collection('messages')
          .document(statusMap['lastMessageReadID']);
      oldCheckPoint.setData({
        'isCheckPointMessage': {color: false}
      }, merge: true);
      DocumentReference newCheckPoint = firestore
          .collection("chatRooms")
          .document(salfhID)
          .collection('messages')
          .document(salfh['lastMessageSentID']);

      newCheckPoint.setData({
        'isCheckPointMessage': {color: true}
      }, merge: true);

      statusMap['lastMessageReadID'] = salfh['lastMessageSentID'];
    }

    
  });
  salfhDoc.updateData(salfh);
}

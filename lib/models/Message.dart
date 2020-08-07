
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Message {
  String content;
  FieldValue serverTimeSent;
  Timestamp timeSent;
  String color;
  String userID;

  Message(
      {@required this.content,
      @required this.timeSent,
      @required this.color,
      @required this.userID});

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'timeSent': timeSent,
      'color': color,
      'userID': userID
    };
  }
}

}

// now returns whether it succeeded or not
Future<bool> addMessage(
    String messageContent, String color, String salfhID, String userID) async {
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
                serverTimeSent: FieldValue.serverTimestamp(),
                color: color,
                userID: userID)
            .toMap())
        .then((value) {
          success = true;
        })
        .timeout(Duration(seconds: 5))
        .catchError((err) {});
  }
  return success;
}

// void updateUsersLastMessageRead(salfhID) async {
//   final firestore = Firestore.instance;
//   DocumentReference salfhDoc = firestore.collection("Swalf").document(salfhID);
//   Map<String, dynamic> salfh = await salfhDoc.get().then((value) => value.data);
//   salfh['colorsStatus'].forEach((color, statusMap) { // not the most effiecent way, but avoids complications on other parts of the code.
//     print(statusMap);
//     if (statusMap['isInChatRoom']) {
//       DocumentReference oldCheckPoint = firestore
//           .collection("chatRooms")
//           .document(salfhID)
//           .collection('messages')
//           .document(statusMap['lastMessageReadID']);
//       oldCheckPoint.setData({
//         'isCheckPointMessage': {color: false}
//       }, merge: true);
//       DocumentReference newCheckPoint = firestore
//           .collection("chatRooms")
//           .document(salfhID)
//           .collection('messages')
//           .document(salfh['lastMessageSentID']);

//       newCheckPoint.setData({
//         'isCheckPointMessage': {color: true}
//       }, merge: true);

//       statusMap['lastMessageReadID'] = salfh['lastMessageSentID'];
//     }

//   });
//   salfhDoc.updateData(salfh);
// }

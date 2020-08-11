import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class Message {
  String content;
  FieldValue serverTimeSent;
  Timestamp timeSent;
  String color;
  String userID;

  Message(
      {@required this.content,
      this.serverTimeSent,
      @required this.color,
      this.userID,
      this.timeSent});

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'timeSent': serverTimeSent,
      'color': color,
      'userID': userID
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timeSent': timeSent.toDate().toIso8601String(),
      'color': color,
      'userID': userID
    };
  }
}

Message fromJson(Map<String, dynamic> jsonMessage) {
  return Message(
      color: jsonMessage['color'],
      content: jsonMessage['content'],
      timeSent: Timestamp.fromDate(DateTime.parse(jsonMessage['timeSent'])));
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


 Future<void> setLocalStorage(List<Map<String,dynamic>> allTheMessages, var futureLastMessageSavedLocallyTime, LocalStorage storage) async {
   print('here');
   print('futureLastMessageSavedLocallyTime'); 
    if (futureLastMessageSavedLocallyTime != null) {
      await storage.ready;
      
      storage.setItem('local_messages', allTheMessages.reversed.toList());
      print("before saving $futureLastMessageSavedLocallyTime");
      {
        storage.setItem('last_message_time',
            futureLastMessageSavedLocallyTime.toDate().toIso8601String());
      }
    }
  }
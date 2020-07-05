import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/User.dart';
import 'package:solif/models/Tag.dart';

import '../constants.dart';

final firestore = Firestore.instance;

class Salfh {
  final Map<String, Map<String, dynamic>>
      colorsStatus; // Color: {"userID": id, "lastMessageRead":messageID, "isInChatRoom":bool}
  int maxUsers;
  String category;
  String creatorID;
  String title;
  DateTime timeCreated;
  DateTime lastMessageSentTime;
  String lastMessageSentID;
  List<String> tags;

  Salfh(
      {@required this.maxUsers,
      @required this.category,
      this.colorsStatus,
      this.title,
      this.timeCreated,
      this.lastMessageSentTime,
      this.creatorID,
      this.tags,
      this.lastMessageSentID});

  Map<String, dynamic> toMap() {
    return {
      'colorsStatus': colorsStatus,
      'creatorID': creatorID,
      'maxUsers': maxUsers,
      'category': category,
      'title': title,
      'timeCreated': timeCreated,
      'lastMessageSentTime': lastMessageSentTime,
      'lastMessageSentID': lastMessageSentID,
      'tags': this.tags
    };
  }
}

Future<bool> joinSalfh({String userID, String salfhID, colorName}) async {
  final ref = firestore.collection('Swalf').document(salfhID);
  bool added = false;
  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(ref);
    if (snapshot.exists) {
      if (snapshot.data['colorsStatus'][colorName]['userID'] == null) {
        final newColorsStatus = snapshot.data['colorsStatus'];
        newColorsStatus[colorName]['userID'] = userID;
        transaction.update(ref, {'colorsStatus': newColorsStatus});
      }
    }
  }).then((value) {
    added = true;
  });
  if (added) {
    await addSalfhToUser(userID, salfhID, colorName);
  }
  return added;
}

Future<Map> saveSalfh(
    {String creatorID,
    int maxUsers,
    String category,
    String title,
    List<String> tags}) async {
  Map salfh = Salfh(
          maxUsers: maxUsers,
          creatorID: creatorID,
          category: category,
          colorsStatus: getInitialColorStatus(creatorID, maxUsers),
          title: title,
          timeCreated: DateTime.now(),
          lastMessageSentTime: DateTime.now(),
          lastMessageSentID: null,
          tags: tags)
      .toMap();

  DocumentReference ref = await firestore.collection("Swalf").add(salfh);
  salfh['id'] = ref.documentID;

  String color = await getColorOfUser(userID: creatorID, salfh: salfh);
  if (ref != null) {
    print('yooo');

    addSalfhToUser(creatorID, ref.documentID, color);
    createSalfhChatRoom(ref.documentID);
    incrementTags(tags);
    return salfh;
  }
  return null;
}

void createSalfhChatRoom(String salfhID) async {
  await firestore.collection("chatRooms").document(salfhID).setData({
    kColorNames[0]: DateTime.now(),
    kColorNames[1]: DateTime.now(),
    kColorNames[2]: DateTime.now(),
    kColorNames[3]: DateTime.now(),
    kColorNames[4]: DateTime.now(),
  });
}

Map<String, Map<String, dynamic>> getInitialColorStatus(
    String creatorID, int maxUsers) {
  Map<String, Map<String, dynamic>> res = Map<String, Map<String, dynamic>>();
  String colorName = kColorNames[Random().nextInt(maxUsers)];

  for (String color in kColorNames.sublist(0, maxUsers)..shuffle()) {
    if (color == colorName) {
      res[color] = {
        'userID': creatorID,
        'lastMessageReadID': null,
        'isInChatRoom': false,
        'isTyping': false
      };
    } else {
      res[color] = {
        'userID': null,
        'lastMessageReadID': null,
        'isInChatRoom': false,
        'isTyping': false
      };
    }
  }
  return res;
}

Future<String> getColorOfUser({String userID, Map salfh}) async {
  String colorName;
  salfh['colorsStatus'].forEach((name, statusMap) {
    statusMap['userID'] == userID ? colorName = name : null;
  });
  return colorName;
}

Future<void> leaveSalfh({String salfhID, String userColor,String userID}) async {
  await firestore.collection('Swalf').document(salfhID).setData({
    'category': 'ok',
    'colorsStatus': {
      userColor: {'userID': null}
    }
  }, merge: true).then((value) async {
    await deleteSalfhFromUser(salfhID,userID);
  });
}


